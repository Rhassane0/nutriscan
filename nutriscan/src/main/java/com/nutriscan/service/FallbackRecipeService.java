package com.nutriscan.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.response.RecipeResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Fallback recipe service using Gemini AI when Edamam API is unavailable.
 * No static/mock data - generates real recipes using AI.
 */
@Service
@Slf4j
public class FallbackRecipeService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String geminiModel;

    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s";

    public FallbackRecipeService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
        this.objectMapper = new ObjectMapper();
    }

    /**
     * Search recipes using Gemini AI when Edamam is unavailable
     */
    public List<RecipeResponse> searchRecipes(String query, String mealType, Integer calories, Integer maxResults) {
        log.info("⚠️ FALLBACK MODE: Using Gemini AI to generate recipes: query={}, mealType={}, calories={}, maxResults={}",
                query, mealType, calories, maxResults);

        // Check if Gemini API key is configured
        if (geminiApiKey == null || geminiApiKey.isEmpty() || geminiApiKey.equals("your-gemini-api-key-here")) {
            log.error("❌ Gemini API key not configured. Cannot generate fallback recipes.");
            log.error("💡 Configure gemini.api.key in application.properties");
            return new ArrayList<>();
        }

        int limit = maxResults != null && maxResults > 0 ? Math.min(maxResults, 5) : 5;

        try {
            String prompt = buildRecipePrompt(query, mealType, calories, limit);
            String geminiResponse = callGeminiAPI(prompt);

            if (geminiResponse == null || geminiResponse.isEmpty()) {
                log.warn("⚠️ Empty response from Gemini API");
                return new ArrayList<>();
            }

            List<RecipeResponse> recipes = parseGeminiRecipeResponse(geminiResponse);
            log.info("✅ Generated {} recipes using Gemini AI", recipes.size());
            return recipes;

        } catch (Exception e) {
            log.error("❌ Error generating recipes with Gemini: {}", e.getMessage(), e);
            return new ArrayList<>();
        }
    }

    /**
     * Build prompt for recipe generation
     */
    private String buildRecipePrompt(String query, String mealType, Integer calories, int count) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Tu es un chef cuisinier et nutritionniste expert. ");
        prompt.append("Génère exactement ").append(count).append(" recettes ");

        if (query != null && !query.isBlank()) {
            prompt.append("pour \"").append(query).append("\" ");
        }

        if (mealType != null && !mealType.isBlank()) {
            prompt.append("pour le repas: ").append(mealType).append(" ");
        }

        if (calories != null && calories > 0) {
            prompt.append("avec environ ").append(calories).append(" calories par portion ");
        }

        prompt.append("\n\nPour CHAQUE recette, fournis:\n");
        prompt.append("- name: nom de la recette en français\n");
        prompt.append("- servings: nombre de portions\n");
        prompt.append("- calories: calories totales par portion\n");
        prompt.append("- protein: protéines en grammes par portion\n");
        prompt.append("- carbs: glucides en grammes par portion\n");
        prompt.append("- fat: lipides en grammes par portion\n");
        prompt.append("- ingredients: liste des ingrédients avec quantités\n");
        prompt.append("- prepTime: temps de préparation en minutes\n");
        prompt.append("\nIMPORTANT: Réponds UNIQUEMENT avec un JSON valide, sans texte avant ou après:\n");
        prompt.append("{\"recipes\": [{\"name\": \"...\", \"servings\": 2, \"calories\": 450, \"protein\": 25, \"carbs\": 40, \"fat\": 18, \"ingredients\": [\"...\"], \"prepTime\": 30}]}\n");
        prompt.append("\nSois précis et réaliste avec les valeurs nutritionnelles.");

        return prompt.toString();
    }

    /**
     * Call Gemini API
     */
    private String callGeminiAPI(String prompt) {
        try {
            String url = String.format(GEMINI_API_URL, geminiModel, geminiApiKey);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            Map<String, Object> requestBody = new HashMap<>();
            List<Map<String, Object>> contents = new ArrayList<>();
            Map<String, Object> content = new HashMap<>();
            List<Map<String, Object>> parts = new ArrayList<>();

            Map<String, Object> textPart = new HashMap<>();
            textPart.put("text", prompt);
            parts.add(textPart);

            content.put("parts", parts);
            contents.add(content);
            requestBody.put("contents", contents);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            log.debug("🚀 Calling Gemini API for recipe generation");

            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            if (response.getBody() != null) {
                if (response.getBody().containsKey("error")) {
                    Map<String, Object> error = (Map<String, Object>) response.getBody().get("error");
                    log.error("❌ Gemini API error: {}", error);
                    return null;
                }

                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.getBody().get("candidates");
                if (candidates != null && !candidates.isEmpty()) {
                    Map<String, Object> candidate = candidates.get(0);
                    Map<String, Object> contentResp = (Map<String, Object>) candidate.get("content");
                    if (contentResp != null) {
                        List<Map<String, Object>> partsResp = (List<Map<String, Object>>) contentResp.get("parts");
                        if (partsResp != null && !partsResp.isEmpty()) {
                            return (String) partsResp.get(0).get("text");
                        }
                    }
                }
            }

            return null;
        } catch (Exception e) {
            log.error("❌ Error calling Gemini API: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Parse Gemini response into RecipeResponse objects
     */
    private List<RecipeResponse> parseGeminiRecipeResponse(String geminiResponse) {
        List<RecipeResponse> recipes = new ArrayList<>();

        try {
            // Clean the response
            String cleanResponse = geminiResponse
                    .replaceAll("```json\\s*", "")
                    .replaceAll("```\\s*", "")
                    .replaceAll("```", "")
                    .trim();

            // Find JSON in response
            int jsonStart = cleanResponse.indexOf("{");
            int jsonEnd = cleanResponse.lastIndexOf("}");

            if (jsonStart >= 0 && jsonEnd > jsonStart) {
                cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
            }

            // Parse the JSON
            JsonNode root = objectMapper.readTree(cleanResponse);
            JsonNode recipesNode = root.get("recipes");

            if (recipesNode != null && recipesNode.isArray()) {
                for (JsonNode recipeNode : recipesNode) {
                    RecipeResponse recipe = parseRecipeNode(recipeNode);
                    if (recipe != null) {
                        recipes.add(recipe);
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error parsing Gemini recipe response: {}", e.getMessage());
            // Try regex-based parsing as fallback
            recipes = parseWithRegex(geminiResponse);
        }

        return recipes;
    }

    /**
     * Parse a single recipe node
     */
    private RecipeResponse parseRecipeNode(JsonNode node) {
        try {
            String name = node.has("name") ? node.get("name").asText() : "Recette";
            int servings = node.has("servings") ? node.get("servings").asInt() : 2;
            double calories = node.has("calories") ? node.get("calories").asDouble() : 0;
            double protein = node.has("protein") ? node.get("protein").asDouble() : 0;
            double carbs = node.has("carbs") ? node.get("carbs").asDouble() : 0;
            double fat = node.has("fat") ? node.get("fat").asDouble() : 0;
            double prepTime = node.has("prepTime") ? node.get("prepTime").asDouble() : 30;

            List<String> ingredients = new ArrayList<>();
            if (node.has("ingredients") && node.get("ingredients").isArray()) {
                for (JsonNode ing : node.get("ingredients")) {
                    ingredients.add(ing.asText());
                }
            }

            RecipeResponse.NutritionInfo nutrition = RecipeResponse.NutritionInfo.builder()
                    .calories(calories)
                    .protein(protein)
                    .carbs(carbs)
                    .fat(fat)
                    .fiber(3.0)
                    .sugar(5.0)
                    .build();

            return RecipeResponse.builder()
                    .uri("gemini:" + name.toLowerCase().replace(" ", "-") + "-" + System.currentTimeMillis())
                    .label(name)
                    .image(null)
                    .source("NutriScan AI (Gemini)")
                    .url(null)
                    .servings(servings)
                    .calories(calories)
                    .totalTime(prepTime)
                    .dietLabels(new ArrayList<>())
                    .healthLabels(new ArrayList<>())
                    .ingredientLines(ingredients)
                    .nutrition(nutrition)
                    .build();

        } catch (Exception e) {
            log.warn("Error parsing recipe node: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Fallback regex-based parsing
     */
    private List<RecipeResponse> parseWithRegex(String response) {
        List<RecipeResponse> recipes = new ArrayList<>();

        try {
            Pattern recipePattern = Pattern.compile("\\{[^{}]*\"name\"\\s*:\\s*\"([^\"]+)\"[^{}]*\\}");
            Matcher matcher = recipePattern.matcher(response);

            while (matcher.find()) {
                String recipeJson = matcher.group();
                String name = extractJsonStringValue(recipeJson, "name");
                double calories = extractJsonNumberValue(recipeJson, "calories", 400);
                double protein = extractJsonNumberValue(recipeJson, "protein", 20);
                double carbs = extractJsonNumberValue(recipeJson, "carbs", 40);
                double fat = extractJsonNumberValue(recipeJson, "fat", 15);
                int servings = (int) extractJsonNumberValue(recipeJson, "servings", 2);

                if (!name.isEmpty()) {
                    RecipeResponse.NutritionInfo nutrition = RecipeResponse.NutritionInfo.builder()
                            .calories(calories)
                            .protein(protein)
                            .carbs(carbs)
                            .fat(fat)
                            .build();

                    RecipeResponse recipe = RecipeResponse.builder()
                            .uri("gemini:" + name.toLowerCase().replace(" ", "-"))
                            .label(name)
                            .source("NutriScan AI (Gemini)")
                            .servings(servings)
                            .calories(calories)
                            .totalTime(30.0)
                            .ingredientLines(new ArrayList<>())
                            .nutrition(nutrition)
                            .build();

                    recipes.add(recipe);
                }
            }
        } catch (Exception e) {
            log.warn("Regex parsing failed: {}", e.getMessage());
        }

        return recipes;
    }

    private String extractJsonStringValue(String json, String key) {
        Pattern pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(json);
        return matcher.find() ? matcher.group(1) : "";
    }

    private double extractJsonNumberValue(String json, String key, double defaultValue) {
        Pattern pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*([\\d.]+)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            try {
                return Double.parseDouble(matcher.group(1));
            } catch (NumberFormatException e) {
                return defaultValue;
            }
        }
        return defaultValue;
    }

    public List<RecipeResponse> getAllRecipes() {
        // No static recipes anymore - return empty list
        log.warn("getAllRecipes() called but no static recipes exist. Use searchRecipes() with Gemini AI.");
        return new ArrayList<>();
    }
}
