package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Réponse complète d'un scan de repas avec informations nutritionnelles détaillées
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealScanResponse {

    /**
     * Type de scan effectué: BARCODE, IMAGE
     */
    private String scanType;

    /**
     * Statut du scan: SUCCESS, PARTIAL, NOT_FOUND, ERROR
     */
    private String status;

    /**
     * Liste des aliments détectés
     */
    private List<DetectedItem> detectedItems;

    /**
     * Résumé nutritionnel total du repas
     */
    private NutritionSummary totalNutrition;

    /**
     * Analyse et conseils générés par l'IA
     */
    private AIAnalysis aiAnalysis;

    /**
     * Score global du repas (0-100)
     */
    private Integer mealScore;

    /**
     * Message d'erreur si applicable
     */
    private String errorMessage;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DetectedItem {
        private String name;
        private String brand; // Pour les produits scannés par code-barres
        private Double confidence; // 0-100%
        private Double quantityGrams;
        private String source; // OPEN_FOOD_FACTS, EDAMAM, AI_DETECTED
        private String barcode; // Si applicable
        private String imageUrl; // Image du produit si disponible
        private String nutriScore; // A, B, C, D, E
        private NutritionInfo nutrition;
        private List<String> ingredients; // Liste des ingrédients
        private List<String> allergens; // Allergènes détectés
        private Long matchedFoodId; // ID dans notre base si trouvé
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionInfo {
        private Double calories;
        private Double proteins;
        private Double carbs;
        private Double fats;
        private Double fiber;
        private Double sugars;
        private Double saturatedFat;
        private Double sodium;
        private Double cholesterol;
        private Double potassium;
        private Double calcium;
        private Double iron;
        private Double vitaminA;
        private Double vitaminC;
        private Double vitaminD;
        private Double vitaminB12;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionSummary {
        private Double totalCalories;
        private Double totalProteins;
        private Double totalCarbs;
        private Double totalFats;
        private Double totalFiber;
        private Double totalSugars;

        // Pourcentages des apports journaliers recommandés (basé sur 2000 kcal)
        private Double caloriesPercentDV;
        private Double proteinsPercentDV;
        private Double carbsPercentDV;
        private Double fatsPercentDV;
        private Double fiberPercentDV;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AIAnalysis {
        private String summary; // Résumé court du repas
        private String healthAnalysis; // Analyse santé détaillée
        private List<String> positivePoints; // Points positifs du repas
        private List<String> negativePoints; // Points à améliorer
        private List<String> recommendations; // Recommandations personnalisées
        private String goalCompatibility; // Compatibilité avec les objectifs de l'utilisateur
        private Double overallScore; // Score global 0-100
    }
}

