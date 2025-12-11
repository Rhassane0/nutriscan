package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealScoreResponse {
    private String mealType; // BREAKFAST, LUNCH, DINNER, SNACK
    private LocalTime time;
    private Double score; // 0-100
    private Double caloriesActual;
    private Double caloriesTarget;
    private Double proteinActual;
    private Double proteinTarget;
    private String feedback; // personnalisé pour ce repas
}

