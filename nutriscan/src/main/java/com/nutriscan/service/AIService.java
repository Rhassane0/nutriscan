package com.nutriscan.service;

import com.nutriscan.dto.response.AIExplanationResponse;
import com.nutriscan.dto.response.DailySummaryResponse;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.dto.response.OffProductResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Method;
import java.time.LocalDate;

@Service
@Slf4j
@Transactional
public class AIService {

    private final OpenFoodFactsService openFoodFactsService;
    private final MealService mealService;
    private final GoalsService goalsService;
    private final Object generativeModel;

    public AIService(OpenFoodFactsService openFoodFactsService, MealService mealService, GoalsService goalsService,
                     @Qualifier("generativeModel") @Nullable Object generativeModel) {
        this.openFoodFactsService = openFoodFactsService;
        this.mealService = mealService;
        this.goalsService = goalsService;
        this.generativeModel = generativeModel;
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
                    .explanation("Aucun repas enregistré pour cette journée.")
                    .tips("Commencez votre journée en prenant un bon petit-déjeuner riche en protéines et en fibres.")
                    .nutritionInsight("Une alimentation régulière est clé pour atteindre vos objectifs.")
                    .isProductAnalysis(false)
                    .build();
        }

        try {
            if (generativeModel == null) {
                log.warn("Gemini not configured, using fallback response");
                return buildFallbackDailyResponse(summary, goals);
            }

            String prompt = buildDailyAnalysisPrompt(summary, goals, date);
            String geminiResponse = callGemini(prompt);
            return parseGeminiDailyResponse(geminiResponse);
        } catch (Exception e) {
            log.error("Erreur lors de l'appel à Gemini", e);
            return buildFallbackDailyResponse(summary, goals);
        }
    }

    public AIExplanationResponse generateProductExplanation(String barcode, Long userId) {
        log.info("Generating product explanation for barcode: {}", barcode);

        OffProductResponse product = openFoodFactsService.getProductByBarcode(barcode);
        GoalsResponse goals = goalsService.getGoalsForUser(userId);

        if (product == null || product.getProduct() == null) {
            return AIExplanationResponse.builder()
                    .explanation("Produit non trouvé.")
                    .isProductAnalysis(true)
                    .build();
        }

        try {
            if (generativeModel == null) {
                log.warn("Gemini not configured, using fallback response");
                return buildFallbackProductResponse(product);
            }

            String prompt = buildProductAnalysisPrompt(product, goals);
            String geminiResponse = callGemini(prompt);
            return parseGeminiProductResponse(geminiResponse, product);
        } catch (Exception e) {
            log.error("Erreur lors de l'appel à Gemini pour le produit", e);
            return buildFallbackProductResponse(product);
        }
    }

    private String callGemini(String prompt) {
        try {
            if (generativeModel == null) {
                throw new RuntimeException("Gemini model not available");
            }

            log.debug("Calling Gemini with prompt");
            Method generateContentMethod = generativeModel.getClass()
                    .getMethod("generateContent", String.class);
            Object response = generateContentMethod.invoke(generativeModel, prompt);

            Method getTextMethod = response.getClass().getMethod("getText");
            String result = (String) getTextMethod.invoke(response);

            log.debug("Gemini response received");
            return result;
        } catch (Exception e) {
            log.error("Erreur lors de l'appel à Gemini: {}", e.getMessage());
            throw new RuntimeException("Impossible de contacter le service IA", e);
        }
    }

    private String buildDailyAnalysisPrompt(DailySummaryResponse summary, GoalsResponse goals, LocalDate date) {
        return String.format(
                "Tu es un coach nutritionnel expérimenté. Analyse le résumé nutritionnel du jour et fournis des conseils personnalisés EN FRANÇAIS.\n\n" +
                "Date: %s\n" +
                "Calories consommées: %.1f / Objectif: %.1f\n" +
                "Protéines: %.1f g / Objectif: %.1f g\n" +
                "Glucides: %.1f g / Objectif: %.1f g\n" +
                "Lipides: %.1f g / Objectif: %.1f g\n\n" +
                "Répondre en format JSON avec les clés: explanation, tips, nutritionInsight",
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
                "Tu es un coach nutritionnel. Analyse ce produit alimentaire et dis si c'est bon pour quelqu'un dont l'objectif est %s. Répondre EN FRANÇAIS.\n\n" +
                "Produit: %s\n" +
                "Calories: %.1f\n" +
                "Protéines: %.1f g\n" +
                "NutriScore: %s\n\n" +
                "Répondre en format JSON avec les clés: explanation, productAdvice, tips",
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
            if (geminiResponse.contains("{")) {
                int start = geminiResponse.indexOf("{");
                int end = geminiResponse.lastIndexOf("}") + 1;
                String jsonPart = geminiResponse.substring(start, end);

                String explanation = extractJsonValue(jsonPart, "explanation");
                String tips = extractJsonValue(jsonPart, "tips");
                String insight = extractJsonValue(jsonPart, "nutritionInsight");

                return AIExplanationResponse.builder()
                        .explanation(explanation)
                        .tips(tips)
                        .nutritionInsight(insight)
                        .isProductAnalysis(false)
                        .build();
            }
        } catch (Exception e) {
            log.warn("Erreur lors du parsing de la réponse Gemini", e);
        }

        return AIExplanationResponse.builder()
                .explanation(geminiResponse)
                .tips("Consultez l'analyse complète ci-dessus.")
                .nutritionInsight("Continuez à suivre vos repas régulièrement.")
                .isProductAnalysis(false)
                .build();
    }

    private AIExplanationResponse parseGeminiProductResponse(String geminiResponse, OffProductResponse product) {
        try {
            if (geminiResponse.contains("{")) {
                int start = geminiResponse.indexOf("{");
                int end = geminiResponse.lastIndexOf("}") + 1;
                String jsonPart = geminiResponse.substring(start, end);

                String explanation = extractJsonValue(jsonPart, "explanation");
                String advice = extractJsonValue(jsonPart, "productAdvice");
                String tips = extractJsonValue(jsonPart, "tips");

                return AIExplanationResponse.builder()
                        .explanation(explanation)
                        .productName(product.getProduct().getProductName())
                        .productAdvice(advice)
                        .tips(tips)
                        .isProductAnalysis(true)
                        .build();
            }
        } catch (Exception e) {
            log.warn("Erreur lors du parsing de la réponse produit", e);
        }

        return AIExplanationResponse.builder()
                .explanation(geminiResponse)
                .productName(product.getProduct().getProductName())
                .productAdvice("Voir l'analyse complète.")
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

        double calorieRatio = summary.getTotalCalories() / goals.getTargetCalories();
        double proteinRatio = summary.getTotalProtein() / goals.getProteinGr();

        if (calorieRatio >= 0.95 && calorieRatio <= 1.05) {
            explanation.append("Excellent ! Vos calories sont parfaitement alignées avec votre objectif. ");
        } else if (calorieRatio < 0.95) {
            explanation.append("Vous êtes légèrement en-dessous de votre objectif calorique. ");
        } else {
            explanation.append("Vous avez dépassé votre objectif calorique aujourd'hui. ");
        }

        if (proteinRatio >= 0.9 && proteinRatio <= 1.1) {
            explanation.append("Vos protéines sont bien distribuées. ");
        }

        return AIExplanationResponse.builder()
                .explanation(explanation.toString())
                .tips("Continuez à suivre vos repas régulièrement pour des meilleurs résultats.")
                .nutritionInsight("La constance est la clé du succès nutritionnel.")
                .isProductAnalysis(false)
                .build();
    }

    private AIExplanationResponse buildFallbackProductResponse(OffProductResponse product) {
        StringBuilder advice = new StringBuilder();
        OffProductResponse.OffProduct prod = product.getProduct();

        Double calories = extractCaloriesFromNutriments(prod.getNutriments());
        if (calories != null) {
            if (calories > 300) {
                advice.append("Ce produit est assez calorique. À consommer avec modération. ");
            } else if (calories < 50) {
                advice.append("Ce produit est très léger, bon pour les collations. ");
            }
        }

        if (prod.getNutritionGrades() != null) {
            if (prod.getNutritionGrades().equalsIgnoreCase("A")) {
                advice.append("Excellent score nutritionnel (A).");
            } else if (prod.getNutritionGrades().equalsIgnoreCase("E")) {
                advice.append("À éviter régulièrement, score nutritionnel faible.");
            }
        }

        return AIExplanationResponse.builder()
                .explanation("Analyse du produit disponible ci-dessous.")
                .productName(prod.getProductName())
                .productAdvice(advice.toString())
                .isProductAnalysis(true)
                .tips("Intégrez ce produit à votre alimentation de manière réfléchie.")
                .build();
    }
}


