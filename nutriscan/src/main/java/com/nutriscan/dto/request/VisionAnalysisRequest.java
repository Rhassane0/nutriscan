package com.nutriscan.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class VisionAnalysisRequest {

    @NotBlank
    private String imageUrl; // URL de l'image ou base64 encodée

    private String mealType; // Optionnel: "BREAKFAST", "LUNCH", etc.
}

