package com.nutriscan.controller;

import com.nutriscan.dto.response.MealScoreResponse;
import com.nutriscan.dto.response.PatternDetectionResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.NutritionPatternAnalysisService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/analysis")
@RequiredArgsConstructor
public class AnalysisController {

    private final NutritionPatternAnalysisService analysisService;

    /**
     * Détecte les patterns nutritionnels sur les 7 derniers jours
     * GET /api/v1/analysis/patterns
     */
    @GetMapping("/patterns")
    public ResponseEntity<List<PatternDetectionResponse>> detectPatterns(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        List<PatternDetectionResponse> patterns = analysisService.detectPatterns(currentUser.getId());
        return ResponseEntity.ok(patterns);
    }

    /**
     * Génère les scores pour chaque repas d'une journée
     * GET /api/v1/analysis/meal-scores?date=2025-01-15
     */
    @GetMapping("/meal-scores")
    public ResponseEntity<List<MealScoreResponse>> getMealScores(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        LocalDate targetDate = (date != null) ? date : LocalDate.now();
        List<MealScoreResponse> scores = analysisService.generateMealScores(currentUser.getId(), targetDate);
        return ResponseEntity.ok(scores);
    }
}

