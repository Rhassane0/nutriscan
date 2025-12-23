package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FoodInfoResponse {

    private String name;
    private String imageUrl;
    private String category;
    private String brand;
    private String source;
    private String nutriScore;

    // Macronutriments de base
    private Double calories;
    private Double protein;
    private Double carbs;
    private Double fat;
    private Double fiber;
    private Double sugars;

    // Détails lipides
    private Double saturatedFat;
    private Double monounsaturatedFat;
    private Double polyunsaturatedFat;
    private Double transFat;
    private Double cholesterol;

    // Autres macros
    private Double sodium;
    private Double salt;
    private Double starch;
    private Double alcohol;

    // Vitamines
    private Double vitaminA;
    private Double vitaminC;
    private Double vitaminD;
    private Double vitaminE;
    private Double vitaminK;
    private Double vitaminB1;
    private Double vitaminB2;
    private Double vitaminB3;
    private Double vitaminB6;
    private Double vitaminB9;
    private Double vitaminB12;

    // Minéraux
    private Double calcium;
    private Double iron;
    private Double magnesium;
    private Double phosphorus;
    private Double potassium;
    private Double zinc;
    private Double selenium;
    private Double copper;
    private Double manganese;
    private Double iodine;

    // Autres
    private Double water;
    private Double caffeine;
    private Double omega3;
    private Double omega6;
}

