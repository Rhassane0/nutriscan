package com.nutriscan.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@Builder
public class RecommendationResponse {

    private LocalDate date;

    private Double score; // 0–100

    private Double totalCalories;
    private Double targetCalories;

    private Double totalProtein;
    private Double targetProtein;

    private Double totalCarbs;
    private Double targetCarbs;

    private Double totalFat;
    private Double targetFat;

    private boolean caloriesOnTarget;
    private boolean proteinOnTarget;
    private boolean fatOk;

    private List<String> messages;
}
