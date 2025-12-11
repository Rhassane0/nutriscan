package com.nutriscan.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AIExplanationRequest {

    @NotNull
    private LocalDate date;

    private String productBarcode; // Optionnel: pour l'analyse d'un produit spécifique
}

