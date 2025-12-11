package com.nutriscan.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatternDetectionResponse {
    private String patternType; // "HIGH_SUGAR_EVENING", "LOW_PROTEIN_BREAKFAST", "LATE_EATING", etc.
    private String description; // Description en français
    private String recommendation; // Conseil personnalisé
    private int severity; // 1-3 (low, medium, high)
}

