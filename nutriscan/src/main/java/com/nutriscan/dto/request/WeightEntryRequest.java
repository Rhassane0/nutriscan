package com.nutriscan.dto.request;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class WeightEntryRequest {

    /**
     * Date of the measurement. If null, we'll use today's date.
     */
    private LocalDate date;

    @NotNull
    @DecimalMin("20.0")
    @DecimalMax("300.0")
    private Double weightKg;
}
