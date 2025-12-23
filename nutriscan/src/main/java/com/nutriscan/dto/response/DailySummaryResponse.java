package com.nutriscan.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Builder
public class DailySummaryResponse {

    private LocalDate date;

    // Macronutriments principaux
    private Double totalCalories;
    private Double totalProtein;
    private Double totalCarbs;
    private Double totalFat;
    private Double totalFiber;
    private Double totalSugars;

    // Détails lipides
    private Double totalSaturatedFat;
    private Double totalUnsaturatedFat;
    private Double totalCholesterol;
    private Double totalOmega3;

    // Micronutriments - Minéraux
    private Double totalSodium;
    private Double totalCalcium;
    private Double totalIron;
    private Double totalPotassium;
    private Double totalMagnesium;
    private Double totalZinc;

    // Vitamines
    private Double totalVitaminA;
    private Double totalVitaminC;
    private Double totalVitaminD;
    private Double totalVitaminE;
    private Double totalVitaminB12;

    // Objectifs journaliers (valeurs absolues pour le frontend)
    private Double caloriesGoal;
    private Double proteinGoal;
    private Double carbsGoal;
    private Double fatGoal;
    private Double fiberGoal;

    // Objectifs journaliers (%)
    private Double caloriesPercentOfGoal;
    private Double proteinPercentOfGoal;
    private Double carbsPercentOfGoal;
    private Double fatPercentOfGoal;
    private Double fiberPercentOfGoal;

    // Score et recommandations
    private Integer nutritionScore;
    private String recommendation;
    private Integer mealsCount;
    private Double waterIntake;
}
