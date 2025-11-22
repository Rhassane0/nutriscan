package com.nutriscan.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Builder
public class WeightHistoryResponse {

    private Long id;
    private LocalDate date;
    private Double weightKg;
    private Double bmi;
}
