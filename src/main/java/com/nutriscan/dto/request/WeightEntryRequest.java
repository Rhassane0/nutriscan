package com.nutriscan.dto.request;

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
    @Positive
    private Double weightKg;
}
