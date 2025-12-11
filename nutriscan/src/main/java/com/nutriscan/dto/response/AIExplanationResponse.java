package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AIExplanationResponse {

    private String explanation; // Explication générale en français
    private String tips; // Conseils pratiques personnalisés
    private String nutritionInsight; // Insight sur la nutrition du jour
    private boolean isProductAnalysis; // Si c'est l'analyse d'un produit
    private String productName; // Nom du produit si analyse produit
    private String productAdvice; // Conseil sur le produit (bon pour vos objectifs ou non)
}

