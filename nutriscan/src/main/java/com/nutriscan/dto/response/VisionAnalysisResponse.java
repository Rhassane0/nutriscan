package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VisionAnalysisResponse {

    private List<DetectedFood> detectedFoods;
    private String analysisText; // Description générale en français
    private double confidenceScore; // 0-100%

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DetectedFood {
        private String name;
        private double confidence; // 0-100%
        private Double estimatedQuantityGrams;
        private Double estimatedCalories;
        private Double estimatedProteins;
        private Double estimatedCarbs;
        private Double estimatedFats;
        private Long suggestedFoodId; // ID de l'aliment dans la base si trouvé
        private String matchStatus; // "AUTO_MATCHED", "CANDIDATES", "NOT_FOUND", "DEMO"
        private List<FoodCandidate> candidates; // Candidates si confidence < 70%
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class FoodCandidate {
        private Long foodId;
        private String name;
        private double matchScore; // Similarité estimée
    }
}

