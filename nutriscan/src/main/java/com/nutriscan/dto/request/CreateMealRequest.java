package com.nutriscan.dto.request;

import com.nutriscan.model.enums.MealSource;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Getter
@Setter
public class CreateMealRequest {

    @NotNull
    private LocalDate date;

    @NotNull
    private LocalTime time;

    @NotBlank
    private String mealType; // "BREAKFAST", "LUNCH", etc.

    // Source optionnel - par défaut MANUAL
    private MealSource source;

    @NotEmpty
    private List<MealItemDto> items;

    @Getter
    @Setter
    public static class MealItemDto {

        /**
         * Either foodId (for local DB foods) OR foodName (for API foods)
         * If foodId is provided, fetch from local DB
         * If foodName + apiSource is provided, fetch from API (Edamam or OpenFoodFacts)
         */
        private Long foodId;  // Optional: local DB reference

        private String foodName;  // Required if foodId is not provided
        private String apiSource;  // "EDAMAM" or "OPENFOODFACTS" - required if foodName is provided

        @NotNull
        @Positive
        private Double quantity; // same unit as serving (e.g. grams)

        private String servingUnit; // "g", "ml", "piece", etc.

        // Nutrition data (can be pre-filled from API or calculated)
        private Double calories;
        private Double protein;
        private Double carbs;
        private Double fat;
    }
}


