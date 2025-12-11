package com.nutriscan.dto.request;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateFoodRequest {

    @Size(min = 2, max = 100)
    private String name;

    @Size(max = 50)
    private String category;

    @DecimalMin("1")
    @DecimalMax("500")
    private Double servingSize;

    @Size(max = 50)
    private String servingUnit;

    @DecimalMin("0")
    @DecimalMax("1000")
    private Double calories;

    @DecimalMin("0")
    @DecimalMax("200")
    private Double protein;

    @DecimalMin("0")
    @DecimalMax("200")
    private Double carbs;

    @DecimalMin("0")
    @DecimalMax("150")
    private Double fat;

    private String imageUrl;

    private String tags;
}

