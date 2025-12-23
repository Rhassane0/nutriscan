package com.nutriscan.dto.request;

import com.nutriscan.model.enums.MealSource;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Getter
@Setter
public class CreateMealRequest {

    @NotNull(message = "La date est requise")
    private LocalDate date;

    // Time est optionnel - si non fourni, on utilisera l'heure courante
    private LocalTime time;

    @NotBlank(message = "Le type de repas est requis")
    private String mealType; // "BREAKFAST", "LUNCH", etc.

    // Source optionnel - par défaut MANUAL
    private MealSource source;

    @NotEmpty(message = "Au moins un aliment est requis")
    @Valid
    private List<MealItemDto> items;

    @Getter
    @Setter
    public static class MealItemDto {

        /**
         * Either foodId (for local DB foods) OR foodName (for API foods)
         */
        private Long foodId;  // Optional: local DB reference

        private String foodName;  // Required if foodId is not provided
        private String apiSource;  // "EDAMAM" or "OPENFOODFACTS"

        // Quantity - flexible pour accepter différents formats
        private Double quantity;

        private String servingUnit; // "g", "ml", "piece", etc.

        // Nutrition data
        private Double calories;
        private Double protein;
        private Double carbs;
        private Double fat;

        // Getter avec valeur par défaut pour quantity
        public Double getQuantity() {
            return quantity != null ? quantity : 100.0;
        }
    }
}


