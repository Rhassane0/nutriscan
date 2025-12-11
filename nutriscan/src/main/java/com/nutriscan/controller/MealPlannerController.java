package com.nutriscan.controller;

import com.nutriscan.dto.request.GenerateMealPlanRequest;
import com.nutriscan.dto.response.MealPlanResponse;
import com.nutriscan.dto.response.RecipeResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.EdamamRecipeService;
import com.nutriscan.service.MealPlanService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/meal-planner")
@RequiredArgsConstructor
public class MealPlannerController {

    private final MealPlanService mealPlanService;
    private final EdamamRecipeService recipeService;

    /**
     * Search recipes
     */
    @GetMapping("/recipes/search")
    public ResponseEntity<List<RecipeResponse>> searchRecipes(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam String query,
            @RequestParam(required = false) List<String> diet,
            @RequestParam(required = false) List<String> health,
            @RequestParam(required = false) String cuisineType,
            @RequestParam(required = false) String mealType,
            @RequestParam(required = false) Integer calories,
            @RequestParam(defaultValue = "10") Integer limit
    ) {
        List<RecipeResponse> recipes = recipeService.searchRecipes(
                query, diet, health, cuisineType, mealType, calories, limit
        );
        return ResponseEntity.ok(recipes);
    }

    /**
     * Generate meal plan
     */
    @PostMapping("/generate")
    public ResponseEntity<MealPlanResponse> generateMealPlan(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @Valid @RequestBody GenerateMealPlanRequest request
    ) {
        MealPlanResponse response = mealPlanService.generateMealPlan(currentUser.getId(), request);
        return ResponseEntity.status(201).body(response);
    }

    /**
     * Get all meal plans for current user
     */
    @GetMapping
    public ResponseEntity<List<MealPlanResponse>> getUserMealPlans(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        List<MealPlanResponse> plans = mealPlanService.getUserMealPlans(currentUser.getId());
        return ResponseEntity.ok(plans);
    }

    /**
     * Get the latest/most recent meal plan for current user
     */
    @GetMapping("/latest")
    public ResponseEntity<MealPlanResponse> getLatestMealPlan(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        MealPlanResponse plan = mealPlanService.getLatestMealPlan(currentUser.getId());
        return ResponseEntity.ok(plan);
    }

    /**
     * Get specific meal plan by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<MealPlanResponse> getMealPlanById(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id
    ) {
        MealPlanResponse plan = mealPlanService.getMealPlanById(currentUser.getId(), id);
        return ResponseEntity.ok(plan);
    }

    /**
     * Delete meal plan
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMealPlan(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id
    ) {
        mealPlanService.deleteMealPlan(currentUser.getId(), id);
        return ResponseEntity.noContent().build();
    }
}

