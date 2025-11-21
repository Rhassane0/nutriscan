package com.nutriscan.dto.response;

import com.nutriscan.model.enums.MealSource;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Getter
@Setter
@Builder
public class MealResponse {

    private Long id;
    private LocalDate date;
    private LocalTime time;
    private String mealType;
    private MealSource source;

    private Double totalCalories;
    private Double totalProtein;
    private Double totalCarbs;
    private Double totalFat;

    private List<MealItemResponse> items;

    @Getter
    @Setter
    @Builder
    public static class MealItemResponse {
        private Long id;
        private Long foodId;
        private String foodName;
        private Double quantity;
        private String servingUnit;
        private Double calories;
        private Double protein;
        private Double carbs;
        private Double fat;
    }
}
