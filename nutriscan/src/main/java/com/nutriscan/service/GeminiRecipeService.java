package com.nutriscan.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.response.RecipeResponse;
import com.nutriscan.model.User;
import com.nutriscan.model.enums.GoalType;
import com.nutriscan.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.*;

/**
 * Service de génération de plans de repas via Gemini AI (gemma)
 */
@Service
@Slf4j
public class GeminiRecipeService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final UserRepository userRepository;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String modelName;

    public GeminiRecipeService(RestTemplate restTemplate, UserRepository userRepository) {
        this.restTemplate = restTemplate;
        this.userRepository = userRepository;
    }

    /**
     * Génère un plan de repas complet pour plusieurs jours en UN SEUL appel
     */
    public Map<String, Map<String, RecipeResponse>> generateFullMealPlan(
            Long userId, LocalDate startDate, int days, int dailyCalories,
            List<String> preferences, List<String> allergies) {

        if (!isConfigured()) {
            log.warn("⚠️ Gemini API not configured");
            return Collections.emptyMap();
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            log.info("🤖 Generating {} day meal plan with Gemini AI ({} cal/day)", days, dailyCalories);

            String prompt = buildPlanPrompt(days, dailyCalories, preferences, allergies, user);
            String response = callGemini(prompt);

            if (response == null || response.isEmpty()) {
                log.warn("Empty response from Gemini");
                return Collections.emptyMap();
            }

            return parsePlanResponse(response, startDate, days);
        } catch (Exception e) {
            log.error("❌ Error generating meal plan: {}", e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Génère des recettes pour un type de repas
     */
    public List<RecipeResponse> generateRecipesForUser(Long userId, String mealType, int calories,
                                                        List<String> preferences, List<String> allergies) {
        if (!isConfigured()) {
            return Collections.emptyList();
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            String prompt = buildRecipePrompt(mealType, calories, preferences, allergies, user);
            String response = callGemini(prompt);

            if (response == null) return Collections.emptyList();
            return parseRecipes(response);
        } catch (Exception e) {
            log.error("Error generating recipes: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    private boolean isConfigured() {
        return geminiApiKey != null && !geminiApiKey.isEmpty() && !geminiApiKey.equals("your-gemini-api-key-here");
    }

    private String buildPlanPrompt(int days, int dailyCalories, List<String> preferences,
                                    List<String> allergies, User user) {
        StringBuilder p = new StringBuilder();
        p.append("Tu es un chef nutritionniste. Génère un plan de repas pour ").append(days);
        p.append(" jours avec ").append(dailyCalories).append(" calories/jour.\n\n");

        if (user != null) {
            if (user.getGoalType() != null) {
                p.append("Objectif: ").append(goalToString(user.getGoalType())).append("\n");
            }
            if (user.getDietPreferences() != null) {
                p.append("Régime: ").append(user.getDietPreferences()).append("\n");
            }
            if (user.getAllergies() != null) {
                p.append("Allergies: ").append(user.getAllergies()).append("\n");
            }
        }

        if (preferences != null && !preferences.isEmpty()) {
            p.append("Préférences: ").append(String.join(", ", preferences)).append("\n");
        }
        if (allergies != null && !allergies.isEmpty()) {
            p.append("EXCLURE: ").append(String.join(", ", allergies)).append("\n");
        }

        p.append("\nCalories: Petit-déj 25%, Déjeuner 35%, Dîner 30%, Collation 10%\n\n");
        p.append("RÉPONDS UNIQUEMENT EN JSON (pas de texte):\n");
        p.append("[{\"day\":1,\"breakfast\":{\"name\":\"...\",\"calories\":500,\"protein\":20,\"carbs\":60,\"fat\":15,\"ingredients\":[\"...\"]},");
        p.append("\"lunch\":{\"name\":\"...\",\"calories\":700,\"protein\":30,\"carbs\":70,\"fat\":25,\"ingredients\":[\"...\"]},");
        p.append("\"dinner\":{\"name\":\"...\",\"calories\":600,\"protein\":30,\"carbs\":50,\"fat\":25,\"ingredients\":[\"...\"]},");
        p.append("\"snack\":{\"name\":\"...\",\"calories\":200,\"protein\":10,\"carbs\":25,\"fat\":8,\"ingredients\":[\"...\"]}}]\n");

        return p.toString();
    }

    private String buildRecipePrompt(String mealType, int calories, List<String> preferences,
                                      List<String> allergies, User user) {
        StringBuilder p = new StringBuilder();
        p.append("Génère 3 recettes pour un ").append(mealTypeFr(mealType));
        p.append(" d'environ ").append(calories).append(" calories.\n");

        if (user != null && user.getGoalType() != null) {
            p.append("Objectif: ").append(goalToString(user.getGoalType())).append("\n");
        }
        if (preferences != null && !preferences.isEmpty()) {
            p.append("Préférences: ").append(String.join(", ", preferences)).append("\n");
        }
        if (allergies != null && !allergies.isEmpty()) {
            p.append("EXCLURE: ").append(String.join(", ", allergies)).append("\n");
        }

        p.append("\nRÉPONDS UNIQUEMENT EN JSON:\n");
        p.append("[{\"name\":\"...\",\"calories\":").append(calories);
        p.append(",\"protein\":20,\"carbs\":30,\"fat\":15,\"ingredients\":[\"...\"]}]\n");

        return p.toString();
    }

    private String mealTypeFr(String type) {
        return switch (type.toUpperCase()) {
            case "BREAKFAST" -> "petit-déjeuner";
            case "LUNCH" -> "déjeuner";
            case "DINNER" -> "dîner";
            case "SNACK" -> "collation";
            default -> "repas";
        };
    }

    private String goalToString(GoalType goal) {
        return switch (goal) {
            case LOSE_WEIGHT -> "Perdre du poids";
            case GAIN_WEIGHT -> "Prendre du poids";
            case MAINTAIN -> "Maintenir le poids";
        };
    }

    @SuppressWarnings("unchecked")
    private Map<String, Map<String, RecipeResponse>> parsePlanResponse(String response, LocalDate startDate, int days) {
        Map<String, Map<String, RecipeResponse>> result = new LinkedHashMap<>();

        try {
            String json = extractJson(response);
            if (json == null) return result;

            List<Map<String, Object>> dayPlans = objectMapper.readValue(json, new TypeReference<>() {});

            for (int i = 0; i < Math.min(dayPlans.size(), days); i++) {
                Map<String, Object> dayPlan = dayPlans.get(i);
                LocalDate date = startDate.plusDays(i);
                Map<String, RecipeResponse> dayMeals = new HashMap<>();

                for (String meal : List.of("breakfast", "lunch", "dinner", "snack")) {
                    Object data = dayPlan.get(meal);
                    if (data instanceof Map) {
                        RecipeResponse recipe = toRecipe((Map<String, Object>) data);
                        if (recipe != null) dayMeals.put(meal.toUpperCase(), recipe);
                    }
                }
                result.put(date.toString(), dayMeals);
            }
            log.info("✅ Parsed {} days meal plan", result.size());
        } catch (Exception e) {
            log.error("Parse error: {}", e.getMessage());
        }
        return result;
    }

    private List<RecipeResponse> parseRecipes(String response) {
        List<RecipeResponse> recipes = new ArrayList<>();
        try {
            String json = extractJson(response);
            if (json == null) return recipes;

            List<Map<String, Object>> list = objectMapper.readValue(json, new TypeReference<>() {});
            for (Map<String, Object> data : list) {
                RecipeResponse r = toRecipe(data);
                if (r != null) recipes.add(r);
            }
        } catch (Exception e) {
            log.error("Parse recipes error: {}", e.getMessage());
        }
        return recipes;
    }

    private String extractJson(String response) {
        String clean = response.replaceAll("```json\\s*", "").replaceAll("```\\s*", "").trim();
        int s = clean.indexOf('[');
        int e = clean.lastIndexOf(']');
        return (s >= 0 && e > s) ? clean.substring(s, e + 1) : null;
    }

    @SuppressWarnings("unchecked")
    private RecipeResponse toRecipe(Map<String, Object> data) {
        try {
            RecipeResponse r = new RecipeResponse();
            r.setLabel((String) data.get("name"));
            r.setCalories(toDouble(data.get("calories")));
            r.setUri("gemini-" + UUID.randomUUID());
            r.setSource("NutriScan AI");
            r.setServings(2);

            RecipeResponse.NutritionInfo n = new RecipeResponse.NutritionInfo();
            n.setCalories(toDouble(data.get("calories")));
            n.setProtein(toDouble(data.get("protein")));
            n.setCarbs(toDouble(data.get("carbs")));
            n.setFat(toDouble(data.get("fat")));
            r.setNutrition(n);

            Object ing = data.get("ingredients");
            if (ing instanceof List) {
                r.setIngredientLines(new ArrayList<>((List<String>) ing));
            }
            return r;
        } catch (Exception e) {
            return null;
        }
    }

    private String callGemini(String prompt) {
        // Try multiple models
        for (String model : List.of(modelName, "gemini-1.5-flash", "gemini-2.0-flash-exp")) {
            try {
                String result = callModel(model, prompt);
                if (result != null && !result.isEmpty()) return result;
            } catch (Exception e) {
                log.warn("Model {} failed", model);
            }
        }
        return null;
    }

    private String callModel(String model, String prompt) {
        try {
            String url = "https://generativelanguage.googleapis.com/v1beta/models/" + model +
                         ":generateContent?key=" + geminiApiKey;

            Map<String, Object> body = Map.of(
                "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))),
                "generationConfig", Map.of("temperature", 0.7, "maxOutputTokens", 8192)
            );

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

            log.info("🤖 Calling {}", model);
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                String text = extractText(response.getBody());
                if (text != null) {
                    log.info("✅ Got response from {}", model);
                    return text;
                }
            }
        } catch (Exception e) {
            log.warn("Error calling {}: {}", model, e.getMessage());
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private String extractText(Map<String, Object> body) {
        try {
            List<Map<String, Object>> candidates = (List<Map<String, Object>>) body.get("candidates");
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> content = (Map<String, Object>) candidates.get(0).get("content");
                if (content != null) {
                    List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
                    if (parts != null && !parts.isEmpty()) {
                        return (String) parts.get(0).get("text");
                    }
                }
            }
        } catch (Exception e) {
            log.error("Extract error: {}", e.getMessage());
        }
        return null;
    }

    private double toDouble(Object v) {
        if (v == null) return 0;
        if (v instanceof Number) return ((Number) v).doubleValue();
        try {
            return Double.parseDouble(v.toString().replaceAll("[^0-9.]", ""));
        } catch (Exception e) {
            return 0;
        }
    }
}

