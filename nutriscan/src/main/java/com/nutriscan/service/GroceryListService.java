package com.nutriscan.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.response.GroceryListResponse;
import com.nutriscan.exception.NotFoundException;
import com.nutriscan.model.*;
import com.nutriscan.repository.GroceryListRepository;
import com.nutriscan.repository.MealPlanRepository;
import com.nutriscan.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroceryListService {

    private final GroceryListRepository groceryListRepository;
    private final MealPlanRepository mealPlanRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;

    @Transactional
    public GroceryListResponse generateGroceryListFromMealPlan(Long userId, Long mealPlanId) {
        log.info("Generating grocery list for user {} from meal plan {}", userId, mealPlanId);

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        MealPlan mealPlan = mealPlanRepository.findById(mealPlanId)
                .orElseThrow(() -> new NotFoundException("Meal plan not found"));

        if (!mealPlan.getUser().getId().equals(userId)) {
            throw new NotFoundException("Meal plan not found");
        }

        // Check if grocery list already exists for this meal plan
        Optional<GroceryList> existingList = groceryListRepository.findByMealPlanId(mealPlanId);
        if (existingList.isPresent()) {
            return mapToResponse(existingList.get());
        }

        // Create grocery list
        GroceryList groceryList = GroceryList.builder()
                .user(user)
                .mealPlan(mealPlan)
                .startDate(mealPlan.getStartDate())
                .endDate(mealPlan.getEndDate())
                .items(new ArrayList<>())
                .build();

        // Aggregate ingredients from all planned meals
        Map<String, IngredientAggregate> aggregatedIngredients = new HashMap<>();

        for (PlannedMeal plannedMeal : mealPlan.getPlannedMeals()) {
            if (plannedMeal.getIngredients() != null) {
                try {
                    List<String> ingredients = objectMapper.readValue(
                            plannedMeal.getIngredients(),
                            new TypeReference<List<String>>() {}
                    );

                    for (String ingredient : ingredients) {
                        parseAndAggregateIngredient(ingredient, aggregatedIngredients);
                    }
                } catch (Exception e) {
                    log.error("Error parsing ingredients for meal {}", plannedMeal.getId(), e);
                }
            }
        }

        // Convert aggregated ingredients to grocery items
        for (Map.Entry<String, IngredientAggregate> entry : aggregatedIngredients.entrySet()) {
            IngredientAggregate agg = entry.getValue();

            GroceryItem item = GroceryItem.builder()
                    .groceryList(groceryList)
                    .name(agg.getName())
                    .quantity(agg.getQuantity())
                    .unit(agg.getUnit())
                    .category(categorizeIngredient(agg.getName()))
                    .purchased(false)
                    .build();

            groceryList.getItems().add(item);
        }

        groceryList = groceryListRepository.save(groceryList);

        return mapToResponse(groceryList);
    }

    @Transactional
    public GroceryListResponse generateGroceryListFromDateRange(Long userId, LocalDate startDate, LocalDate endDate) {
        log.info("Generating grocery list for user {} from {} to {}", userId, startDate, endDate);

        // Find meal plans for this date range (get most recent one)
        List<MealPlan> mealPlans = mealPlanRepository.findByUserIdAndDateRange(userId, startDate);

        if (mealPlans.isEmpty()) {
            throw new NotFoundException("No meal plan found for the specified date range. Please create a meal plan first.");
        }

        // Use the most recent meal plan (first in list due to ORDER BY createdAt DESC)
        MealPlan mealPlan = mealPlans.getFirst();

        if (mealPlans.size() > 1) {
            log.warn("Found {} meal plans for date range, using the most recent one (id: {})",
                mealPlans.size(), mealPlan.getId());
        }

        return generateGroceryListFromMealPlan(userId, mealPlan.getId());
    }

    public List<GroceryListResponse> getUserGroceryLists(Long userId) {
        List<GroceryList> lists = groceryListRepository.findByUserId(userId);
        return lists.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public GroceryListResponse getLatestGroceryList(Long userId) {
        List<GroceryList> lists = groceryListRepository.findByUserId(userId);

        if (lists.isEmpty()) {
            throw new NotFoundException("No grocery lists found. Please create a grocery list first.");
        }

        // Assume repository returns ordered by creation date DESC
        return mapToResponse(lists.get(0));
    }

    public GroceryListResponse getGroceryListById(Long userId, Long listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new NotFoundException("Grocery list not found"));

        if (!list.getUser().getId().equals(userId)) {
            throw new NotFoundException("Grocery list not found");
        }

        return mapToResponse(list);
    }

    @Transactional
    public GroceryListResponse updateItemStatus(Long userId, Long listId, Long itemId, Boolean purchased) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new NotFoundException("Grocery list not found"));

        if (!list.getUser().getId().equals(userId)) {
            throw new NotFoundException("Grocery list not found");
        }

        GroceryItem item = list.getItems().stream()
                .filter(i -> i.getId().equals(itemId))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("Grocery item not found"));

        item.setPurchased(purchased);
        list = groceryListRepository.save(list);

        return mapToResponse(list);
    }

    @Transactional
    public void deleteGroceryList(Long userId, Long listId) {
        GroceryList list = groceryListRepository.findById(listId)
                .orElseThrow(() -> new NotFoundException("Grocery list not found"));

        if (!list.getUser().getId().equals(userId)) {
            throw new NotFoundException("Grocery list not found");
        }

        groceryListRepository.delete(list);
    }

    private void parseAndAggregateIngredient(String ingredientLine, Map<String, IngredientAggregate> aggregated) {
        // Simple parsing - can be improved with NLP
        String cleaned = ingredientLine.toLowerCase().trim();

        // Try to extract quantity and unit (simple regex)
        String name = cleaned;
        double quantity = 1.0;
        String unit = "item";

        // Basic pattern matching (e.g., "2 cups flour", "500g chicken")
        String[] parts = cleaned.split("\\s+");
        if (parts.length >= 2) {
            try {
                // Try to parse first part as number
                quantity = Double.parseDouble(parts[0].replaceAll("[^0-9.]", ""));
                unit = parts[1];
                name = String.join(" ", Arrays.copyOfRange(parts, 2, parts.length));
            } catch (NumberFormatException e) {
                // Keep defaults
                name = cleaned;
            }
        }

        // Normalize name (remove common words)
        name = name.replaceAll("\\b(fresh|organic|chopped|diced|sliced|raw)\\b", "").trim();

        // Aggregate by name
        final String finalName = name;
        final String finalUnit = unit;
        final double finalQuantity = quantity;
        aggregated.computeIfAbsent(finalName, k -> new IngredientAggregate(finalName, 0.0, finalUnit))
                .addQuantity(finalQuantity);
    }

    private String categorizeIngredient(String ingredient) {
        String lower = ingredient.toLowerCase();

        if (lower.matches(".*(tomato|carrot|onion|pepper|lettuce|spinach|broccoli|cucumber|celery).*")) {
            return "VEGETABLES";
        } else if (lower.matches(".*(apple|banana|orange|berry|grape|lemon|lime|mango).*")) {
            return "FRUITS";
        } else if (lower.matches(".*(chicken|beef|pork|fish|salmon|turkey|egg|tofu).*")) {
            return "PROTEIN";
        } else if (lower.matches(".*(milk|cheese|yogurt|butter|cream).*")) {
            return "DAIRY";
        } else if (lower.matches(".*(rice|bread|pasta|flour|oat|quinoa|wheat).*")) {
            return "GRAINS";
        } else if (lower.matches(".*(oil|vinegar|salt|pepper|spice|herb|sauce).*")) {
            return "CONDIMENTS";
        } else {
            return "OTHER";
        }
    }

    private GroceryListResponse mapToResponse(GroceryList list) {
        List<GroceryListResponse.GroceryItem> items = list.getItems().stream()
                .map(item -> GroceryListResponse.GroceryItem.builder()
                        .id(item.getId())  // Inclure l'ID pour permettre les mises à jour
                        .name(item.getName())
                        .quantity(item.getQuantity())
                        .unit(item.getUnit())
                        .category(item.getCategory())
                        .purchased(item.getPurchased())
                        .build())
                .collect(Collectors.toList());

        return GroceryListResponse.builder()
                .id(list.getId())
                .userId(list.getUser().getId())
                .generatedDate(list.getGeneratedDate())
                .startDate(list.getStartDate())
                .endDate(list.getEndDate())
                .items(items)
                .totalItems(items.size())
                .build();
    }

    @lombok.Data
    @lombok.AllArgsConstructor
    private static class IngredientAggregate {
        private String name;
        private Double quantity;
        private String unit;

        public void addQuantity(Double amount) {
            this.quantity += amount;
        }
    }
}

