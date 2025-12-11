package com.nutriscan.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Requête pour scanner un repas (image ou code-barres)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealScanRequest {

    /**
     * Type de scan: "BARCODE", "IMAGE_URL", "IMAGE_BASE64"
     */
    @NotBlank(message = "Le type de scan est requis")
    private String scanType;

    /**
     * Données du scan:
     * - Pour BARCODE: le code-barres
     * - Pour IMAGE_URL: l'URL de l'image
     * - Pour IMAGE_BASE64: l'image encodée en base64
     */
    @NotBlank(message = "Les données du scan sont requises")
    private String data;

    /**
     * Type de repas optionnel: BREAKFAST, LUNCH, DINNER, SNACK
     */
    private String mealType;

    /**
     * Quantité estimée en grammes (optionnel)
     */
    private Double estimatedQuantityGrams;
}

