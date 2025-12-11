package com.nutriscan.util;

import lombok.extern.slf4j.Slf4j;

@Slf4j
public class NutritionCalculator {

    /**
     * Calcule le BMR (Basal Metabolic Rate) usando Mifflin-St Jeor formula
     * BMR = 10*weight(kg) + 6.25*height(cm) - 5*age + 5 (for men)
     * BMR = 10*weight(kg) + 6.25*height(cm) - 5*age - 161 (for women)
     */
    public double calculateBMR(double weight, double height, int age, String gender) {
        if ("MALE".equalsIgnoreCase(gender)) {
            return 10 * weight + 6.25 * height - 5 * age + 5;
        } else if ("FEMALE".equalsIgnoreCase(gender)) {
            return 10 * weight + 6.25 * height - 5 * age - 161;
        }
        throw new IllegalArgumentException("Gender must be MALE or FEMALE");
    }

    /**
     * Calcule le TDEE (Total Daily Energy Expenditure) = BMR * Activity Factor
     * Activity factors:
     * - SEDENTARY: 1.2 (little or no exercise)
     * - LIGHT: 1.375 (light exercise 1-3 days/week)
     * - MODERATE: 1.55 (moderate exercise 3-5 days/week)
     * - ACTIVE: 1.725 (heavy exercise 6-7 days/week)
     * - VERY_ACTIVE: 1.9 (physical job or training twice per day)
     */
    public double calculateTDEE(double bmr, String activityLevel) {
        double activityFactor = switch (activityLevel.toUpperCase()) {
            case "SEDENTARY" -> 1.2;
            case "LIGHT" -> 1.375;
            case "MODERATE" -> 1.55;
            case "ACTIVE" -> 1.725;
            case "VERY_ACTIVE" -> 1.9;
            default -> 1.55; // Default to moderate
        };
        return bmr * activityFactor;
    }

    /**
     * Ajuste les calories en fonction de l'objectif
     */
    public double adjustCaloriesForGoal(double tdee, String goal) {
        return switch (goal.toUpperCase()) {
            case "LOSE_WEIGHT" -> tdee - 400; // Déficit de 400 kcal
            case "GAIN_WEIGHT" -> tdee + 300; // Surplus de 300 kcal
            case "MAINTAIN" -> tdee;
            default -> tdee;
        };
    }

    /**
     * Calcule l'objectif de protéines par kilogramme
     * - Perte de poids: 2.0 g/kg
     * - Maintien: 1.6 g/kg
     * - Gain musculaire: 1.8-2.2 g/kg
     */
    public double calculateProteinTarget(double weight, String goal) {
        double proteinPerKg = switch (goal.toUpperCase()) {
            case "LOSE_WEIGHT" -> 2.0;
            case "MAINTAIN" -> 1.6;
            case "GAIN_WEIGHT" -> 2.0;
            default -> 1.6;
        };
        return weight * proteinPerKg;
    }

    /**
     * Calcule les glucides : 45-65% des calories totales
     * En moyenne : 4 kcal par gramme
     */
    public double calculateCarbsTarget(double calories) {
        // 50% des calories viennent des glucides
        double carbCalories = calories * 0.50;
        return carbCalories / 4; // 4 kcal par gramme de glucides
    }

    /**
     * Calcule les lipides : 20-35% des calories totales
     * En moyenne : 9 kcal par gramme
     */
    public double calculateFatTarget(double calories) {
        // 25% des calories viennent des lipides
        double fatCalories = calories * 0.25;
        return fatCalories / 9; // 9 kcal par gramme de lipides
    }

    /**
     * Calcule l'IMC (BMI - Body Mass Index)
     * BMI = weight(kg) / (height(m))²
     */
    public double calculateBMI(double weight, double heightCm) {
        double heightM = heightCm / 100;
        return weight / (heightM * heightM);
    }

    /**
     * Classifie l'IMC
     */
    public String classifyBMI(double bmi) {
        if (bmi < 18.5) {
            return "UNDERWEIGHT";
        } else if (bmi < 25) {
            return "NORMAL_WEIGHT";
        } else if (bmi < 30) {
            return "OVERWEIGHT";
        } else {
            return "OBESE";
        }
    }

    /**
     * Calcule le poids cible basé sur BMI normal (21-22)
     */
    public double calculateTargetWeight(double heightCm) {
        double heightM = heightCm / 100;
        // IMC cible: 22
        return 22 * heightM * heightM;
    }

    /**
     * Calcule les calories de maintenance pour une journée
     */
    public double calculateMaintenanceCalories(double weight, double height, int age, String gender, String activityLevel) {
        double bmr = calculateBMR(weight, height, age, gender);
        return calculateTDEE(bmr, activityLevel);
    }
}

