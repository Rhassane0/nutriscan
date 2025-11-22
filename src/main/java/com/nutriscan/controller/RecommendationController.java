package com.nutriscan.controller;

import com.nutriscan.dto.response.RecommendationResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.RecommendationService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/recommendations")
@RequiredArgsConstructor
public class RecommendationController {

    private final RecommendationService recommendationService;

    /**
     * Get a daily recommendation for the current user:
     * - Score /100
     * - Macros vs goals
     * - Messages (tips)
     *
     * Example:
     *  GET /api/v1/recommendations/daily
     *  GET /api/v1/recommendations/daily?date=2025-11-22
     */
    @GetMapping("/daily")
    public ResponseEntity<RecommendationResponse> getDailyRecommendation(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        RecommendationResponse response =
                recommendationService.getDailyRecommendation(currentUser.getId(), date);
        return ResponseEntity.ok(response);
    }
}
