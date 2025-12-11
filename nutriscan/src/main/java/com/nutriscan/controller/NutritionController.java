package com.nutriscan.controller;

import com.nutriscan.dto.response.FoodInfoResponse;
import com.nutriscan.dto.response.OffProductResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.NutritionDatabaseService;
import com.nutriscan.service.OpenFoodFactsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/nutrition")
@RequiredArgsConstructor
public class NutritionController {

    private final NutritionDatabaseService nutritionDatabaseService;
    private final OpenFoodFactsService openFoodFactsService;

    /**
     * Search natural foods in the nutrition database (Edamam API).
     * Returns complete food details including calories, macros, etc.
     * No need to call a separate endpoint for details.
     */
    @GetMapping("/search")
    public ResponseEntity<List<FoodInfoResponse>> searchFoods(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam String query,
            @RequestParam(defaultValue = "10") int limit
    ) {
        // Search returns complete food info with all nutritional details
        List<FoodInfoResponse> results = nutritionDatabaseService.searchFoods(query, limit);
        return ResponseEntity.ok(results);
    }

    /**
     * Search for a single specific food by name.
     * Returns complete food info with all nutritional details.
     */
    @GetMapping("/search-by-name")
    public ResponseEntity<FoodInfoResponse> searchFoodByName(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam String name
    ) {
        // Returns complete food info - no additional API call needed
        FoodInfoResponse food = nutritionDatabaseService.searchFoodByName(name);
        return ResponseEntity.ok(food);
    }

    /**
     * Alternative search endpoint - same as /search.
     */
    @GetMapping("/find")
    public ResponseEntity<List<FoodInfoResponse>> findFoods(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam String query,
            @RequestParam(defaultValue = "10") int limit
    ) {
        List<FoodInfoResponse> results = nutritionDatabaseService.searchFoods(query, limit);
        return ResponseEntity.ok(results);
    }

    /**
     * Search for organic foods/products (OpenFoodFacts API).
     * Returns packaged products and organic items.
     */
    @GetMapping("/organic/search")
    public ResponseEntity<List<OffProductResponse>> searchOrganicProducts(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam String query,
            @RequestParam(defaultValue = "10") int limit
    ) {
        List<OffProductResponse> results = openFoodFactsService.searchProducts(query, limit);
        return ResponseEntity.ok(results);
    }

    /**
     * Get product details by barcode (OpenFoodFacts).
     */
    @GetMapping("/organic/barcode/{barcode}")
    public ResponseEntity<OffProductResponse> getProductByBarcode(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable String barcode
    ) {
        OffProductResponse product = openFoodFactsService.getProductByBarcode(barcode);
        return ResponseEntity.ok(product);
    }
}

