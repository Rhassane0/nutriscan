package com.nutriscan.dto.request;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateFoodRequest {

    @NotBlank
    @Size(min = 2, max = 100)
    private String name;

    @NotBlank
    @Size(max = 50)
    private String category; // e.g., "Fruits", "Vegetables", "Proteins"

    @DecimalMin("1")
    @DecimalMax("500")
    private Double servingSize; // e.g., 100 for 100g

    @NotBlank
    @Size(max = 50)
    private String servingUnit; // e.g., "g", "ml", "portion"

    @DecimalMin("0")
    @DecimalMax("1000")
    private Double calories;

    @DecimalMin("0")
    @DecimalMax("200")
    private Double protein; // per serving

    @DecimalMin("0")
    @DecimalMax("200")
    private Double carbs; // per serving

    @DecimalMin("0")
    @DecimalMax("150")
    private Double fat; // per serving

    private String imageUrl;

    private String source; // "MANUAL", "OPENFOODSFACTS", "SEED"

    private String tags; // comma-separated: "moroccan", "healthy", "cheap", etc.
}

