package com.nutriscan.controller;

import com.nutriscan.dto.response.FoodResponse;
import com.nutriscan.dto.response.OffProductResponse;
import com.nutriscan.service.FoodService;
import com.nutriscan.service.OpenFoodFactsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/foods")
@RequiredArgsConstructor
public class FoodController {

    private final FoodService foodService;
    private final OpenFoodFactsService openFoodFactsService;

    @GetMapping("/{id}")
    public ResponseEntity<FoodResponse> getFoodById(@PathVariable Long id) {
        return ResponseEntity.ok(foodService.getFoodById(id));
    }

    /**
     * Search foods in local database
     */
    @GetMapping("/search")
    public ResponseEntity<List<FoodResponse>> searchFoods(@RequestParam String query) {
        return ResponseEntity.ok(foodService.searchByName(query));
    }

    /**
     * Search organic foods in OpenFoodFacts API
     */
    @GetMapping("/search/organic")
    public ResponseEntity<List<OffProductResponse>> searchOrganicFoods(
            @RequestParam String query,
            @RequestParam(defaultValue = "20") Integer limit
    ) {
        List<OffProductResponse> products = openFoodFactsService.searchProducts(query, limit);
        return ResponseEntity.ok(products);
    }

    @GetMapping
    public ResponseEntity<List<FoodResponse>> getAllFoods() {
        return ResponseEntity.ok(foodService.getAllFoods());
    }
}
