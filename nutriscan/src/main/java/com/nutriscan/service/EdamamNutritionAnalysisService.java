package com.nutriscan.service;

import com.nutriscan.model.Meal;
import com.nutriscan.model.MealItem;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * Service pour l'intégration avec l'API Nutrition Analysis d'Edamam.
 * Cette API fournit une analyse nutritionnelle détaillée d'un repas composé d'ingrédients.
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class EdamamNutritionAnalysisService {

    private final RestTemplate restTemplate;

    @Value("${edamam.nutrition-analysis.app-id}")
    private String appId;

    @Value("${edamam.nutrition-analysis.app-key}")
    private String appKey;

    @Value("${edamam.nutrition-analysis.base-url}")
    private String baseUrl;

    /**
     * Analyse un repas en détail via l'API Edamam
     * Retourne les nutriments détaillés : calories, protéines, glucides, lipides, fibres, sucres, etc.
     */
    public EdamamMealAnalysisDTO analyzeMeal(Meal meal) {
        try {
            Map<String, Object> requestBody = buildAnalysisRequest(meal);

            // Construire l'URL avec les paramètres d'authentification
            String url = String.format("%s?app_id=%s&app_key=%s", baseUrl, appId, appKey);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            EdamamNutritionAnalysisResponse response = restTemplate.postForObject(
                    url,
                    entity,
                    EdamamNutritionAnalysisResponse.class
            );

            return mapToMealAnalysisDTO(response, meal);

        } catch (Exception e) {
            log.error("Erreur lors de l'analyse du repas via Edamam: {}", e.getMessage());
            // Retourner une analyse basique en cas d'erreur (fallback)
            return buildFallbackAnalysis(meal);
        }
    }

    /**
     * Construit la requête pour l'API Nutrition Analysis
     * Convertit les items du repas en ingrédients avec quantités
     */
    private Map<String, Object> buildAnalysisRequest(Meal meal) {
        Map<String, Object> request = new HashMap<>();

        // Titre descriptif du repas
        String title = String.format("Analyse - %s (%s)",
            meal.getMealType(),
            meal.getDate());
        request.put("title", title);

        // Convertir les items du repas en liste d'ingrédients
        List<String> ingredients = new ArrayList<>();
        for (MealItem item : meal.getItems()) {
            String ingredient = formatIngredient(item);
            if (ingredient != null) {
                ingredients.add(ingredient);
            }
        }

        request.put("ingr", ingredients);
        return request;
    }

    /**
     * Formate un item du repas en chaîne d'ingrédient pour l'API Edamam
     * Format: "quantité unité aliment"
     * Exemple: "100 g apple raw"
     */
    private String formatIngredient(MealItem item) {
        if (item == null || item.getFoodName() == null) {
            return null;
        }

        double quantity = item.getQuantity() != null ? item.getQuantity() : 100;
        String unit = item.getServingUnit() != null ? item.getServingUnit() : "g";
        String foodName = item.getFoodName().trim();

        return String.format("%.0f %s %s", quantity, unit, foodName);
    }

    /**
     * Mappe la réponse Edamam à notre DTO interne
     */
    private EdamamMealAnalysisDTO mapToMealAnalysisDTO(EdamamNutritionAnalysisResponse response, Meal meal) {
        EdamamMealAnalysisDTO dto = new EdamamMealAnalysisDTO();

        dto.setMealId(meal.getId());
        dto.setMealType(meal.getMealType());
        dto.setDate(meal.getDate());

        if (response != null && response.getTotalNutrients() != null) {
            // Extraire les nutriments principaux
            dto.setTotalCalories(extractNutrient(response.getTotalNutrients(), "ENERC_KCAL"));
            dto.setTotalProtein(extractNutrient(response.getTotalNutrients(), "PROCNT"));
            dto.setTotalFat(extractNutrient(response.getTotalNutrients(), "FAT"));
            dto.setTotalCarbs(extractNutrient(response.getTotalNutrients(), "CHOCDF"));

            // Nutriments détaillés
            dto.setFiber(extractNutrient(response.getTotalNutrients(), "FIBTG"));
            dto.setSugar(extractNutrient(response.getTotalNutrients(), "SUGAR"));
            dto.setSaturatedFat(extractNutrient(response.getTotalNutrients(), "FASAT"));
            dto.setCholesterol(extractNutrient(response.getTotalNutrients(), "CHOLE"));
            dto.setSodium(extractNutrient(response.getTotalNutrients(), "NA"));

            // Vitamines et minéraux
            dto.setCalcium(extractNutrient(response.getTotalNutrients(), "CA"));
            dto.setIron(extractNutrient(response.getTotalNutrients(), "FE"));
            dto.setMagnesium(extractNutrient(response.getTotalNutrients(), "MG"));
            dto.setPotassium(extractNutrient(response.getTotalNutrients(), "K"));
        }

        // Étiquettes de santé et régime
        if (response != null) {
            dto.setHealthLabels(response.getHealthLabels());
            dto.setDietLabels(response.getDietLabels());
        }

        // Calculer les scores
        dto.setNutritionalScore(calculateNutritionalScore(dto));
        dto.setRecommendations(generateRecommendations(dto));

        return dto;
    }

    /**
     * Extrait une valeur de nutriment d'une map
     */
    private Double extractNutrient(Map<String, NutrientInfo> nutrients, String key) {
        if (nutrients == null || !nutrients.containsKey(key)) {
            return 0.0;
        }
        NutrientInfo info = nutrients.get(key);
        return info != null ? info.getQuantity() : 0.0;
    }

    /**
     * Calcule un score nutritionnel basé sur les nutriments analysés
     */
    private Double calculateNutritionalScore(EdamamMealAnalysisDTO analysis) {
        double score = 100.0;

        // Déductions pour les nutriments excessifs
        if (analysis.getSugar() != null && analysis.getSugar() > 50) {
            score -= 15; // Sucre trop élevé
        } else if (analysis.getSugar() != null && analysis.getSugar() > 30) {
            score -= 8;
        }

        if (analysis.getSaturatedFat() != null && analysis.getSaturatedFat() > 20) {
            score -= 15; // Graisses saturées trop élevées
        } else if (analysis.getSaturatedFat() != null && analysis.getSaturatedFat() > 10) {
            score -= 8;
        }

        if (analysis.getSodium() != null && analysis.getSodium() > 2000) {
            score -= 10; // Sodium trop élevé
        }

        // Bonus pour les nutriments bénéfiques
        if (analysis.getFiber() != null && analysis.getFiber() > 5) {
            score += 10; // Fibres suffisantes
        }

        if (analysis.getTotalProtein() != null && analysis.getTotalProtein() > 20) {
            score += 10; // Protéines suffisantes
        }

        // Bonus si équilibré
        if (analysis.getTotalProtein() != null && analysis.getTotalFat() != null && analysis.getTotalCarbs() != null) {
            double protein = analysis.getTotalProtein();
            double fat = analysis.getTotalFat();
            double carbs = analysis.getTotalCarbs();

            // Approximativement 30% protéines, 35% fats, 35% carbs est bon
            if (protein > 15 && protein < 35 && fat > 20 && fat < 40 && carbs > 30 && carbs < 50) {
                score += 5;
            }
        }

        return Math.max(0, Math.min(100, score));
    }

    /**
     * Génère des recommandations basées sur l'analyse nutritionnelle
     */
    private List<String> generateRecommendations(EdamamMealAnalysisDTO analysis) {
        List<String> recommendations = new ArrayList<>();

        if (analysis.getSugar() != null && analysis.getSugar() > 40) {
            recommendations.add("⚠️ Teneur en sucre élevée. Essayez de réduire les aliments sucrés ou les sodas.");
        }

        if (analysis.getFiber() != null && analysis.getFiber() < 3) {
            recommendations.add("📌 Fibres insuffisantes. Ajoutez des légumes, fruits ou grains entiers.");
        }

        if (analysis.getTotalProtein() != null && analysis.getTotalProtein() < 10) {
            recommendations.add("🥚 Protéines insuffisantes. Ajoutez œufs, yaourt, viande ou légumineuses.");
        }

        if (analysis.getSaturatedFat() != null && analysis.getSaturatedFat() > 15) {
            recommendations.add("🚫 Graisses saturées élevées. Privilégiez les huiles saines (olive, avocat).");
        }

        if (analysis.getSodium() != null && analysis.getSodium() > 1500) {
            recommendations.add("🧂 Sodium trop élevé. Réduisez le sel et les aliments transformés.");
        }

        if (analysis.getTotalCalories() != null && analysis.getTotalCalories() > 1200) {
            recommendations.add("🔥 Repas très calorique. Vérifiez les portions ou les méthodes de cuisson.");
        }

        return recommendations;
    }

    /**
     * Analyse de secours en cas d'erreur de l'API Edamam
     * Utilise les données locales du repas
     */
    private EdamamMealAnalysisDTO buildFallbackAnalysis(Meal meal) {
        EdamamMealAnalysisDTO dto = new EdamamMealAnalysisDTO();

        dto.setMealId(meal.getId());
        dto.setMealType(meal.getMealType());
        dto.setDate(meal.getDate());
        dto.setTotalCalories(meal.getTotalCalories() != null ? meal.getTotalCalories() : 0.0);
        dto.setTotalProtein(meal.getTotalProtein() != null ? meal.getTotalProtein() : 0.0);
        dto.setTotalFat(meal.getTotalFat() != null ? meal.getTotalFat() : 0.0);
        dto.setTotalCarbs(meal.getTotalCarbs() != null ? meal.getTotalCarbs() : 0.0);

        dto.setNutritionalScore(75.0); // Score par défaut
        dto.setRecommendations(List.of("Analyse détaillée indisponible. Vérifiez votre connexion."));

        return dto;
    }

    // ============ DTOs interna ============

    public static class EdamamMealAnalysisDTO {
        private Long mealId;
        private String mealType;
        private java.time.LocalDate date;

        // Macros
        private Double totalCalories;
        private Double totalProtein;
        private Double totalFat;
        private Double totalCarbs;

        // Nutriments détaillés
        private Double fiber;
        private Double sugar;
        private Double saturatedFat;
        private Double cholesterol;
        private Double sodium;

        // Vitamines et minéraux
        private Double calcium;
        private Double iron;
        private Double magnesium;
        private Double potassium;

        // Labels et score
        private List<String> healthLabels;
        private List<String> dietLabels;
        private Double nutritionalScore;
        private List<String> recommendations;

        // Getters et Setters
        public Long getMealId() { return mealId; }
        public void setMealId(Long mealId) { this.mealId = mealId; }

        public String getMealType() { return mealType; }
        public void setMealType(String mealType) { this.mealType = mealType; }

        public java.time.LocalDate getDate() { return date; }
        public void setDate(java.time.LocalDate date) { this.date = date; }

        public Double getTotalCalories() { return totalCalories; }
        public void setTotalCalories(Double totalCalories) { this.totalCalories = totalCalories; }

        public Double getTotalProtein() { return totalProtein; }
        public void setTotalProtein(Double totalProtein) { this.totalProtein = totalProtein; }

        public Double getTotalFat() { return totalFat; }
        public void setTotalFat(Double totalFat) { this.totalFat = totalFat; }

        public Double getTotalCarbs() { return totalCarbs; }
        public void setTotalCarbs(Double totalCarbs) { this.totalCarbs = totalCarbs; }

        public Double getFiber() { return fiber; }
        public void setFiber(Double fiber) { this.fiber = fiber; }

        public Double getSugar() { return sugar; }
        public void setSugar(Double sugar) { this.sugar = sugar; }

        public Double getSaturatedFat() { return saturatedFat; }
        public void setSaturatedFat(Double saturatedFat) { this.saturatedFat = saturatedFat; }

        public Double getCholesterol() { return cholesterol; }
        public void setCholesterol(Double cholesterol) { this.cholesterol = cholesterol; }

        public Double getSodium() { return sodium; }
        public void setSodium(Double sodium) { this.sodium = sodium; }

        public Double getCalcium() { return calcium; }
        public void setCalcium(Double calcium) { this.calcium = calcium; }

        public Double getIron() { return iron; }
        public void setIron(Double iron) { this.iron = iron; }

        public Double getMagnesium() { return magnesium; }
        public void setMagnesium(Double magnesium) { this.magnesium = magnesium; }

        public Double getPotassium() { return potassium; }
        public void setPotassium(Double potassium) { this.potassium = potassium; }

        public List<String> getHealthLabels() { return healthLabels; }
        public void setHealthLabels(List<String> healthLabels) { this.healthLabels = healthLabels; }

        public List<String> getDietLabels() { return dietLabels; }
        public void setDietLabels(List<String> dietLabels) { this.dietLabels = dietLabels; }

        public Double getNutritionalScore() { return nutritionalScore; }
        public void setNutritionalScore(Double nutritionalScore) { this.nutritionalScore = nutritionalScore; }

        public List<String> getRecommendations() { return recommendations; }
        public void setRecommendations(List<String> recommendations) { this.recommendations = recommendations; }
    }

    /**
     * DTO pour la réponse de l'API Edamam
     */
    public static class EdamamNutritionAnalysisResponse {
        private Map<String, NutrientInfo> totalNutrients;
        private List<String> healthLabels;
        private List<String> dietLabels;

        public Map<String, NutrientInfo> getTotalNutrients() { return totalNutrients; }
        public void setTotalNutrients(Map<String, NutrientInfo> totalNutrients) { this.totalNutrients = totalNutrients; }

        public List<String> getHealthLabels() { return healthLabels; }
        public void setHealthLabels(List<String> healthLabels) { this.healthLabels = healthLabels; }

        public List<String> getDietLabels() { return dietLabels; }
        public void setDietLabels(List<String> dietLabels) { this.dietLabels = dietLabels; }
    }

    /**
     * DTO pour les informations d'un nutriment
     */
    public static class NutrientInfo {
        private String label;
        private Double quantity;
        private String unit;

        public String getLabel() { return label; }
        public void setLabel(String label) { this.label = label; }

        public Double getQuantity() { return quantity; }
        public void setQuantity(Double quantity) { this.quantity = quantity; }

        public String getUnit() { return unit; }
        public void setUnit(String unit) { this.unit = unit; }
    }
}

