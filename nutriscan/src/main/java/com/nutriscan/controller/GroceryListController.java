package com.nutriscan.controller;

import com.nutriscan.dto.response.GroceryListResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.GroceryListService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/grocery-list")
@RequiredArgsConstructor
public class GroceryListController {

    private final GroceryListService groceryListService;

    /**
     * Generate grocery list from meal plan
     */
    @PostMapping("/from-meal-plan/{mealPlanId}")
    public ResponseEntity<GroceryListResponse> generateFromMealPlan(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long mealPlanId
    ) {
        GroceryListResponse response = groceryListService.generateGroceryListFromMealPlan(
                currentUser.getId(), mealPlanId
        );
        return ResponseEntity.status(201).body(response);
    }

    /**
     * Generate grocery list from date range
     */
    @PostMapping("/from-dates")
    public ResponseEntity<GroceryListResponse> generateFromDateRange(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        GroceryListResponse response = groceryListService.generateGroceryListFromDateRange(
                currentUser.getId(), startDate, endDate
        );
        return ResponseEntity.status(201).body(response);
    }

    /**
     * Get all grocery lists for current user
     */
    @GetMapping
    public ResponseEntity<List<GroceryListResponse>> getUserGroceryLists(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        List<GroceryListResponse> lists = groceryListService.getUserGroceryLists(currentUser.getId());
        return ResponseEntity.ok(lists);
    }

    /**
     * Get the latest/most recent grocery list for current user
     */
    @GetMapping("/latest")
    public ResponseEntity<GroceryListResponse> getLatestGroceryList(
            @AuthenticationPrincipal CustomUserDetails currentUser
    ) {
        GroceryListResponse list = groceryListService.getLatestGroceryList(currentUser.getId());
        return ResponseEntity.ok(list);
    }

    /**
     * Get specific grocery list by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<GroceryListResponse> getGroceryListById(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id
    ) {
        GroceryListResponse list = groceryListService.getGroceryListById(currentUser.getId(), id);
        return ResponseEntity.ok(list);
    }

    /**
     * Update item purchased status
     */
    @PatchMapping("/{listId}/items/{itemId}")
    public ResponseEntity<GroceryListResponse> updateItemStatus(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long listId,
            @PathVariable Long itemId,
            @RequestParam Boolean purchased
    ) {
        GroceryListResponse response = groceryListService.updateItemStatus(
                currentUser.getId(), listId, itemId, purchased
        );
        return ResponseEntity.ok(response);
    }

    /**
     * Delete grocery list
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGroceryList(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @PathVariable Long id
    ) {
        groceryListService.deleteGroceryList(currentUser.getId(), id);
        return ResponseEntity.noContent().build();
    }
}

