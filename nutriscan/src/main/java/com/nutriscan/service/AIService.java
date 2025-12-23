package com.nutriscan.service;

import com.nutriscan.dto.response.AIExplanationResponse;
import com.nutriscan.dto.response.DailySummaryResponse;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.dto.response.OffProductResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.*;

@Service
@Slf4j
@Transactional
public class AIService {

    private final OpenFoodFactsService openFoodFactsService;
    private final MealService mealService;
    private final GoalsService goalsService;
    private final RestTemplate restTemplate;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String geminiModel;

    public AIService(OpenFoodFactsService openFoodFactsService, MealService mealService, GoalsService goalsService,
                     RestTemplate restTemplate) {
        this.openFoodFactsService = openFoodFactsService;
        this.mealService = mealService;
        this.goalsService = goalsService;
        this.restTemplate = restTemplate;
    }

    public OffProductResponse scanBarcodeAndAnalyze(String barcode) {
        OffProductResponse product = openFoodFactsService.getProductByBarcode(barcode);
        return product;
    }

    public AIExplanationResponse generateDailyExplanation(Long userId, LocalDate date) {
        log.info("Generating AI explanation for user {} on date {}", userId, date);

        DailySummaryResponse summary = mealService.getDailySummary(userId, date);
        GoalsResponse goals = goalsService.getGoalsForUser(userId);

        if (summary == null || summary.getTotalCalories() == null || summary.getTotalCalories() == 0) {
            return AIExplanationResponse.builder()
                    .explanation("Aucun repas enregistre pour cette journee.")
                    .tips("Commencez votre journee en prenant un bon petit-dejeuner riche en proteines et en fibres.")
                    .nutritionInsight("Une alimentation reguliere est cle pour atteindre vos objectifs.")
                    .isProductAnalysis(false)
                    .build();
        }

        try {
            if (!isGeminiConfigured()) {
                log.warn("Gemini not configured, using fallback response");
                return buildFallbackDailyResponse(summary, goals);
            }

            String prompt = buildDailyAnalysisPrompt(summary, goals, date);
            String geminiResponse = callGeminiAPI(prompt);

            if (geminiResponse != null && !geminiResponse.isEmpty()) {
                return parseGeminiDailyResponse(geminiResponse);
            }

            return buildFallbackDailyResponse(summary, goals);
        } catch (Exception e) {
            log.error("Erreur lors de l'appel a Gemini", e);
            return buildFallbackDailyResponse(summary, goals);
        }
    }

    public AIExplanationResponse generateProductExplanation(String barcode, Long userId) {
        log.info("Generating product explanation for barcode: {}", barcode);

        OffProductResponse product = openFoodFactsService.getProductByBarcode(barcode);
        GoalsResponse goals = goalsService.getGoalsForUser(userId);

        if (product == null || product.getProduct() == null) {
            return AIExplanationResponse.builder()
                    .explanation("Produit non trouve.")
                    .isProductAnalysis(true)
                    .build();
        }

        try {
            if (!isGeminiConfigured()) {
                log.warn("Gemini not configured, using fallback response");
                return buildFallbackProductResponse(product);
            }

            String prompt = buildProductAnalysisPrompt(product, goals);
            String geminiResponse = callGeminiAPI(prompt);

            if (geminiResponse != null && !geminiResponse.isEmpty()) {
                return parseGeminiProductResponse(geminiResponse, product);
            }

            return buildFallbackProductResponse(product);
        } catch (Exception e) {
            log.error("Erreur lors de l'appel a Gemini pour le produit", e);
            return buildFallbackProductResponse(product);
        }
    }

    private boolean isGeminiConfigured() {
        return geminiApiKey != null && !geminiApiKey.isEmpty() && !geminiApiKey.equals("your-gemini-api-key-here");
    }

    private String callGeminiAPI(String prompt) {
        try {
            String url = "https://generativelanguage.googleapis.com/v1beta/models/" + geminiModel + ":generateContent?key=" + geminiApiKey;

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

            log.debug("Calling Gemini API...");
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            if (response.getBody() != null) {
                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.getBody().get("candidates");
                if (candidates != null && !candidates.isEmpty()) {
                    Map<String, Object> candidate = candidates.get(0);
                    Map<String, Object> contentResp = (Map<String, Object>) candidate.get("content");
                    if (contentResp != null) {
                        List<Map<String, Object>> partsResp = (List<Map<String, Object>>) contentResp.get("parts");
                        if (partsResp != null && !partsResp.isEmpty()) {
                            String text = (String) partsResp.get(0).get("text");
                            log.info("Gemini response received ({} chars)", text.length());
                            return text;
                        }
                    }
                }
            }

            return null;
        } catch (Exception e) {
            log.error("Error calling Gemini API: {}", e.getMessage());
            return null;
        }
    }

    private String buildDailyAnalysisPrompt(DailySummaryResponse summary, GoalsResponse goals, LocalDate date) {
        return String.format(
                "Tu es un coach nutritionnel experimente. Analyse le resume nutritionnel du jour et fournis des conseils personnalises EN FRANCAIS.\n\n" +
                "Date: %s\n" +
                "Calories consommees: %.1f / Objectif: %.1f\n" +
                "Proteines: %.1f g / Objectif: %.1f g\n" +
                "Glucides: %.1f g / Objectif: %.1f g\n" +
                "Lipides: %.1f g / Objectif: %.1f g\n\n" +
                "Reponds UNIQUEMENT en format JSON avec les cles: explanation, tips, nutritionInsight\n" +
                "Exemple: {\"explanation\": \"...\", \"tips\": \"...\", \"nutritionInsight\": \"...\"}",
                date,
                summary.getTotalCalories(), goals.getTargetCalories(),
                summary.getTotalProtein(), goals.getProteinGr(),
                summary.getTotalCarbs(), goals.getCarbsGr(),
                summary.getTotalFat(), goals.getFatGr()
        );
    }

    private String buildProductAnalysisPrompt(OffProductResponse product, GoalsResponse goals) {
        OffProductResponse.OffProduct prod = product.getProduct();
        Double calories = extractCaloriesFromNutriments(prod.getNutriments());
        Double protein = extractProteinFromNutriments(prod.getNutriments());

        return String.format(
                "Tu es un coach nutritionnel. Analyse ce produit alimentaire et dis si c'est bon pour quelqu'un dont l'objectif est %s. Reponds EN FRANCAIS.\n\n" +
                "Produit: %s\n" +
                "Calories: %.1f\n" +
                "Proteines: %.1f g\n" +
                "NutriScore: %s\n\n" +
                "Reponds UNIQUEMENT en format JSON avec les cles: explanation, productAdvice, tips\n" +
                "Exemple: {\"explanation\": \"...\", \"productAdvice\": \"...\", \"tips\": \"...\"}",
                goals.getGoalType(),
                prod.getProductName(),
                calories != null ? calories : 0,
                protein != null ? protein : 0,
                prod.getNutritionGrades() != null ? prod.getNutritionGrades() : "N/A"
        );
    }

    private Double extractCaloriesFromNutriments(java.util.Map<String, Object> nutriments) {
        if (nutriments == null) return null;
        Object cal = nutriments.get("energy-kcal_100g");
        if (cal instanceof Number) {
            return ((Number) cal).doubleValue();
        }
        return null;
    }

    private Double extractProteinFromNutriments(java.util.Map<String, Object> nutriments) {
        if (nutriments == null) return null;
        Object prot = nutriments.get("proteins_100g");
        if (prot instanceof Number) {
            return ((Number) prot).doubleValue();
        }
        return null;
    }

    private AIExplanationResponse parseGeminiDailyResponse(String geminiResponse) {
        try {
            // Nettoyer la reponse
            String cleanResponse = geminiResponse
                    .replaceAll("```json\\s*", "")
                    .replaceAll("```\\s*", "")
                    .trim();

            if (cleanResponse.contains("{")) {
                int start = cleanResponse.indexOf("{");
                int end = cleanResponse.lastIndexOf("}") + 1;
                String jsonPart = cleanResponse.substring(start, end);

                String explanation = extractJsonValue(jsonPart, "explanation");
                String tips = extractJsonValue(jsonPart, "tips");
                String insight = extractJsonValue(jsonPart, "nutritionInsight");

                return AIExplanationResponse.builder()
                        .explanation(explanation.isEmpty() ? geminiResponse : explanation)
                        .tips(tips.isEmpty() ? "Continuez vos efforts!" : tips)
                        .nutritionInsight(insight.isEmpty() ? "Suivez regulierement vos repas." : insight)
                        .isProductAnalysis(false)
                        .build();
            }
        } catch (Exception e) {
            log.warn("Erreur lors du parsing de la reponse Gemini", e);
        }

        return AIExplanationResponse.builder()
                .explanation(geminiResponse)
                .tips("Consultez l'analyse complete ci-dessus.")
                .nutritionInsight("Continuez a suivre vos repas regulierement.")
                .isProductAnalysis(false)
                .build();
    }

    private AIExplanationResponse parseGeminiProductResponse(String geminiResponse, OffProductResponse product) {
        try {
            String cleanResponse = geminiResponse
                    .replaceAll("```json\\s*", "")
                    .replaceAll("```\\s*", "")
                    .trim();

            if (cleanResponse.contains("{")) {
                int start = cleanResponse.indexOf("{");
                int end = cleanResponse.lastIndexOf("}") + 1;
                String jsonPart = cleanResponse.substring(start, end);

                String explanation = extractJsonValue(jsonPart, "explanation");
                String advice = extractJsonValue(jsonPart, "productAdvice");
                String tips = extractJsonValue(jsonPart, "tips");

                return AIExplanationResponse.builder()
                        .explanation(explanation.isEmpty() ? geminiResponse : explanation)
                        .productName(product.getProduct().getProductName())
                        .productAdvice(advice.isEmpty() ? "Voir l'analyse." : advice)
                        .tips(tips.isEmpty() ? "Verifiez les valeurs nutritionnelles." : tips)
                        .isProductAnalysis(true)
                        .build();
            }
        } catch (Exception e) {
            log.warn("Erreur lors du parsing de la reponse produit", e);
        }

        return AIExplanationResponse.builder()
                .explanation(geminiResponse)
                .productName(product.getProduct().getProductName())
                .productAdvice("Voir l'analyse complete.")
                .isProductAnalysis(true)
                .build();
    }

    private String extractJsonValue(String json, String key) {
        String searchKey = "\"" + key + "\"";
        int startIdx = json.indexOf(searchKey);
        if (startIdx == -1) return "";

        int colonIdx = json.indexOf(":", startIdx);
        int quoteIdx = json.indexOf("\"", colonIdx);
        int endIdx = json.indexOf("\"", quoteIdx + 1);

        if (endIdx > quoteIdx) {
            return json.substring(quoteIdx + 1, endIdx);
        }
        return "";
    }

    private AIExplanationResponse buildFallbackDailyResponse(DailySummaryResponse summary, GoalsResponse goals) {
        StringBuilder explanation = new StringBuilder();
        double caloriePercent = (summary.getTotalCalories() / goals.getTargetCalories()) * 100;

        if (caloriePercent < 80) {
            explanation.append("Vous n'avez pas atteint votre objectif calorique aujourd'hui (")
                    .append(String.format("%.0f%%", caloriePercent))
                    .append("). ");
        } else if (caloriePercent > 110) {
            explanation.append("Vous avez depasse votre objectif calorique (")
                    .append(String.format("%.0f%%", caloriePercent))
                    .append("). ");
        } else {
            explanation.append("Excellent! Vous etes dans votre objectif calorique. ");
        }

        String tips = "Essayez d'equilibrer vos macronutriments pour de meilleurs resultats.";
        String insight = String.format("Calories: %.0f/%.0f | Proteines: %.0fg | Glucides: %.0fg | Lipides: %.0fg",
                summary.getTotalCalories(), goals.getTargetCalories(),
                summary.getTotalProtein(), summary.getTotalCarbs(), summary.getTotalFat());

        return AIExplanationResponse.builder()
                .explanation(explanation.toString())
                .tips(tips)
                .nutritionInsight(insight)
                .isProductAnalysis(false)
                .build();
    }

    private AIExplanationResponse buildFallbackProductResponse(OffProductResponse product) {
        OffProductResponse.OffProduct prod = product.getProduct();
        String name = prod.getProductName() != null ? prod.getProductName() : "Produit";
        String nutriscore = prod.getNutritionGrades() != null ? prod.getNutritionGrades().toUpperCase() : "N/A";

        String explanation;
        if ("A".equals(nutriscore) || "B".equals(nutriscore)) {
            explanation = String.format("%s a un bon NutriScore (%s). C'est un choix sain!", name, nutriscore);
        } else if ("D".equals(nutriscore) || "E".equals(nutriscore)) {
            explanation = String.format("%s a un NutriScore %s. A consommer avec moderation.", name, nutriscore);
        } else {
            explanation = String.format("Analyse de %s. NutriScore: %s", name, nutriscore);
        }

        return AIExplanationResponse.builder()
                .explanation(explanation)
                .productName(name)
                .productAdvice("Verifiez les informations nutritionnelles sur l'emballage.")
                .tips("Comparez avec des produits similaires pour faire le meilleur choix.")
                .isProductAnalysis(true)
                .build();
    }
}
