package com.nutriscan.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class FoodResponse {

    private Long id;
    private String name;
    private String category;

    private Double servingSize;
    private String servingUnit;

    private Double caloriesKcal;
    private Double proteinGr;
    private Double carbsGr;
    private Double fatGr;
    private Double fiberGr;
    private Double sugarGr;

    private String imageUrl;
    private String source;
}
