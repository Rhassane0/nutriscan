package com.nutriscan.controller;

import com.nutriscan.dto.request.UpdateGoalsRequest;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.GoalsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/goals")
@RequiredArgsConstructor
public class GoalsController {

    private final GoalsService goalsService;

    /**
     * Get current goals for logged-in user.
     * If no targets exist yet, they are calculated from the profile.
     */
    @GetMapping
    public ResponseEntity<GoalsResponse> getGoals(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        GoalsResponse response = goalsService.getGoalsForUser(currentUser.getId());
        return ResponseEntity.ok(response);
    }

    /**
     * Set/Create goals for logged-in user (POST alias for PUT).
     * Manual override of daily targets.
     */
    @PostMapping
    public ResponseEntity<GoalsResponse> setGoals(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody UpdateGoalsRequest request
    ) {
        GoalsResponse response = goalsService.updateGoals(currentUser.getId(), request);
        return ResponseEntity.ok(response);
    }

    /**
     * Recalculate goals from profile (goalType, activityLevel, weight, etc.).
     */
    @PostMapping("/recalculate")
    public ResponseEntity<GoalsResponse> recalculateGoals(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        GoalsResponse response = goalsService.recalculateGoals(currentUser.getId());
        return ResponseEntity.ok(response);
    }

    /**
     * Manual override of daily targets (PUT alias for POST).
     */
    @PutMapping
    public ResponseEntity<GoalsResponse> updateGoals(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody UpdateGoalsRequest request
    ) {
        GoalsResponse response = goalsService.updateGoals(currentUser.getId(), request);
        return ResponseEntity.ok(response);
    }

    /**
     * Delete goals - resets to recalculated values.
     */
    @DeleteMapping
    public ResponseEntity<Void> deleteGoals(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        goalsService.deleteGoals(currentUser.getId());
        return ResponseEntity.noContent().build();
    }
}

