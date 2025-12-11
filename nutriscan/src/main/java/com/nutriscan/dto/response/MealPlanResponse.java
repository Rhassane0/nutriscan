package com.nutriscan.dto.response;

import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealPlanResponse {
    private Long id;
    private Long userId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String planType; // WEEKLY, DAILY
    private List<PlannedMeal> meals;
    private Double totalCalories;
    private Double totalProtein;
    private Double totalCarbs;
    private Double totalFat;

    @Getter
    @Setter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PlannedMeal {
        private LocalDate date;
        private String mealType; // BREAKFAST, LUNCH, DINNER, SNACK
        private String recipeName;
        private String recipeUri;
        private String recipeImage;
        private Integer servings;
        private Double calories;
        private List<String> ingredients;
    }
}

