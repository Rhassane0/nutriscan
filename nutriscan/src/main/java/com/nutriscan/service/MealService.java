package com.nutriscan.service;

import com.nutriscan.dto.request.CreateMealRequest;
import com.nutriscan.dto.response.DailySummaryResponse;
import com.nutriscan.dto.response.MealResponse;
import com.nutriscan.model.Food;
import com.nutriscan.model.Meal;
import com.nutriscan.model.MealItem;
import com.nutriscan.model.User;
import com.nutriscan.repository.FoodRepository;
import com.nutriscan.repository.MealRepository;
import com.nutriscan.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class MealService {

    private final MealRepository mealRepository;
    private final FoodRepository foodRepository;
    private final UserRepository userRepository;

    public MealResponse createMeal(Long userId, CreateMealRequest request) {
        try {
            log.info("Creating meal for user: {}", userId);
            log.debug("Request: date={}, time={}, mealType={}, items count={}",
                request.getDate(), request.getTime(), request.getMealType(),
                request.getItems() != null ? request.getItems().size() : 0);

            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

            Meal meal = new Meal();
            meal.setUser(user);
            meal.setDate(request.getDate());
            meal.setTime(request.getTime());
            meal.setMealType(request.getMealType());
            meal.setSource(request.getSource() != null ? request.getSource() : com.nutriscan.model.enums.MealSource.MANUAL);

            double totalCalories = 0.0;
            double totalProtein = 0.0;
            double totalCarbs = 0.0;
            double totalFat = 0.0;

            List<MealItem> items = new ArrayList<>();

            for (CreateMealRequest.MealItemDto itemDto : request.getItems()) {
                log.debug("Processing meal item: foodId={}, foodName={}, apiSource={}, quantity={}",
                    itemDto.getFoodId(), itemDto.getFoodName(), itemDto.getApiSource(), itemDto.getQuantity());

                double calories = 0.0;
                double protein = 0.0;
                double carbs = 0.0;
                double fat = 0.0;
                String foodName = "";
                String servingUnit = "g";

                // Case 1: Food from local database (backward compatibility)
                if (itemDto.getFoodId() != null) {
                    log.debug("Using local database food with ID: {}", itemDto.getFoodId());

                    Food food = foodRepository.findById(itemDto.getFoodId())
                            .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + itemDto.getFoodId()));

                    foodName = food.getName();
                    servingUnit = food.getServingUnit() != null ? food.getServingUnit() : "g";
                    double factor = itemDto.getQuantity() / (food.getServingSize() != null && food.getServingSize() > 0 ? food.getServingSize() : 1.0);

                    calories = safe(food.getCaloriesKcal()) * factor;
                    protein = safe(food.getProteinGr()) * factor;
                    carbs = safe(food.getCarbsGr()) * factor;
                    fat = safe(food.getFatGr()) * factor;

                    MealItem item = MealItem.builder()
                            .meal(meal)
                            .food(food)
                            .foodName(foodName)
                            .quantity(itemDto.getQuantity())
                            .servingUnit(servingUnit)
                            .calories(calories)
                            .protein(protein)
                            .carbs(carbs)
                            .fat(fat)
                            .build();

                    items.add(item);
                }
                // Case 2: Food from API (Edamam or OpenFoodFacts)
                else if (itemDto.getFoodName() != null && !itemDto.getFoodName().isEmpty()) {
                    log.debug("Using API food: {} from {}", itemDto.getFoodName(), itemDto.getApiSource());

                    foodName = itemDto.getFoodName();
                    servingUnit = itemDto.getServingUnit() != null ? itemDto.getServingUnit() : "g";

                    // Use pre-filled nutrition data from API or frontend
                    if (itemDto.getCalories() != null) {
                        // Nutrition data provided from frontend (already calculated)
                        calories = itemDto.getCalories();
                        protein = safe(itemDto.getProtein());
                        carbs = safe(itemDto.getCarbs());
                        fat = safe(itemDto.getFat());

                        log.debug("Using provided nutrition: cal={}, protein={}, carbs={}, fat={}",
                            calories, protein, carbs, fat);
                    } else {
                        // No nutrition data provided - can't calculate
                        log.error("Nutrition data missing for API food: {}", itemDto.getFoodName());
                        throw new IllegalArgumentException("Nutrition data required for API food: " + itemDto.getFoodName());
                    }

                    // Create a temporary MealItem with API food data
                    // Note: We don't store food reference, just the data
                    MealItem item = MealItem.builder()
                            .meal(meal)
                            .food(null)  // No local food reference for API foods
                            .foodName(foodName)
                            .quantity(itemDto.getQuantity())
                            .servingUnit(servingUnit)
                            .calories(calories)
                            .protein(protein)
                            .carbs(carbs)
                            .fat(fat)
                            .build();

                    items.add(item);
                } else {
                    log.error("Neither foodId nor foodName provided in meal item");
                    throw new IllegalArgumentException("Either foodId or foodName must be provided");
                }

                totalCalories += calories;
                totalProtein += protein;
                totalCarbs += carbs;
                totalFat += fat;
            }

            meal.setTotalCalories(totalCalories);
            meal.setTotalProtein(totalProtein);
            meal.setTotalCarbs(totalCarbs);
            meal.setTotalFat(totalFat);
            meal.setItems(items);

            log.debug("Saving meal with {} items, totals: cal={}, protein={}, carbs={}, fat={}",
                items.size(), totalCalories, totalProtein, totalCarbs, totalFat);

            Meal saved = mealRepository.save(meal);

            log.info("Meal created successfully with ID: {}", saved.getId());

            return mapToMealResponse(saved);

        } catch (Exception e) {
            log.error("Error creating meal: {}", e.getMessage(), e);
            throw e;
        }
    }

    @Transactional(readOnly = true)
    public List<MealResponse> getMealsForDate(Long userId, LocalDate date) {
        List<Meal> meals = mealRepository.findByUserIdAndDate(userId, date);
        return meals.stream()
                .map(this::mapToMealResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public DailySummaryResponse getDailySummary(Long userId, LocalDate date) {
        List<Meal> meals = mealRepository.findByUserIdAndDate(userId, date);

        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;

        for (Meal meal : meals) {
            totalCalories += safe(meal.getTotalCalories());
            totalProtein  += safe(meal.getTotalProtein());
            totalCarbs    += safe(meal.getTotalCarbs());
            totalFat      += safe(meal.getTotalFat());
        }

        return DailySummaryResponse.builder()
                .date(date)
                .totalCalories(totalCalories)
                .totalProtein(totalProtein)
                .totalCarbs(totalCarbs)
                .totalFat(totalFat)
                .build();
    }

    /**
     * Update an existing meal.
     * Supports both local DB foods and API foods (Edamam, OpenFoodFacts)
     */
    public MealResponse updateMeal(Long userId, Long mealId, CreateMealRequest request) {
        // Verify meal belongs to user by reloading user to avoid lazy loading issues
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new IllegalArgumentException("Meal not found with id: " + mealId));

        // Reload user from DB to avoid lazy loading
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        if (!meal.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Meal does not belong to user");
        }

        // Update meal properties
        meal.setDate(request.getDate());
        meal.setTime(request.getTime());
        meal.setMealType(request.getMealType());
        meal.setSource(request.getSource() != null ? request.getSource() : com.nutriscan.model.enums.MealSource.MANUAL);

        // Clear old items
        meal.getItems().clear();

        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;

        // Add new items (same logic as createMeal)
        for (CreateMealRequest.MealItemDto itemDto : request.getItems()) {
            double calories = 0.0;
            double protein = 0.0;
            double carbs = 0.0;
            double fat = 0.0;
            String foodName = "";
            String servingUnit = "g";

            // Case 1: Food from local database
            if (itemDto.getFoodId() != null) {
                Food food = foodRepository.findById(itemDto.getFoodId())
                        .orElseThrow(() -> new IllegalArgumentException("Food not found with id: " + itemDto.getFoodId()));

                foodName = food.getName();
                servingUnit = food.getServingUnit() != null ? food.getServingUnit() : "g";
                double factor = itemDto.getQuantity() / (food.getServingSize() != null && food.getServingSize() > 0 ? food.getServingSize() : 1.0);

                calories = safe(food.getCaloriesKcal()) * factor;
                protein = safe(food.getProteinGr()) * factor;
                carbs = safe(food.getCarbsGr()) * factor;
                fat = safe(food.getFatGr()) * factor;

                MealItem item = MealItem.builder()
                        .meal(meal)
                        .food(food)
                        .foodName(foodName)
                        .quantity(itemDto.getQuantity())
                        .servingUnit(servingUnit)
                        .calories(calories)
                        .protein(protein)
                        .carbs(carbs)
                        .fat(fat)
                        .build();

                meal.getItems().add(item);
            }
            // Case 2: Food from API
            else if (itemDto.getFoodName() != null && !itemDto.getFoodName().isEmpty()) {
                if (itemDto.getCalories() != null) {
                    calories = itemDto.getCalories();
                    protein = safe(itemDto.getProtein());
                    carbs = safe(itemDto.getCarbs());
                    fat = safe(itemDto.getFat());
                } else {
                    throw new IllegalArgumentException("Nutrition data required for API food: " + itemDto.getFoodName());
                }

                MealItem item = MealItem.builder()
                        .meal(meal)
                        .food(null)
                        .foodName(itemDto.getFoodName())
                        .quantity(itemDto.getQuantity())
                        .servingUnit(itemDto.getServingUnit() != null ? itemDto.getServingUnit() : "g")
                        .calories(calories)
                        .protein(protein)
                        .carbs(carbs)
                        .fat(fat)
                        .build();

                meal.getItems().add(item);
            } else {
                throw new IllegalArgumentException("Either foodId or foodName must be provided");
            }

            totalCalories += calories;
            totalProtein += protein;
            totalCarbs += carbs;
            totalFat += fat;
        }

        // Update totals
        meal.setTotalCalories(totalCalories);
        meal.setTotalProtein(totalProtein);
        meal.setTotalCarbs(totalCarbs);
        meal.setTotalFat(totalFat);

        Meal updated = mealRepository.save(meal);
        return mapToMealResponse(updated);
    }

    /**
     * Delete a meal.
     */
    public void deleteMeal(Long userId, Long mealId) {
        // Verify meal belongs to user by reloading user to avoid lazy loading issues
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new IllegalArgumentException("Meal not found with id: " + mealId));

        // Reload user from DB to avoid lazy loading
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));

        if (!meal.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Meal does not belong to user");
        }

        mealRepository.deleteById(mealId);
    }

    private MealResponse mapToMealResponse(Meal meal) {
        return MealResponse.builder()
                .id(meal.getId())
                .date(meal.getDate())
                .time(meal.getTime())
                .mealType(meal.getMealType())
                .source(meal.getSource())
                .totalCalories(meal.getTotalCalories())
                .totalProtein(meal.getTotalProtein())
                .totalCarbs(meal.getTotalCarbs())
                .totalFat(meal.getTotalFat())
                .items(
                        meal.getItems().stream()
                                .map(item -> MealResponse.MealItemResponse.builder()
                                        .id(item.getId())
                                        .foodId(item.getFood() != null ? item.getFood().getId() : null)
                                        .foodName(item.getFoodName() != null ? item.getFoodName() : (item.getFood() != null ? item.getFood().getName() : null))
                                        .quantity(item.getQuantity())
                                        .servingUnit(item.getServingUnit())
                                        .calories(item.getCalories())
                                        .protein(item.getProtein())
                                        .carbs(item.getCarbs())
                                        .fat(item.getFat())
                                        .build()
                                ).toList()
                )
                .build();
    }

    private double safe(Double value) {
        return value == null ? 0.0 : value;
    }
}

