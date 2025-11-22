package com.nutriscan.dto.request;

import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

/**
 * Optional manual override for daily targets.
 * If a field is null, we keep the existing value.
 */
@Getter
@Setter
public class UpdateGoalsRequest {

    @Positive
    private Double targetCalories;

    @Positive
    private Double proteinGr;

    @Positive
    private Double carbsGr;

    @Positive
    private Double fatGr;
}
