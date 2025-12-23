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
            // Si time n'est pas fourni, utiliser l'heure courante
            meal.setTime(request.getTime() != null ? request.getTime() : java.time.LocalTime.now());
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

        // Macronutriments
        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;
        double totalFiber = 0.0;
        double totalSugars = 0.0;

        // Lipides détaillés
        double totalSaturatedFat = 0.0;
        double totalUnsaturatedFat = 0.0;
        double totalCholesterol = 0.0;

        // Micronutriments
        double totalSodium = 0.0;
        double totalCalcium = 0.0;
        double totalIron = 0.0;
        double totalPotassium = 0.0;

        // Vitamines
        double totalVitaminC = 0.0;
        double totalVitaminD = 0.0;
        double totalVitaminA = 0.0;

        for (Meal meal : meals) {
            totalCalories += safe(meal.getTotalCalories());
            totalProtein  += safe(meal.getTotalProtein());
            totalCarbs    += safe(meal.getTotalCarbs());
            totalFat      += safe(meal.getTotalFat());

            // Calculer les micronutriments à partir des items du repas
            if (meal.getItems() != null) {
                for (MealItem item : meal.getItems()) {
                    // Estimer les micronutriments basés sur les macros si non disponibles
                    double itemCal = safe(item.getCalories());
                    double itemCarbs = safe(item.getCarbs());
                    double itemFat = safe(item.getFat());

                    // Estimations basées sur les apports typiques
                    totalFiber += itemCarbs * 0.1;  // ~10% des glucides en fibres
                    totalSugars += itemCarbs * 0.3; // ~30% des glucides en sucres
                    totalSaturatedFat += itemFat * 0.35; // ~35% des lipides saturés
                    totalUnsaturatedFat += itemFat * 0.65; // ~65% insaturés
                    totalCholesterol += itemCal * 0.05; // estimation
                    totalSodium += itemCal * 0.4; // ~0.4mg/kcal
                    totalCalcium += itemCal * 0.15; // estimation
                    totalIron += itemCal * 0.003; // estimation
                    totalPotassium += itemCal * 0.5; // estimation
                    totalVitaminC += itemCal * 0.02; // estimation
                    totalVitaminD += itemCal * 0.002; // estimation
                    totalVitaminA += itemCal * 0.1; // estimation
                }
            }
        }

        // Calculer le score nutritionnel
        int nutritionScore = calculateNutritionScore(totalCalories, totalProtein, totalCarbs, totalFat, totalFiber);

        // Générer une recommandation basée sur les données
        String recommendation = generateRecommendation(totalCalories, totalProtein, totalCarbs, totalFat, totalFiber, nutritionScore);

        // Valeurs par défaut des objectifs
        double caloriesGoal = 2000.0;
        double proteinGoal = 50.0;
        double carbsGoal = 260.0;
        double fatGoal = 70.0;
        double fiberGoal = 25.0;

        // Estimer les micronutriments supplémentaires
        double totalMagnesium = totalCalories * 0.15; // estimation ~300mg pour 2000kcal
        double totalZinc = totalCalories * 0.005; // estimation ~10mg pour 2000kcal
        double totalVitaminE = totalCalories * 0.007; // estimation ~15mg pour 2000kcal
        double totalVitaminB12 = totalCalories * 0.001; // estimation ~2µg pour 2000kcal
        double totalOmega3 = totalFat * 0.05; // estimation ~5% des lipides

        return DailySummaryResponse.builder()
                .date(date)
                .totalCalories(totalCalories)
                .totalProtein(totalProtein)
                .totalCarbs(totalCarbs)
                .totalFat(totalFat)
                .totalFiber(totalFiber)
                .totalSugars(totalSugars)
                .totalSaturatedFat(totalSaturatedFat)
                .totalUnsaturatedFat(totalUnsaturatedFat)
                .totalCholesterol(totalCholesterol)
                .totalOmega3(totalOmega3)
                .totalSodium(totalSodium)
                .totalCalcium(totalCalcium)
                .totalIron(totalIron)
                .totalPotassium(totalPotassium)
                .totalMagnesium(totalMagnesium)
                .totalZinc(totalZinc)
                .totalVitaminA(totalVitaminA)
                .totalVitaminC(totalVitaminC)
                .totalVitaminD(totalVitaminD)
                .totalVitaminE(totalVitaminE)
                .totalVitaminB12(totalVitaminB12)
                .caloriesGoal(caloriesGoal)
                .proteinGoal(proteinGoal)
                .carbsGoal(carbsGoal)
                .fatGoal(fatGoal)
                .fiberGoal(fiberGoal)
                .caloriesPercentOfGoal((totalCalories / caloriesGoal) * 100)
                .proteinPercentOfGoal((totalProtein / proteinGoal) * 100)
                .carbsPercentOfGoal((totalCarbs / carbsGoal) * 100)
                .fatPercentOfGoal((totalFat / fatGoal) * 100)
                .fiberPercentOfGoal((totalFiber / fiberGoal) * 100)
                .nutritionScore(nutritionScore)
                .recommendation(recommendation)
                .mealsCount(meals.size())
                .build();
    }

    private int calculateNutritionScore(double cal, double pro, double carb, double fat, double fiber) {
        if (cal == 0) return 50;

        int score = 50; // Score de base

        // Ratio protéines (optimal: 15-25% des calories)
        double proRatio = (pro * 4 / cal) * 100;
        if (proRatio >= 15 && proRatio <= 25) score += 15;
        else if (proRatio >= 10 && proRatio <= 30) score += 8;

        // Ratio glucides (optimal: 45-55% des calories)
        double carbRatio = (carb * 4 / cal) * 100;
        if (carbRatio >= 45 && carbRatio <= 55) score += 15;
        else if (carbRatio >= 40 && carbRatio <= 65) score += 8;

        // Ratio lipides (optimal: 20-35% des calories)
        double fatRatio = (fat * 9 / cal) * 100;
        if (fatRatio >= 20 && fatRatio <= 35) score += 15;
        else if (fatRatio >= 15 && fatRatio <= 40) score += 8;

        // Bonus fibres
        if (fiber >= 25) score += 5;
        else if (fiber >= 15) score += 3;

        return Math.min(100, Math.max(0, score));
    }

    private String generateRecommendation(double cal, double pro, double carb, double fat, double fiber, int score) {
        List<String> tips = new java.util.ArrayList<>();

        if (cal < 1200) {
            tips.add("Apport calorique faible - mangez plus pour éviter la fatigue");
        } else if (cal > 2500) {
            tips.add("Attention à l'excès calorique");
        }

        double proRatio = cal > 0 ? (pro * 4 / cal) * 100 : 0;
        if (proRatio < 15) {
            tips.add("Augmentez vos protéines (viandes, légumineuses, œufs)");
        }

        if (fiber < 20) {
            tips.add("Mangez plus de fibres (fruits, légumes, céréales complètes)");
        }

        double fatRatio = cal > 0 ? (fat * 9 / cal) * 100 : 0;
        if (fatRatio > 40) {
            tips.add("Réduisez les graisses, privilégiez les huiles végétales");
        }

        if (tips.isEmpty()) {
            if (score >= 80) return "Excellent équilibre nutritionnel ! Continuez ainsi ! 🌟";
            if (score >= 60) return "Bon équilibre ! Quelques ajustements possibles.";
            return "Journée correcte. Variez davantage votre alimentation.";
        }

        return String.join(" • ", tips);
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

