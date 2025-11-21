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
@RequestMapping("/api/v1/meals")
@RequiredArgsConstructor
public class MealController {

    private final MealService mealService;

    @PostMapping
    public ResponseEntity<MealResponse> createMeal(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody CreateMealRequest request
    ) {
        MealResponse response = mealService.createMeal(currentUser.getId(), request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<MealResponse>> getMealsForDate(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        List<MealResponse> meals = mealService.getMealsForDate(currentUser.getId(), date);
        return ResponseEntity.ok(meals);
    }

    @GetMapping("/summary")
    public ResponseEntity<DailySummaryResponse> getDailySummary(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        DailySummaryResponse summary = mealService.getDailySummary(currentUser.getId(), date);
        return ResponseEntity.ok(summary);
    }
}
