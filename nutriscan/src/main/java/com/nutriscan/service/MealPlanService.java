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
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MealPlanService {

    private final MealPlanRepository mealPlanRepository;
    private final UserRepository userRepository;
    private final GeminiAIService geminiAIService;  // Utilise le nouveau service AI unifié
    private final GoalsService goalsService;
    private final ObjectMapper objectMapper;

    @Transactional
    public MealPlanResponse generateMealPlan(Long userId, GenerateMealPlanRequest request) {
        log.info("Generating meal plan for user {} from {} to {}", userId, request.getStartDate(), request.getEndDate());

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));

        // Get user's goals
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

        long days = ChronoUnit.DAYS.between(request.getStartDate(), request.getEndDate()) + 1;

        // OPTIMISATION: Générer tout le plan en UN SEUL appel à Gemini AI
        log.info("🚀 Generating full {} day meal plan with Gemini AI...", days);

        Map<String, Map<String, RecipeResponse>> fullPlan = geminiAIService.generateFullMealPlan(
                userId,
                request.getStartDate(),
                (int) days,
                targetCalories,
                request.getHealthPreferences(),
                request.getExcludedIngredients()
        );

        double totalCalories = 0.0;
        double totalProtein = 0.0;
        double totalCarbs = 0.0;
        double totalFat = 0.0;

        if (!fullPlan.isEmpty()) {
            // Utiliser le plan généré par Gemini
            for (int i = 0; i < days; i++) {
                LocalDate currentDate = request.getStartDate().plusDays(i);
                String dateKey = currentDate.toString();
                Map<String, RecipeResponse> dayMeals = fullPlan.get(dateKey);

                if (dayMeals != null) {
                    for (Map.Entry<String, RecipeResponse> entry : dayMeals.entrySet()) {
                        String mealType = entry.getKey();
                        RecipeResponse recipe = entry.getValue();

                        PlannedMeal meal = createPlannedMealFromRecipe(currentDate, mealType, recipe, mealPlan);
                        if (meal != null) {
                            mealPlan.getPlannedMeals().add(meal);
                            totalCalories += meal.getCalories() != null ? meal.getCalories() : 0;
                            totalProtein += meal.getProtein() != null ? meal.getProtein() : 0;
                            totalCarbs += meal.getCarbs() != null ? meal.getCarbs() : 0;
                            totalFat += meal.getFat() != null ? meal.getFat() : 0;
                        }
                    }
                }
            }
            log.info("✅ Generated {} meals from Gemini full plan", mealPlan.getPlannedMeals().size());
        }

        // Si Gemini n'a rien retourné ou retourné partiellement, compléter avec des recettes par défaut
        if (mealPlan.getPlannedMeals().size() < days * 4) {
            log.info("⚠️ Completing plan with default recipes...");
            for (int i = 0; i < days; i++) {
                LocalDate currentDate = request.getStartDate().plusDays(i);

                // Vérifier quels repas manquent pour ce jour
                List<String> existingMealTypes = mealPlan.getPlannedMeals().stream()
                        .filter(m -> m.getDate().equals(currentDate))
                        .map(PlannedMeal::getMealType)
                        .toList();

                for (String mealType : List.of("BREAKFAST", "LUNCH", "DINNER", "SNACK")) {
                    if (!existingMealTypes.contains(mealType)) {
                        int mealCalories = getMealCalories(targetCalories, mealType);
                        RecipeResponse defaultRecipe = createDefaultRecipe(mealType, mealCalories);
                        PlannedMeal meal = createPlannedMealFromRecipe(currentDate, mealType, defaultRecipe, mealPlan);
                        if (meal != null) {
                            mealPlan.getPlannedMeals().add(meal);
                            totalCalories += meal.getCalories() != null ? meal.getCalories() : 0;
                            totalProtein += meal.getProtein() != null ? meal.getProtein() : 0;
                            totalCarbs += meal.getCarbs() != null ? meal.getCarbs() : 0;
                            totalFat += meal.getFat() != null ? meal.getFat() : 0;
                        }
                    }
                }
            }
        }

        if (mealPlan.getPlannedMeals().isEmpty()) {
            log.error("No meals could be generated for the entire meal plan period");
            throw new RuntimeException("Could not generate meal plan: No recipes found. Please try with different criteria.");
        }

        mealPlan.setTotalCalories(totalCalories);
        mealPlan.setTotalProtein(totalProtein);
        mealPlan.setTotalCarbs(totalCarbs);
        mealPlan.setTotalFat(totalFat);

        log.info("💾 Saving meal plan with {} meals, total calories: {}", mealPlan.getPlannedMeals().size(), totalCalories);
        mealPlan = mealPlanRepository.save(mealPlan);

        return mapToResponse(mealPlan);
    }

    private int getMealCalories(int dailyTotal, String mealType) {
        return switch (mealType) {
            case "BREAKFAST" -> (int) (dailyTotal * 0.25);
            case "LUNCH" -> (int) (dailyTotal * 0.35);
            case "DINNER" -> (int) (dailyTotal * 0.30);
            case "SNACK" -> (int) (dailyTotal * 0.10);
            default -> (int) (dailyTotal * 0.25);
        };
    }

    private PlannedMeal createPlannedMealFromRecipe(LocalDate date, String mealType, RecipeResponse recipe, MealPlan mealPlan) {
        if (recipe == null) return null;

        PlannedMeal meal = PlannedMeal.builder()
                .mealPlan(mealPlan)
                .date(date)
                .mealType(mealType)
                .recipeName(recipe.getLabel())
                .recipeUri(recipe.getUri())
                .recipeImage(recipe.getImage())
                .recipeUrl(recipe.getUrl())
                .servings(recipe.getServings() != null ? recipe.getServings() : 2)
                .calories(recipe.getCalories())
                .build();

        if (recipe.getNutrition() != null) {
            meal.setProtein(recipe.getNutrition().getProtein());
            meal.setCarbs(recipe.getNutrition().getCarbs());
            meal.setFat(recipe.getNutrition().getFat());
        }

        if (recipe.getIngredientLines() != null && !recipe.getIngredientLines().isEmpty()) {
            try {
                meal.setIngredients(objectMapper.writeValueAsString(recipe.getIngredientLines()));
            } catch (Exception e) {
                log.error("Error serializing ingredients", e);
            }
        }

        return meal;
    }

    private List<PlannedMeal> generateDailyMeals(LocalDate date, int targetCalories, GenerateMealPlanRequest request, MealPlan mealPlan) {
        List<PlannedMeal> meals = new ArrayList<>();
        Long userId = mealPlan.getUser().getId();

        // Distribute calories: Breakfast 25%, Lunch 35%, Dinner 30%, Snack 10%
        int breakfastCal = (int) (targetCalories * 0.25);
        int lunchCal = (int) (targetCalories * 0.35);
        int dinnerCal = (int) (targetCalories * 0.30);
        int snackCal = (int) (targetCalories * 0.10);

        // Generate breakfast
        PlannedMeal breakfast = findAndCreatePlannedMeal(date, "BREAKFAST", breakfastCal, request, mealPlan, userId);
        if (breakfast != null) meals.add(breakfast);

        // Generate lunch
        PlannedMeal lunch = findAndCreatePlannedMeal(date, "LUNCH", lunchCal, request, mealPlan, userId);
        if (lunch != null) meals.add(lunch);

        // Generate dinner
        PlannedMeal dinner = findAndCreatePlannedMeal(date, "DINNER", dinnerCal, request, mealPlan, userId);
        if (dinner != null) meals.add(dinner);

        // Generate snack
        PlannedMeal snack = findAndCreatePlannedMeal(date, "SNACK", snackCal, request, mealPlan, userId);
        if (snack != null) meals.add(snack);

        return meals;
    }

    private PlannedMeal findAndCreatePlannedMeal(LocalDate date, String mealType, int calories, GenerateMealPlanRequest request, MealPlan mealPlan, Long userId) {
        RecipeResponse recipe = null;

        // Utiliser Gemini AI pour générer des recettes personnalisées
        try {
            log.info("🤖 Generating personalized {} recipe with Gemini AI for user {} (~{} cal)...", mealType, userId, calories);
            List<RecipeResponse> geminiRecipes = geminiAIService.generateRecipes(
                    userId,
                    mealType,
                    calories,
                    request.getHealthPreferences(),
                    request.getExcludedIngredients()
            );

            if (geminiRecipes != null && !geminiRecipes.isEmpty()) {
                recipe = geminiRecipes.get(0);
                log.info("✅ Gemini generated recipe for {}: {} ({} cal)", mealType, recipe.getLabel(), recipe.getCalories());
            } else {
                log.warn("⚠️ Gemini returned no recipes for {}", mealType);
            }
        } catch (Exception e) {
            log.error("❌ Gemini API failed for {}: {}", mealType, e.getMessage());
        }

        // 2. Si Gemini échoue, créer une recette par défaut (pas d'appel à Edamam car épuisé)
        if (recipe == null) {
            log.warn("⚠️ Creating default recipe for {} as fallback", mealType);
            recipe = createDefaultRecipe(mealType, calories);
        }

        if (recipe == null) {
            log.error("❌ Could not create any recipe for {} with {} calories", mealType, calories);
            return null;
        }

        // Créer le repas planifié
        PlannedMeal plannedMeal = PlannedMeal.builder()
                .mealPlan(mealPlan)
                .date(date)
                .mealType(mealType)
                .recipeName(recipe.getLabel())
                .recipeUri(recipe.getUri())
                .recipeImage(recipe.getImage())
                .recipeUrl(recipe.getUrl())
                .servings(recipe.getServings() != null ? recipe.getServings() : 2)
                .calories(recipe.getCalories() != null ? recipe.getCalories() : (double) calories)
                .build();

        // Nutrition
        if (recipe.getNutrition() != null) {
            plannedMeal.setProtein(recipe.getNutrition().getProtein());
            plannedMeal.setCarbs(recipe.getNutrition().getCarbs());
            plannedMeal.setFat(recipe.getNutrition().getFat());
        } else {
            // Valeurs par défaut basées sur les calories
            plannedMeal.setProtein(calories * 0.15 / 4); // 15% des calories en protéines
            plannedMeal.setCarbs(calories * 0.50 / 4);   // 50% des calories en glucides
            plannedMeal.setFat(calories * 0.35 / 9);     // 35% des calories en lipides
        }

        // Ingrédients
        if (recipe.getIngredientLines() != null && !recipe.getIngredientLines().isEmpty()) {
            try {
                plannedMeal.setIngredients(objectMapper.writeValueAsString(recipe.getIngredientLines()));
            } catch (Exception e) {
                log.error("Error serializing ingredients", e);
            }
        }

        return plannedMeal;
    }

    /**
     * Crée une recette par défaut quand aucune API ne répond
     */
    private RecipeResponse createDefaultRecipe(String mealType, int calories) {
        RecipeResponse recipe = new RecipeResponse();
        java.util.Random random = new java.util.Random();

        switch (mealType.toUpperCase()) {
            case "BREAKFAST" -> {
                String[][] breakfasts = {
                    {"Petit-déjeuner aux œufs", "2 œufs brouillés", "2 tranches de pain complet", "1 orange", "Café ou thé"},
                    {"Bowl d'avoine aux fruits", "60g flocons d'avoine", "200ml lait", "1 banane", "Myrtilles", "1 c.s. miel"},
                    {"Tartines avocat œuf", "2 tranches pain complet", "1/2 avocat", "1 œuf poché", "Tomates cerises"},
                    {"Yaourt granola fruits", "200g yaourt grec", "40g granola", "Fruits de saison", "Noix concassées"},
                    {"Pancakes protéinés", "2 pancakes", "Sirop d'érable", "Fruits rouges", "1 yaourt"}
                };
                int idx = random.nextInt(breakfasts.length);
                recipe.setLabel(breakfasts[idx][0]);
                recipe.setIngredientLines(List.of(java.util.Arrays.copyOfRange(breakfasts[idx], 1, breakfasts[idx].length)));
            }
            case "LUNCH" -> {
                String[][] lunches = {
                    {"Salade César au poulet", "150g poulet grillé", "Salade romaine", "Croûtons", "Parmesan", "Sauce César légère"},
                    {"Buddha bowl quinoa", "150g quinoa cuit", "Pois chiches rôtis", "Légumes variés", "Sauce tahini"},
                    {"Wrap poulet avocat", "1 tortilla complète", "120g poulet", "1/2 avocat", "Crudités", "Sauce yaourt"},
                    {"Pâtes au pesto maison", "80g pâtes complètes", "Pesto basilic", "Tomates cerises", "Mozzarella", "Pignons"},
                    {"Riz sauté aux légumes", "150g riz", "Légumes wok", "Sauce soja", "Œuf", "Sésame"}
                };
                int idx = random.nextInt(lunches.length);
                recipe.setLabel(lunches[idx][0]);
                recipe.setIngredientLines(List.of(java.util.Arrays.copyOfRange(lunches[idx], 1, lunches[idx].length)));
            }
            case "DINNER" -> {
                String[][] dinners = {
                    {"Saumon grillé légumes", "150g pavé de saumon", "Brocolis vapeur", "Riz basmati", "Citron", "Aneth"},
                    {"Poulet rôti aux herbes", "150g filet de poulet", "Pommes de terre rôties", "Haricots verts", "Thym", "Romarin"},
                    {"Curry de légumes", "Légumes variés", "Lait de coco", "Pâte de curry", "Riz basmati", "Coriandre"},
                    {"Steak haricots verts", "150g steak", "200g haricots verts", "Échalotes", "Persil", "Huile d'olive"},
                    {"Poisson blanc purée", "150g cabillaud", "200g purée maison", "Épinards", "Beurre", "Muscade"}
                };
                int idx = random.nextInt(dinners.length);
                recipe.setLabel(dinners[idx][0]);
                recipe.setIngredientLines(List.of(java.util.Arrays.copyOfRange(dinners[idx], 1, dinners[idx].length)));
            }
            case "SNACK" -> {
                String[][] snacks = {
                    {"Fruits secs et noix", "30g amandes", "30g noix de cajou", "Raisins secs"},
                    {"Smoothie protéiné", "1 banane", "200ml lait", "1 c.s. beurre cacahuète", "Cacao"},
                    {"Yaourt aux fruits", "150g yaourt grec", "Fruits frais", "1 c.c. miel"},
                    {"Tartine beurre cacahuète", "1 tranche pain complet", "2 c.s. beurre cacahuète", "1/2 banane"},
                    {"Fromage et crackers", "30g fromage", "4 crackers complets", "Quelques raisins"}
                };
                int idx = random.nextInt(snacks.length);
                recipe.setLabel(snacks[idx][0]);
                recipe.setIngredientLines(List.of(java.util.Arrays.copyOfRange(snacks[idx], 1, snacks[idx].length)));
            }
            default -> {
                recipe.setLabel("Repas équilibré");
                recipe.setIngredientLines(List.of("Protéines au choix", "Féculents complets", "Légumes de saison", "Huile d'olive"));
            }
        }

        recipe.setUri("nutriscan-" + mealType.toLowerCase() + "-" + System.currentTimeMillis());
        recipe.setCalories((double) calories);
        recipe.setServings(1);
        recipe.setSource("NutriScan");

        RecipeResponse.NutritionInfo nutrition = new RecipeResponse.NutritionInfo();
        nutrition.setProtein(calories * 0.20 / 4);
        nutrition.setCarbs(calories * 0.45 / 4);
        nutrition.setFat(calories * 0.35 / 9);
        recipe.setNutrition(nutrition);

        log.info("📝 Created default recipe: {} ({} cal)", recipe.getLabel(), calories);

        return recipe;
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
                            .id(pm.getId())
                            .date(pm.getDate())
                            .mealType(pm.getMealType())
                            .recipeName(pm.getRecipeName())
                            .recipeUri(pm.getRecipeUri())
                            .recipeImage(pm.getRecipeImage())
                            .recipeUrl(pm.getRecipeUrl())
                            .servings(pm.getServings())
                            .calories(pm.getCalories())
                            .protein(pm.getProtein())
                            .carbs(pm.getCarbs())
                            .fat(pm.getFat())
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

    /**
     * Ajouter une recette au plan de repas existant
     */
    @Transactional
    public MealPlanResponse addRecipeToPlan(Long userId, Long planId, Map<String, Object> recipeData) {
        MealPlan plan = mealPlanRepository.findById(planId)
                .orElseThrow(() -> new NotFoundException("Meal plan not found"));

        if (!plan.getUser().getId().equals(userId)) {
            throw new NotFoundException("Meal plan not found");
        }

        // Extraire les données de la recette
        LocalDate date = LocalDate.parse((String) recipeData.get("date"));
        String mealType = (String) recipeData.get("mealType");
        String recipeName = (String) recipeData.get("recipeName");
        String recipeUri = (String) recipeData.getOrDefault("recipeUri", null);
        String recipeImage = (String) recipeData.getOrDefault("recipeImage", null);
        int servings = recipeData.get("servings") != null ? ((Number) recipeData.get("servings")).intValue() : 1;
        double calories = recipeData.get("calories") != null ? ((Number) recipeData.get("calories")).doubleValue() : 0;
        double protein = recipeData.get("protein") != null ? ((Number) recipeData.get("protein")).doubleValue() : 0;
        double carbs = recipeData.get("carbs") != null ? ((Number) recipeData.get("carbs")).doubleValue() : 0;
        double fat = recipeData.get("fat") != null ? ((Number) recipeData.get("fat")).doubleValue() : 0;

        // Créer le repas planifié
        PlannedMeal newMeal = PlannedMeal.builder()
                .mealPlan(plan)
                .date(date)
                .mealType(mealType)
                .recipeName(recipeName)
                .recipeUri(recipeUri)
                .recipeImage(recipeImage)
                .servings(servings)
                .calories(calories)
                .protein(protein)
                .carbs(carbs)
                .fat(fat)
                .build();

        // Sérialiser les ingrédients si fournis
        if (recipeData.get("ingredients") != null) {
            try {
                newMeal.setIngredients(objectMapper.writeValueAsString(recipeData.get("ingredients")));
            } catch (Exception e) {
                log.error("Error serializing ingredients", e);
            }
        }

        plan.getPlannedMeals().add(newMeal);

        // Mettre à jour les totaux
        plan.setTotalCalories(plan.getTotalCalories() + calories);
        plan.setTotalProtein(plan.getTotalProtein() + protein);
        plan.setTotalCarbs(plan.getTotalCarbs() + carbs);
        plan.setTotalFat(plan.getTotalFat() + fat);

        mealPlanRepository.save(plan);
        log.info("✅ Added recipe '{}' to plan {} for {}", recipeName, planId, date);

        return mapToResponse(plan);
    }

    /**
     * Supprimer un repas du plan
     */
    @Transactional
    public MealPlanResponse removeMealFromPlan(Long userId, Long planId, Long mealId) {
        MealPlan plan = mealPlanRepository.findById(planId)
                .orElseThrow(() -> new NotFoundException("Meal plan not found"));

        if (!plan.getUser().getId().equals(userId)) {
            throw new NotFoundException("Meal plan not found");
        }

        PlannedMeal mealToRemove = plan.getPlannedMeals().stream()
                .filter(m -> m.getId().equals(mealId))
                .findFirst()
                .orElseThrow(() -> new NotFoundException("Meal not found in plan"));

        // Mettre à jour les totaux
        plan.setTotalCalories(plan.getTotalCalories() - (mealToRemove.getCalories() != null ? mealToRemove.getCalories() : 0));
        plan.setTotalProtein(plan.getTotalProtein() - (mealToRemove.getProtein() != null ? mealToRemove.getProtein() : 0));
        plan.setTotalCarbs(plan.getTotalCarbs() - (mealToRemove.getCarbs() != null ? mealToRemove.getCarbs() : 0));
        plan.setTotalFat(plan.getTotalFat() - (mealToRemove.getFat() != null ? mealToRemove.getFat() : 0));

        plan.getPlannedMeals().remove(mealToRemove);
        mealPlanRepository.save(plan);

        log.info("🗑️ Removed meal '{}' from plan {}", mealToRemove.getRecipeName(), planId);

        return mapToResponse(plan);
    }
}

