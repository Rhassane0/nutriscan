package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FoodInfoResponse {

    private String name;
    private String imageUrl;
    private Double calories;
    private Double protein;
    private Double carbs;
    private Double fat;
    private String nutriScore;
    private String source;
}

