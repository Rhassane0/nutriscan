package com.nutriscan.service;

import com.nutriscan.config.NutritionApiConfig;
import com.nutriscan.dto.response.FoodInfoResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class NutritionDatabaseService {

    private final RestTemplate restTemplate;
    private final NutritionApiConfig nutritionApiConfig;

    /**
     * Search for natural foods using Edamam Nutrition API
     */
    public List<FoodInfoResponse> searchFoods(String query, int limit) {
        List<FoodInfoResponse> results = new ArrayList<>();

        try {
            // Edamam API format: /api/food-database/v2/parser?query=...&app_id=...&app_key=...
            String url = String.format(
                    "%s/food-database/v2/parser?query=%s&type=generic&pageSize=%d&app_id=%s&app_key=%s",
                    nutritionApiConfig.getBaseUrl(),
                    query.replace(" ", "%%20"),
                    limit,
                    nutritionApiConfig.getAppId(),
                    nutritionApiConfig.getAppKey()
            );

            log.info("Searching for natural foods: {} at URL: {}", query, url);

            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> response = restTemplate.getForObject(url, Map.class);

                if (response == null) {
                    log.warn("Null response from Edamam API for query: {}", query);
                    return getMockFoodResults(query);
                }

                log.debug("API Response keys: {}", response.keySet());

                // Check for error in response
                if (response.containsKey("error") || response.containsKey("message")) {
                    log.error("API Error: {}", response.get("message") != null ? response.get("message") : response.get("error"));
                    return getMockFoodResults(query);
                }

                // Edamam returns "hints" array
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> hints = (List<Map<String, Object>>) response.get("hints");

                if (hints == null || hints.isEmpty()) {
                    log.warn("No food hints found for query: {}", query);
                    return getMockFoodResults(query);
                }

                log.info("Found {} food hints for query: {}", hints.size(), query);

                // Convert each hint from API format to FoodInfoResponse
                for (Map<String, Object> hint : hints) {
                    try {
                        FoodInfoResponse foodInfo = convertEdamamResponseToFoodInfo(hint);
                        if (foodInfo != null && foodInfo.getName() != null) {
                            results.add(foodInfo);
                            log.debug("Successfully added food to results: {}", foodInfo.getName());
                        }
                    } catch (Exception e) {
                        log.warn("Could not process food hint: {}", e.getMessage());
                    }
                }

                log.info("Returning {} food results for query: {}", results.size(), query);

            } catch (org.springframework.web.client.HttpClientErrorException e) {
                log.error("HTTP Error calling Edamam API: {} - {}", e.getStatusCode(), e.getMessage());
                return getMockFoodResults(query);
            } catch (org.springframework.web.client.HttpServerErrorException e) {
                log.error("API Server Error: {} - {}", e.getStatusCode(), e.getMessage());
                return getMockFoodResults(query);
            }

        } catch (Exception e) {
            log.error("Failed to search foods: {}", e.getMessage(), e);
            return getMockFoodResults(query);
        }

        return results;
    }

    /**
     * Search for a single specific food by name
     */
    public FoodInfoResponse searchFoodByName(String foodName) {
        try {
            String url = String.format(
                    "%s/food-database/v2/parser?query=%s&type=generic&limit=1&app_id=%s&app_key=%s",
                    nutritionApiConfig.getBaseUrl(),
                    foodName.replace(" ", "%%20"),
                    nutritionApiConfig.getAppId(),
                    nutritionApiConfig.getAppKey()
            );

            log.info("Searching for food by name: {}", foodName);

            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response == null) {
                log.warn("Null response from API for food: {}", foodName);
                return null;
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> hints = (List<Map<String, Object>>) response.get("hints");

            if (hints == null || hints.isEmpty()) {
                log.warn("Empty hints for food: {}", foodName);
                return null;
            }

            log.info("Found {} hints for food: {}", hints.size(), foodName);

            Map<String, Object> hint = hints.get(0);
            return convertEdamamResponseToFoodInfo(hint);

        } catch (Exception e) {
            log.error("Failed to search food from Edamam API: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch food from Edamam API: " + e.getMessage(), e);
        }
    }

    /**
     * Convert Edamam API response format to FoodInfoResponse
     */
    private FoodInfoResponse convertEdamamResponseToFoodInfo(Map<String, Object> hint) {
        log.debug("Converting Edamam food hint. Available keys: {}", hint.keySet());

        @SuppressWarnings("unchecked")
        Map<String, Object> foodData = (Map<String, Object>) hint.get("food");

        if (foodData == null) {
            log.warn("No 'food' object in hint");
            return null;
        }

        String name = (String) foodData.get("label");
        String imageUrl = (String) foodData.get("image");

        Double calories = null;
        Double protein = null;
        Double carbs = null;
        Double fat = null;

        // Extract nutrition data from Edamam response
        @SuppressWarnings("unchecked")
        Map<String, Object> nutrients = (Map<String, Object>) foodData.get("nutrients");

        if (nutrients != null) {
            log.debug("Found nutrients with keys: {}", nutrients.keySet());

            // Edamam uses ENERC_KCAL for calories, PROCNT for protein, CHOCDF for carbs, FAT for fat
            Object calObj = nutrients.get("ENERC_KCAL");
            if (calObj instanceof Number) {
                calories = ((Number) calObj).doubleValue();
            }

            Object proteinObj = nutrients.get("PROCNT");
            if (proteinObj instanceof Number) {
                protein = ((Number) proteinObj).doubleValue();
            }

            Object carbsObj = nutrients.get("CHOCDF");
            if (carbsObj instanceof Number) {
                carbs = ((Number) carbsObj).doubleValue();
            }

            Object fatObj = nutrients.get("FAT");
            if (fatObj instanceof Number) {
                fat = ((Number) fatObj).doubleValue();
            }
        } else {
            log.warn("No nutrients data in Edamam response");
        }

        FoodInfoResponse result = FoodInfoResponse.builder()
                .name(name)
                .imageUrl(imageUrl)
                .calories(calories)
                .protein(protein)
                .carbs(carbs)
                .fat(fat)
                .nutriScore(null)
                .source("EDAMAM_NATURAL_FOODS")
                .build();

        log.debug("Converted to FoodInfoResponse: name={}, cal={}, protein={}, carbs={}, fat={}",
                  name, calories, protein, carbs, fat);

        return result;
    }

    /**
     * Return mock food data for testing/development when API fails
     */
    private List<FoodInfoResponse> getMockFoodResults(String query) {
        log.info("Returning mock data for query: {}", query);
        List<FoodInfoResponse> mockResults = new ArrayList<>();

        if (query.toLowerCase().contains("apple")) {
            mockResults.add(FoodInfoResponse.builder()
                    .name("Apple, raw")
                    .imageUrl(null)
                    .calories(52.0)
                    .protein(0.3)
                    .carbs(13.8)
                    .fat(0.2)
                    .nutriScore("A")
                    .source("EDAMAM_NATURAL_FOODS_MOCK")
                    .build());
        } else if (query.toLowerCase().contains("chicken")) {
            mockResults.add(FoodInfoResponse.builder()
                    .name("Chicken, breast, raw")
                    .imageUrl(null)
                    .calories(165.0)
                    .protein(31.0)
                    .carbs(0.0)
                    .fat(3.6)
                    .nutriScore("A")
                    .source("EDAMAM_NATURAL_FOODS_MOCK")
                    .build());
        } else if (query.toLowerCase().contains("banana")) {
            mockResults.add(FoodInfoResponse.builder()
                    .name("Banana, raw")
                    .imageUrl(null)
                    .calories(89.0)
                    .protein(1.1)
                    .carbs(23.0)
                    .fat(0.3)
                    .nutriScore("A")
                    .source("EDAMAM_NATURAL_FOODS_MOCK")
                    .build());
        } else {
            mockResults.add(FoodInfoResponse.builder()
                    .name(query)
                    .imageUrl(null)
                    .calories(50.0)
                    .protein(5.0)
                    .carbs(10.0)
                    .fat(1.0)
                    .nutriScore("B")
                    .source("EDAMAM_NATURAL_FOODS_MOCK")
                    .build());
        }

        return mockResults;
    }
}

