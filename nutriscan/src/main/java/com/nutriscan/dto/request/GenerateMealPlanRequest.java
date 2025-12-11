package com.nutriscan.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class GenerateMealPlanRequest {

    @NotNull
    private LocalDate startDate;

    @NotNull
    private LocalDate endDate;

    private String planType; // WEEKLY, DAILY (default: WEEKLY)

    private Integer targetCalories; // Optional: use user's goals if not provided

    private List<String> dietaryRestrictions; // vegan, vegetarian, gluten-free, etc.

    private List<String> healthPreferences; // low-carb, high-protein, etc.

    private List<String> excludedIngredients; // allergies or dislikes

    private String cuisine; // italian, french, asian, etc. (optional)
}

