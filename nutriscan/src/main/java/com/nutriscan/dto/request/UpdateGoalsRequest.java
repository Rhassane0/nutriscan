package com.nutriscan.dto.request;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
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

    @DecimalMin("500")
    @DecimalMax("10000")
    private Double targetCalories;

    @DecimalMin("10")
    @DecimalMax("300")
    private Double proteinGr;

    @DecimalMin("20")
    @DecimalMax("800")
    private Double carbsGr;

    @DecimalMin("10")
    @DecimalMax("300")
    private Double fatGr;
}
