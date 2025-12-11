package com.nutriscan.controller;

import com.nutriscan.dto.request.CreateMealRequest;
import com.nutriscan.dto.response.DailySummaryResponse;
import com.nutriscan.dto.response.MealResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.MealService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/meals")
@RequiredArgsConstructor
public class MealController {

    private final MealService mealService;

    /**
     * Create a new meal for the user.
     */
    @PostMapping
    public ResponseEntity<MealResponse> createMeal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody CreateMealRequest request
    ) {
        MealResponse response = mealService.createMeal(currentUser.getId(), request);
        return ResponseEntity.status(201).body(response);
    }

    /**
     * Get all meals for a specific date (defaults to today if not specified).
     */
    @GetMapping
    public ResponseEntity<List<MealResponse>> getMealsForDate(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        LocalDate targetDate = date != null ? date : LocalDate.now();
        List<MealResponse> meals = mealService.getMealsForDate(currentUser.getId(), targetDate);
        return ResponseEntity.ok(meals);
    }

    /**
     * Get daily nutrition summary.
     */
    @GetMapping("/summary")
    public ResponseEntity<DailySummaryResponse> getDailySummary(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        DailySummaryResponse summary = mealService.getDailySummary(currentUser.getId(), date);
        return ResponseEntity.ok(summary);
    }

    /**
     * Update an existing meal.
     */
    @PutMapping("/{mealId}")
    public ResponseEntity<MealResponse> updateMeal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long mealId,
            @Valid @RequestBody CreateMealRequest request
    ) {
        MealResponse response = mealService.updateMeal(currentUser.getId(), mealId, request);
        return ResponseEntity.ok(response);
    }

    /**
     * Delete a meal.
     */
    @DeleteMapping("/{mealId}")
    public ResponseEntity<Void> deleteMeal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long mealId
    ) {
        mealService.deleteMeal(currentUser.getId(), mealId);
        return ResponseEntity.noContent().build();
    }
}

