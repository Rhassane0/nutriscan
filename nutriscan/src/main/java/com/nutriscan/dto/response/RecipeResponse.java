package com.nutriscan.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecipeResponse {
    private String uri;
    private String label;
    private String image;
    private String source;
    private String url;
    private Integer servings;
    private List<String> dietLabels;
    private List<String> healthLabels;
    private List<String> ingredientLines;
    private Double calories;
    private Double totalTime;
    private NutritionInfo nutrition;

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class NutritionInfo {
        // Macronutriments
        private Double calories;
        private Double protein;
        private Double fat;
        private Double carbs;
        private Double fiber;
        private Double sugar;
        private Double saturatedFat;
        private Double monounsaturatedFat;
        private Double polyunsaturatedFat;
        private Double transFat;
        private Double cholesterol;
        private Double sodium;

        // Vitamines
        private Double vitaminA;
        private Double vitaminC;
        private Double vitaminD;
        private Double vitaminE;
        private Double vitaminK;
        private Double vitaminB6;
        private Double vitaminB12;
        private Double folate;
        private Double niacin;
        private Double riboflavin;
        private Double thiamin;

        // Minéraux
        private Double calcium;
        private Double iron;
        private Double magnesium;
        private Double phosphorus;
        private Double potassium;
        private Double zinc;
        private Double selenium;

        // Autres
        private Double water;
    }
}

