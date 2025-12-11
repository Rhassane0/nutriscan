package com.nutriscan.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.response.RecipeResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.ArrayList;
import java.util.List;

@Service
@Slf4j
public class EdamamRecipeService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final FallbackRecipeService fallbackRecipeService;

    @Value("${edamam.recipe.app-id}")
    private String appId;

    @Value("${edamam.recipe.app-key}")
    private String appKey;

    @Value("${edamam.recipe.base-url}")
    private String baseUrl;

    public EdamamRecipeService(FallbackRecipeService fallbackRecipeService) {
        this.fallbackRecipeService = fallbackRecipeService;
    }

    /**
     * Search recipes based on query and filters
     */
    public List<RecipeResponse> searchRecipes(String query,
                                                List<String> diet,
                                                List<String> health,
                                                String cuisineType,
                                                String mealType,
                                                Integer calories,
                                                Integer maxResults) {
        try {
            log.info("Searching recipes with query: {}, diet: {}, health: {}, cuisine: {}, mealType: {}, calories: {}, maxResults: {}",
                query, diet, health, cuisineType, mealType, calories, maxResults);

            UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(baseUrl)
                    .queryParam("type", "public")
                    .queryParam("q", query)
                    .queryParam("app_id", appId)
                    .queryParam("app_key", appKey);

            if (diet != null && !diet.isEmpty()) {
                diet.forEach(d -> builder.queryParam("diet", d));
            }

            if (health != null && !health.isEmpty()) {
                health.forEach(h -> builder.queryParam("health", h));
            }

            if (cuisineType != null) {
                builder.queryParam("cuisineType", cuisineType);
            }

            if (mealType != null) {
                builder.queryParam("mealType", mealType);
            }

            if (calories != null) {
                builder.queryParam("calories", calories);
            }

            if (maxResults != null && maxResults > 0) {
                builder.queryParam("to", maxResults);
            }

            String url = builder.toUriString();
            log.info("🔍 Calling Edamam Recipe API for query: '{}'", query);
            log.debug("Full URL: {}", url);

            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);

            if (response.getStatusCode().is2xxSuccessful()) {
                log.info("✅ Got successful response from Edamam API");
                List<RecipeResponse> recipes = parseRecipeResponse(response.getBody());

                if (!recipes.isEmpty()) {
                    log.info("🍽️ Found {} recipes from Edamam API for '{}'", recipes.size(), query);
                    return recipes;
                } else {
                    log.warn("⚠️ Edamam API returned 0 recipes for '{}', using fallback", query);
                    return fallbackRecipeService.searchRecipes(query, mealType, calories, maxResults);
                }
            } else {
                log.error("❌ Edamam API returned status {}, using fallback", response.getStatusCode());
                return fallbackRecipeService.searchRecipes(query, mealType, calories, maxResults);
            }

        } catch (Exception e) {
            log.error("❌ Error calling Edamam API: {} - Using fallback recipes", e.getMessage());
            log.error("💡 Check if your Edamam API keys are valid: app_id={}, app_key={}***",
                appId, appKey != null && appKey.length() > 5 ? appKey.substring(0, 5) : "null");
            log.debug("Full stack trace:", e);
            return fallbackRecipeService.searchRecipes(query, mealType, calories, maxResults);
        }
    }

    /**
     * Get recipe by URI
     */
    public RecipeResponse getRecipeByUri(String recipeUri) {
        try {
            String url = UriComponentsBuilder.fromHttpUrl(baseUrl + "/" + recipeUri)
                    .queryParam("type", "public")
                    .queryParam("app_id", appId)
                    .queryParam("app_key", appKey)
                    .toUriString();

            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            List<RecipeResponse> recipes = parseRecipeResponse(response.getBody());

            return recipes.isEmpty() ? null : recipes.get(0);

        } catch (Exception e) {
            log.error("Error getting recipe by URI: {}", e.getMessage(), e);
            return null;
        }
    }

    private List<RecipeResponse> parseRecipeResponse(String jsonResponse) {
        List<RecipeResponse> recipes = new ArrayList<>();
        try {
            log.debug("Parsing recipe response JSON");
            JsonNode root = objectMapper.readTree(jsonResponse);

            if (!root.has("hits")) {
                log.warn("No 'hits' field in response. Response keys: {}", root.fieldNames());
                return recipes;
            }

            JsonNode hits = root.get("hits");
            log.info("Found hits array with {} elements", hits.size());

            if (hits != null && hits.isArray()) {
                for (JsonNode hit : hits) {
                    JsonNode recipe = hit.get("recipe");
                    if (recipe != null) {
                        RecipeResponse recipeResponse = RecipeResponse.builder()
                                .uri(recipe.has("uri") ? recipe.get("uri").asText() : null)
                                .label(recipe.has("label") ? recipe.get("label").asText() : null)
                                .image(recipe.has("image") ? recipe.get("image").asText() : null)
                                .source(recipe.has("source") ? recipe.get("source").asText() : null)
                                .url(recipe.has("url") ? recipe.get("url").asText() : null)
                                .servings(recipe.has("yield") ? recipe.get("yield").asInt() : null)
                                .calories(recipe.has("calories") ? recipe.get("calories").asDouble() : null)
                                .totalTime(recipe.has("totalTime") ? recipe.get("totalTime").asDouble() : null)
                                .dietLabels(parseArrayField(recipe, "dietLabels"))
                                .healthLabels(parseArrayField(recipe, "healthLabels"))
                                .ingredientLines(parseArrayField(recipe, "ingredientLines"))
                                .nutrition(parseNutrition(recipe))
                                .build();

                        recipes.add(recipeResponse);
                        log.debug("Added recipe: {}", recipeResponse.getLabel());
                    } else {
                        log.warn("Hit does not contain 'recipe' field");
                    }
                }
            }
            log.info("Successfully parsed {} recipes", recipes.size());
        } catch (Exception e) {
            log.error("Error parsing recipe response: {}", e.getMessage(), e);
        }
        return recipes;
    }

    private List<String> parseArrayField(JsonNode recipe, String fieldName) {
        List<String> values = new ArrayList<>();
        if (recipe.has(fieldName)) {
            JsonNode array = recipe.get(fieldName);
            if (array.isArray()) {
                array.forEach(node -> values.add(node.asText()));
            }
        }
        return values;
    }

    private RecipeResponse.NutritionInfo parseNutrition(JsonNode recipe) {
        if (!recipe.has("totalNutrients")) {
            return null;
        }

        JsonNode nutrients = recipe.get("totalNutrients");

        return RecipeResponse.NutritionInfo.builder()
                .calories(extractNutrient(nutrients, "ENERC_KCAL"))
                .protein(extractNutrient(nutrients, "PROCNT"))
                .fat(extractNutrient(nutrients, "FAT"))
                .carbs(extractNutrient(nutrients, "CHOCDF"))
                .fiber(extractNutrient(nutrients, "FIBTG"))
                .sugar(extractNutrient(nutrients, "SUGAR"))
                .build();
    }

    private Double extractNutrient(JsonNode nutrients, String code) {
        if (nutrients.has(code)) {
            JsonNode nutrient = nutrients.get(code);
            if (nutrient.has("quantity")) {
                return nutrient.get("quantity").asDouble();
            }
        }
        return null;
    }
}

