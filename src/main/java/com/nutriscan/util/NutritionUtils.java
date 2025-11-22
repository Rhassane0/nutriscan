package com.nutriscan.util;

import com.nutriscan.model.enums.ActivityLevel;
import com.nutriscan.model.enums.Gender;
import com.nutriscan.model.enums.GoalType;
import lombok.AllArgsConstructor;
import lombok.Getter;

public final class NutritionUtils {

    private NutritionUtils() {
    }

    /**
     * Mifflin-St Jeor BMR formula.
     * weightKg, heightCm, ageYears
     */
    public static double calculateBmr(Gender gender, double weightKg, int heightCm, int ageYears) {
        double bmr = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
        if (gender == Gender.FEMALE) {
            bmr -= 161;
        } else {
            // Assume MALE as default for others
            bmr += 5;
        }
        return bmr;
    }

    public static double getActivityFactor(ActivityLevel level) {
        if (level == null) return 1.2;

        return switch (level) {
            case SEDENTARY -> 1.2;
            case LIGHT -> 1.375;
            case MODERATE -> 1.55;
            case ACTIVE -> 1.725;
            case VERY_ACTIVE -> 1.9;
        };
    }

    /**
     * TDEE = BMR * activity factor
     */
    public static double calculateTdee(
            Gender gender,
            double weightKg,
            int heightCm,
            int ageYears,
            ActivityLevel activityLevel
    ) {
        double bmr = calculateBmr(gender, weightKg, heightCm, ageYears);
        double factor = getActivityFactor(activityLevel);
        return bmr * factor;
    }

    /**
     * Apply deficit/surplus based on goal type.
     */
    public static double adjustCaloriesForGoal(double tdee, GoalType goalType) {
        if (goalType == null) return tdee;

        return switch (goalType) {
            case LOSE_WEIGHT -> tdee - 400;    // ~ -400 kcal
            case MAINTAIN -> tdee;
            case GAIN_WEIGHT -> tdee + 300;    // ~ +300 kcal
        };
    }

    /**
     * Simple macro strategy:
     * - Protein: 1.6–2.0 g/kg depending on goal
     * - Fat: 25% of calories
     * - Carbs: remaining calories
     */
    public static MacroTargets calculateMacroTargets(double targetCalories, double weightKg, GoalType goalType) {
        double proteinPerKg;

        if (goalType == null) {
            proteinPerKg = 1.6;
        } else {
            switch (goalType) {
                case LOSE_WEIGHT -> proteinPerKg = 1.8;
                case MAINTAIN -> proteinPerKg = 1.6;
                case GAIN_WEIGHT -> proteinPerKg = 2.0; // more for gain/sport
                default -> proteinPerKg = 1.6;
            }
        }

        double proteinGr = proteinPerKg * weightKg;

        double fatCalories = targetCalories * 0.25;
        double fatGr = fatCalories / 9.0;

        double proteinCalories = proteinGr * 4.0;
        double remainingCalories = targetCalories - proteinCalories - fatCalories;
        if (remainingCalories < 0) remainingCalories = 0;

        double carbsGr = remainingCalories / 4.0;

        return new MacroTargets(targetCalories, proteinGr, carbsGr, fatGr);
    }

    /**
     * BMI = weightKg / (heightM^2)
     */
    public static double calculateBmi(double weightKg, int heightCm) {
        double heightM = heightCm / 100.0;
        if (heightM <= 0) {
            throw new IllegalArgumentException("Height must be > 0");
        }
        return weightKg / (heightM * heightM);
    }


    @Getter
    @AllArgsConstructor
    public static class MacroTargets {
        private final double calories;
        private final double proteinGr;
        private final double carbsGr;
        private final double fatGr;
    }
}
