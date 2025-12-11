package com.nutriscan.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.request.GenerateMealPlanRequest;
import com.nutriscan.dto.response.MealPlanResponse;
import com.nutriscan.dto.response.RecipeResponse;
import com.nutriscan.exception.NotFoundException;
import com.nutriscan.model.*;
import com.nutriscan.repository.MealPlanRepository;
import com.nutriscan.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MealPlanService {

    private final MealPlanRepository mealPlanRepository;
    private final UserRepository userRepository;
    private final EdamamRecipeService recipeService;
    private final GoalsService goalsService;
    private final ObjectMapper objectMapper;

    @Transactional
    public MealPlanResponse generateMealPlan(Long userId, GenerateMealPlanRequest request) {
        log.info("Generating meal plan for user {} from {} to {}", userId, request.getStartDate(), request.getEndDate());

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        // Get user's goals - getGoalsForUser returns GoalsResponse which has getTargetCalories()
        com.nutriscan.dto.response.GoalsResponse userGoals = goalsService.getGoalsForUser(userId);
        int targetCalories = request.getTargetCalories() != null ?
                request.getTargetCalories() :
                (userGoals != null && userGoals.getTargetCalories() != null ?
                    userGoals.getTargetCalories().intValue() : 2000);

        log.info("Target calories for meal plan: {}", targetCalories);

        // Create meal plan
        MealPlan mealPlan = MealPlan.builder()
                .user(user)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .planType(request.getPlanType() != null ? request.getPlanType() : "WEEKLY")
                .plannedMeals(new ArrayList<>())
                .build();

        // Generate meals for each day
        long days = ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate()) + 1;
        LocalDate currentDate = request.getStartDate();

        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;

        for (int i = 0; i < days; i++) {
            log.info("Generating meals for day {}/{} ({})", i + 1, days, currentDate);
            List<PlannedMeal> dailyMeals = generateDailyMeals(currentDate, targetCalories, request, mealPlan);

            if (dailyMeals.isEmpty()) {
                log.warn("No meals generated for day {}", currentDate);
            } else {
                log.info("Generated {} meals for {}", dailyMeals.size(), currentDate);
            }

            mealPlan.getPlannedMeals().addAll(dailyMeals);

            // Sum totals
            for (PlannedMeal meal : dailyMeals) {
                totalCalories += meal.getCalories() != null ? meal.getCalories() : 0;
                totalProtein += meal.getProtein() != null ? meal.getProtein() : 0;
                totalCarbs += meal.getCarbs() != null ? meal.getCarbs() : 0;
                totalFat += meal.getFat() != null ? meal.getFat() : 0;
            }

            currentDate = currentDate.plusDays(1);
        }

        if (mealPlan.getPlannedMeals().isEmpty()) {
            log.error("No meals could be generated for the entire meal plan period");
            throw new RuntimeException("Could not generate meal plan: No recipes found. Please try with different criteria.");
        }

        mealPlan.setTotalCalories(totalCalories);
        mealPlan.setTotalProtein(totalProtein);
        mealPlan.setTotalCarbs(totalCarbs);
        mealPlan.setTotalFat(totalFat);

        log.info("Saving meal plan with {} meals, total calories: {}", mealPlan.getPlannedMeals().size(), totalCalories);
        mealPlan = mealPlanRepository.save(mealPlan);

        return mapToResponse(mealPlan);
    }

    private List<PlannedMeal> generateDailyMeals(LocalDate date, int targetCalories, GenerateMealPlanRequest request, MealPlan mealPlan) {
        List<PlannedMeal> meals = new ArrayList<>();

        // Distribute calories: Breakfast 25%, Lunch 35%, Dinner 30%, Snack 10%
        int breakfastCal = (int) (targetCalories * 0.25);
        int lunchCal = (int) (targetCalories * 0.35);
        int dinnerCal = (int) (targetCalories * 0.30);
        int snackCal = (int) (targetCalories * 0.10);

        // Generate breakfast
        PlannedMeal breakfast = findAndCreatePlannedMeal(date, "BREAKFAST", breakfastCal, request, mealPlan);
        if (breakfast != null) meals.add(breakfast);

        // Generate lunch
        PlannedMeal lunch = findAndCreatePlannedMeal(date, "LUNCH", lunchCal, request, mealPlan);
        if (lunch != null) meals.add(lunch);

        // Generate dinner
        PlannedMeal dinner = findAndCreatePlannedMeal(date, "DINNER", dinnerCal, request, mealPlan);
        if (dinner != null) meals.add(dinner);

        // Generate snack
        PlannedMeal snack = findAndCreatePlannedMeal(date, "SNACK", snackCal, request, mealPlan);
        if (snack != null) meals.add(snack);

        return meals;
    }

    private PlannedMeal findAndCreatePlannedMeal(LocalDate date, String mealType, int calories, GenerateMealPlanRequest request, MealPlan mealPlan) {
        try {
            // Build search query based on meal type
            String query = getQueryForMealType(mealType);

            List<RecipeResponse> recipes = recipeService.searchRecipes(
                    query,
                    request.getDietaryRestrictions(),
                    request.getHealthPreferences(),
                    request.getCuisine(),
                    mealType.toLowerCase(),
                    calories,
                    5 // Get 5 recipes and pick first one
            );

            if (recipes.isEmpty()) {
                log.warn("No recipes found for {} with {} calories", mealType, calories);
                return null;
            }

            RecipeResponse recipe = recipes.getFirst(); // Pick first recipe

            // Create planned meal
            PlannedMeal plannedMeal = PlannedMeal.builder()
                    .mealPlan(mealPlan)
                    .date(date)
                    .mealType(mealType)
                    .recipeName(recipe.getLabel())
                    .recipeUri(recipe.getUri())
                    .recipeImage(recipe.getImage())
                    .recipeUrl(recipe.getUrl())
                    .servings(recipe.getServings())
                    .calories(recipe.getCalories())
                    .build();

            // Set nutrition if available
            if (recipe.getNutrition() != null) {
                plannedMeal.setProtein(recipe.getNutrition().getProtein());
                plannedMeal.setCarbs(recipe.getNutrition().getCarbs());
                plannedMeal.setFat(recipe.getNutrition().getFat());
            }

            // Store ingredients as JSON
            if (recipe.getIngredientLines() != null && !recipe.getIngredientLines().isEmpty()) {
                try {
                    plannedMeal.setIngredients(objectMapper.writeValueAsString(recipe.getIngredientLines()));
                } catch (Exception e) {
                    log.error("Error serializing ingredients", e);
                }
            }

            return plannedMeal;

        } catch (Exception e) {
            log.error("Error creating planned meal for {}: {}", mealType, e.getMessage(), e);
            return null;
        }
    }

    private String getQueryForMealType(String mealType) {
        return switch (mealType) {
            case "BREAKFAST" -> "breakfast";
            case "LUNCH" -> "lunch main dish";
            case "DINNER" -> "dinner main course";
            case "SNACK" -> "healthy snack";
            default -> "meal";
        };
    }

    public List<MealPlanResponse> getUserMealPlans(Long userId) {
        List<MealPlan> plans = mealPlanRepository.findByUserId(userId);
        return plans.stream().map(this::mapToResponse).collect(Collectors.toList());
    }

    public MealPlanResponse getLatestMealPlan(Long userId) {
        List<MealPlan> plans = mealPlanRepository.findByUserId(userId);

        if (plans.isEmpty()) {
            throw new NotFoundException("No meal plans found. Please create a meal plan first.");
        }

        // findByUserId already orders by startDate DESC, so first one is the latest
        return mapToResponse(plans.get(0));
    }

    public MealPlanResponse getMealPlanById(Long userId, Long planId) {
        MealPlan plan = mealPlanRepository.findById(planId)
                .orElseThrow(() -> new NotFoundException("Meal plan not found"));

        if (!plan.getUser().getId().equals(userId)) {
            throw new NotFoundException("Meal plan not found");
        }

        return mapToResponse(plan);
    }

    @Transactional
    public void deleteMealPlan(Long userId, Long planId) {
        MealPlan plan = mealPlanRepository.findById(planId)
                .orElseThrow(() -> new NotFoundException("Meal plan not found"));

        if (!plan.getUser().getId().equals(userId)) {
            throw new NotFoundException("Meal plan not found");
        }

        mealPlanRepository.delete(plan);
    }

    private MealPlanResponse mapToResponse(MealPlan plan) {
        List<MealPlanResponse.PlannedMeal> plannedMeals = plan.getPlannedMeals().stream()
                .map(pm -> {
                    List<String> ingredients = new ArrayList<>();
                    if (pm.getIngredients() != null) {
                        try {
                            ingredients = objectMapper.readValue(pm.getIngredients(), new TypeReference<>() {});
                        } catch (Exception e) {
                            log.error("Error deserializing ingredients", e);
                        }
                    }

                    return MealPlanResponse.PlannedMeal.builder()
                            .date(pm.getDate())
                            .mealType(pm.getMealType())
                            .recipeName(pm.getRecipeName())
                            .recipeUri(pm.getRecipeUri())
                            .recipeImage(pm.getRecipeImage())
                            .servings(pm.getServings())
                            .calories(pm.getCalories())
                            .ingredients(ingredients)
                            .build();
                })
                .collect(Collectors.toList());

        return MealPlanResponse.builder()
                .id(plan.getId())
                .userId(plan.getUser().getId())
                .startDate(plan.getStartDate())
                .endDate(plan.getEndDate())
                .planType(plan.getPlanType())
                .meals(plannedMeals)
                .totalCalories(plan.getTotalCalories())
                .totalProtein(plan.getTotalProtein())
                .totalCarbs(plan.getTotalCarbs())
                .totalFat(plan.getTotalFat())
                .build();
    }
}

