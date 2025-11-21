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

    @NotNull
    private MealSource source;

    @NotEmpty
    private List<MealItemDto> items;

    @Getter
    @Setter
    public static class MealItemDto {

        @NotNull
        private Long foodId;

        @NotNull
        @Positive
        private Double quantity; // same unit as Food.servingUnit (e.g. grams)
    }
}
