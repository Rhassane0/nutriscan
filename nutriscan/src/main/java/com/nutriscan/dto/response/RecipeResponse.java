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
        private Double calories;
        private Double protein;
        private Double fat;
        private Double carbs;
        private Double fiber;
        private Double sugar;
    }
}

