package com.nutriscan.service;

import com.nutriscan.dto.response.RecipeResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Fallback recipe service with static recipes when Edamam API is unavailable
 */
@Service
@Slf4j
public class FallbackRecipeService {

    private final List<RecipeResponse> staticRecipes = new ArrayList<>();

    public FallbackRecipeService() {
        initializeStaticRecipes();
    }

    private void initializeStaticRecipes() {
        // Breakfast recipes
        staticRecipes.add(createRecipe(
                "Oatmeal with Berries",
                "BREAKFAST",
                List.of("1 cup oats", "1 cup milk", "1/2 cup mixed berries", "1 tbsp honey"),
                350.0, 12.0, 58.0, 8.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Scrambled Eggs with Toast",
                "BREAKFAST",
                List.of("3 eggs", "2 slices whole wheat bread", "1 tsp butter", "Salt and pepper"),
                420.0, 22.0, 32.0, 20.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Greek Yogurt Parfait",
                "BREAKFAST",
                List.of("1 cup Greek yogurt", "1/2 cup granola", "1/2 cup mixed berries", "1 tbsp honey"),
                380.0, 18.0, 52.0, 10.0, 1
        ));

        // Poulet - Chicken recipes
        staticRecipes.add(createRecipe(
                "Poulet Grillé aux Herbes",
                "LUNCH",
                List.of("200g de blanc de poulet", "Herbes de Provence", "2 cuillères d'huile d'olive", "Citron", "Ail"),
                420.0, 45.0, 5.0, 22.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Poulet Rôti au Four",
                "DINNER",
                List.of("1 poulet entier", "Pommes de terre", "Carottes", "Oignon", "Thym", "Romarin"),
                550.0, 42.0, 35.0, 28.0, 4
        ));

        staticRecipes.add(createRecipe(
                "Poulet Curry Coco",
                "DINNER",
                List.of("300g de poulet", "Lait de coco", "Curry", "Oignon", "Tomates", "Riz basmati"),
                620.0, 38.0, 52.0, 28.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Salade César au Poulet",
                "LUNCH",
                List.of("150g de poulet grillé", "Salade romaine", "Croûtons", "Parmesan", "Sauce César"),
                480.0, 38.0, 20.0, 28.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Poulet Teriyaki",
                "DINNER",
                List.of("200g de poulet", "Sauce teriyaki", "Sésame", "Brocoli", "Riz"),
                520.0, 40.0, 48.0, 18.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Poulet à la Marocaine",
                "DINNER",
                List.of("300g de poulet", "Olives", "Citron confit", "Oignon", "Épices ras el hanout"),
                480.0, 42.0, 15.0, 26.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Wrap Poulet Avocat",
                "LUNCH",
                List.of("150g de poulet", "Tortilla", "Avocat", "Tomate", "Salade", "Sauce yaourt"),
                450.0, 35.0, 38.0, 18.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Poulet Basquaise",
                "DINNER",
                List.of("400g de poulet", "Poivrons", "Tomates", "Oignon", "Jambon de Bayonne", "Piment d'Espelette"),
                520.0, 45.0, 22.0, 25.0, 4
        ));

        // Lunch recipes
        staticRecipes.add(createRecipe(
                "Grilled Chicken Salad",
                "LUNCH",
                List.of("150g grilled chicken breast", "Mixed greens", "Cherry tomatoes", "Cucumber", "Olive oil dressing"),
                480.0, 38.0, 15.0, 28.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Quinoa Buddha Bowl",
                "LUNCH",
                List.of("1 cup cooked quinoa", "Chickpeas", "Roasted vegetables", "Tahini dressing"),
                520.0, 18.0, 68.0, 18.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Turkey Sandwich",
                "LUNCH",
                List.of("100g turkey breast", "Whole wheat bread", "Lettuce", "Tomato", "Mustard"),
                450.0, 32.0, 48.0, 12.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Vegetable Stir Fry with Rice",
                "LUNCH",
                List.of("Mixed vegetables", "1 cup brown rice", "Soy sauce", "Ginger", "Garlic"),
                490.0, 12.0, 82.0, 10.0, 2
        ));

        // Dinner recipes
        staticRecipes.add(createRecipe(
                "Baked Salmon with Vegetables",
                "DINNER",
                List.of("150g salmon fillet", "Broccoli", "Carrots", "Olive oil", "Lemon"),
                510.0, 36.0, 18.0, 32.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Chicken Pasta",
                "DINNER",
                List.of("100g chicken breast", "200g whole wheat pasta", "Tomato sauce", "Parmesan"),
                580.0, 38.0, 64.0, 18.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Beef Stir Fry",
                "DINNER",
                List.of("120g lean beef", "Mixed vegetables", "Brown rice", "Soy sauce"),
                520.0, 32.0, 52.0, 18.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Vegetarian Chili",
                "DINNER",
                List.of("Black beans", "Kidney beans", "Tomatoes", "Bell peppers", "Spices"),
                450.0, 18.0, 72.0, 8.0, 4
        ));

        // Snack recipes
        staticRecipes.add(createRecipe(
                "Protein Smoothie",
                "SNACK",
                List.of("1 scoop protein powder", "1 banana", "1 cup milk", "1 tbsp peanut butter"),
                320.0, 28.0, 35.0, 8.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Apple with Almond Butter",
                "SNACK",
                List.of("1 large apple", "2 tbsp almond butter"),
                280.0, 6.0, 38.0, 12.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Mixed Nuts and Dried Fruit",
                "SNACK",
                List.of("1/4 cup mixed nuts", "1/4 cup dried fruit"),
                300.0, 8.0, 32.0, 16.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Hummus with Veggies",
                "SNACK",
                List.of("1/2 cup hummus", "Carrot sticks", "Cucumber slices", "Bell pepper"),
                220.0, 8.0, 24.0, 10.0, 1
        ));

        // More Pasta recipes
        staticRecipes.add(createRecipe(
                "Pasta Carbonara",
                "DINNER",
                List.of("200g spaghetti", "100g pancetta", "2 eggs", "Parmesan cheese", "Black pepper"),
                650.0, 28.0, 72.0, 28.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Pasta Bolognese",
                "DINNER",
                List.of("200g pasta", "300g ground beef", "Tomato sauce", "Onion", "Garlic", "Herbs"),
                620.0, 35.0, 68.0, 22.0, 3
        ));

        staticRecipes.add(createRecipe(
                "Penne Arrabbiata",
                "LUNCH",
                List.of("200g penne", "Tomato sauce", "Chili flakes", "Garlic", "Olive oil", "Basil"),
                480.0, 14.0, 82.0, 12.0, 2
        ));

        // Salad recipes
        staticRecipes.add(createRecipe(
                "Greek Salad",
                "LUNCH",
                List.of("Cucumber", "Tomatoes", "Red onion", "Feta cheese", "Olives", "Olive oil"),
                320.0, 12.0, 18.0, 24.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Tuna Salad",
                "LUNCH",
                List.of("150g canned tuna", "Mixed greens", "Eggs", "Green beans", "Potatoes", "Olives"),
                420.0, 32.0, 22.0, 24.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Avocado Salad",
                "LUNCH",
                List.of("1 avocado", "Cherry tomatoes", "Cucumber", "Red onion", "Lime juice", "Cilantro"),
                280.0, 4.0, 18.0, 22.0, 1
        ));

        // Soup recipes
        staticRecipes.add(createRecipe(
                "Tomato Soup",
                "LUNCH",
                List.of("Tomatoes", "Onion", "Garlic", "Vegetable broth", "Cream", "Basil"),
                180.0, 4.0, 24.0, 8.0, 4
        ));

        staticRecipes.add(createRecipe(
                "Chicken Noodle Soup",
                "DINNER",
                List.of("Chicken breast", "Egg noodles", "Carrots", "Celery", "Chicken broth", "Herbs"),
                320.0, 28.0, 32.0, 8.0, 4
        ));

        staticRecipes.add(createRecipe(
                "Vegetable Soup",
                "LUNCH",
                List.of("Mixed vegetables", "Vegetable broth", "Potatoes", "Tomatoes", "Herbs"),
                150.0, 5.0, 28.0, 3.0, 4
        ));

        // Fish recipes
        staticRecipes.add(createRecipe(
                "Grilled Fish with Lemon",
                "DINNER",
                List.of("200g white fish", "Lemon", "Olive oil", "Garlic", "Fresh herbs"),
                280.0, 38.0, 4.0, 12.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Fish Tacos",
                "DINNER",
                List.of("200g fish fillet", "Tortillas", "Cabbage slaw", "Lime", "Avocado", "Salsa"),
                480.0, 32.0, 42.0, 20.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Tuna Steak",
                "DINNER",
                List.of("200g tuna steak", "Sesame seeds", "Soy sauce", "Ginger", "Wasabi"),
                320.0, 45.0, 4.0, 14.0, 1
        ));

        // Rice dishes
        staticRecipes.add(createRecipe(
                "Fried Rice",
                "DINNER",
                List.of("2 cups rice", "Eggs", "Vegetables", "Soy sauce", "Sesame oil", "Green onions"),
                420.0, 12.0, 68.0, 12.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Rice Bowl with Vegetables",
                "LUNCH",
                List.of("1 cup rice", "Mixed vegetables", "Tofu", "Soy sauce", "Sesame seeds"),
                380.0, 14.0, 62.0, 10.0, 1
        ));

        // Vegetarian recipes
        staticRecipes.add(createRecipe(
                "Vegetable Curry",
                "DINNER",
                List.of("Mixed vegetables", "Coconut milk", "Curry paste", "Rice", "Cilantro"),
                450.0, 12.0, 58.0, 20.0, 2
        ));

        staticRecipes.add(createRecipe(
                "Stuffed Peppers",
                "DINNER",
                List.of("Bell peppers", "Rice", "Black beans", "Corn", "Cheese", "Salsa"),
                380.0, 16.0, 52.0, 12.0, 4
        ));

        staticRecipes.add(createRecipe(
                "Vegetarian Burger",
                "LUNCH",
                List.of("Black bean patty", "Burger bun", "Lettuce", "Tomato", "Avocado", "Sauce"),
                420.0, 18.0, 48.0, 18.0, 1
        ));

        // Beef recipes
        staticRecipes.add(createRecipe(
                "Beef Tacos",
                "DINNER",
                List.of("200g ground beef", "Taco shells", "Lettuce", "Cheese", "Salsa", "Sour cream"),
                520.0, 28.0, 38.0, 28.0, 3
        ));

        staticRecipes.add(createRecipe(
                "Steak with Vegetables",
                "DINNER",
                List.of("200g beef steak", "Roasted vegetables", "Garlic butter", "Herbs"),
                520.0, 42.0, 18.0, 32.0, 1
        ));

        staticRecipes.add(createRecipe(
                "Beef Stroganoff",
                "DINNER",
                List.of("300g beef strips", "Mushrooms", "Sour cream", "Onion", "Egg noodles"),
                580.0, 38.0, 48.0, 28.0, 2
        ));

        log.info("Initialized {} static fallback recipes", staticRecipes.size());
    }

    private RecipeResponse createRecipe(String name, String mealType, List<String> ingredients,
                                        double calories, double protein, double carbs, double fat, int servings) {
        RecipeResponse.NutritionInfo nutrition = RecipeResponse.NutritionInfo.builder()
                .calories(calories)
                .protein(protein)
                .carbs(carbs)
                .fat(fat)
                .fiber(5.0)
                .sugar(8.0)
                .build();

        return RecipeResponse.builder()
                .uri("fallback:" + name.toLowerCase().replace(" ", "-"))
                .label(name)
                .image(null) // Pas d'image par défaut
                .source("NutriScan Static Recipes")
                .url("https://nutriscan.app/recipes/" + name.toLowerCase().replace(" ", "-"))
                .servings(servings)
                .calories(calories)
                .totalTime(30.0)
                .dietLabels(new ArrayList<>())
                .healthLabels(List.of("Low Sugar"))
                .ingredientLines(ingredients)
                .nutrition(nutrition)
                .build();
    }

    /**
     * Search recipes in the static collection
     * NOTE: Cette méthode est utilisée uniquement quand l'API Edamam échoue.
     * Elle retourne uniquement des recettes qui correspondent VRAIMENT à la recherche.
     */
    public List<RecipeResponse> searchRecipes(String query, String mealType, Integer calories, Integer maxResults) {
        log.info("⚠️ FALLBACK MODE: Searching static recipes: query={}, mealType={}, calories={}, maxResults={}",
                query, mealType, calories, maxResults);

        int limit = maxResults != null && maxResults > 0 ? maxResults : 10;

        // Si pas de query, retourner des recettes par mealType
        if (query == null || query.isBlank()) {
            List<RecipeResponse> results = staticRecipes.stream()
                    .filter(recipe -> matchesMealType(recipe, mealType))
                    .filter(recipe -> matchesCalories(recipe, calories))
                    .limit(limit)
                    .collect(Collectors.toList());

            log.info("No query provided, returning {} recipes for mealType: {}", results.size(), mealType);
            return results;
        }

        // Recherche avec query - on veut UNIQUEMENT des résultats pertinents
        List<RecipeResponse> results = staticRecipes.stream()
                .filter(recipe -> matchesQuery(recipe, query))
                .filter(recipe -> matchesMealType(recipe, mealType))
                .filter(recipe -> matchesCalories(recipe, calories))
                .limit(limit)
                .collect(Collectors.toList());

        // Si pas de résultats avec tous les filtres, essayer sans filtre calories
        if (results.isEmpty() && calories != null) {
            results = staticRecipes.stream()
                    .filter(recipe -> matchesQuery(recipe, query))
                    .filter(recipe -> matchesMealType(recipe, mealType))
                    .limit(limit)
                    .collect(Collectors.toList());
        }

        // Si toujours pas de résultats, essayer sans filtre mealType
        if (results.isEmpty() && mealType != null) {
            results = staticRecipes.stream()
                    .filter(recipe -> matchesQuery(recipe, query))
                    .limit(limit)
                    .collect(Collectors.toList());
        }

        // Si TOUJOURS pas de résultats, on retourne une liste vide
        // C'est mieux que de retourner des recettes non pertinentes !
        if (results.isEmpty()) {
            log.warn("❌ No matching recipes found for query '{}' in fallback database", query);
            log.warn("💡 Tip: The Edamam API should be used for comprehensive recipe search.");
            return new ArrayList<>();
        }

        log.info("✅ Found {} matching static recipes for query '{}'", results.size(), query);
        return results;
    }

    private boolean matchesMealType(RecipeResponse recipe, String mealType) {
        if (mealType == null || mealType.isBlank()) {
            return true; // No filter = match all
        }

        String recipeName = recipe.getLabel().toLowerCase();
        String type = mealType.toLowerCase();

        // Flexible matching based on common meal type indicators
        switch (type) {
            case "breakfast":
                return recipeName.contains("oat") || recipeName.contains("egg") ||
                       recipeName.contains("yogurt") || recipeName.contains("parfait") ||
                       recipeName.contains("breakfast");
            case "lunch":
                return recipeName.contains("salad") || recipeName.contains("sandwich") ||
                       recipeName.contains("bowl") || recipeName.contains("stir") ||
                       recipeName.contains("chicken") || recipeName.contains("turkey") ||
                       recipeName.contains("quinoa") || recipeName.contains("vegetable") ||
                       recipeName.contains("lunch");
            case "dinner":
                return recipeName.contains("salmon") || recipeName.contains("pasta") ||
                       recipeName.contains("beef") || recipeName.contains("chili") ||
                       recipeName.contains("dinner") || recipeName.contains("steak") ||
                       recipeName.contains("fish");
            case "snack":
                return recipeName.contains("smoothie") || recipeName.contains("apple") ||
                       recipeName.contains("nuts") || recipeName.contains("hummus") ||
                       recipeName.contains("snack") || recipeName.contains("fruit");
            default:
                // Pour tout autre type, chercher le mot dans le nom
                return recipeName.contains(type);
        }
    }

    private boolean matchesCalories(RecipeResponse recipe, Integer targetCalories) {
        if (targetCalories == null) {
            return true; // No filter = match all
        }

        double recipeCalories = recipe.getCalories() != null ? recipe.getCalories() : 0;
        // Allow 50% variance for more flexibility
        return Math.abs(recipeCalories - targetCalories) <= targetCalories * 0.5;
    }

    private boolean matchesQuery(RecipeResponse recipe, String query) {
        if (query == null || query.isBlank()) {
            return true;
        }

        String recipeName = recipe.getLabel().toLowerCase();
        String searchQuery = query.toLowerCase().trim();

        // Traductions français-anglais pour les recherches courantes
        java.util.Map<String, List<String>> translations = java.util.Map.of(
            "poulet", List.of("chicken", "poulet"),
            "chicken", List.of("chicken", "poulet"),
            "boeuf", List.of("beef", "boeuf"),
            "beef", List.of("beef", "boeuf"),
            "poisson", List.of("fish", "salmon", "poisson", "saumon"),
            "fish", List.of("fish", "salmon", "poisson", "saumon"),
            "salade", List.of("salad", "salade"),
            "salad", List.of("salad", "salade"),
            "oeuf", List.of("egg", "oeuf", "eggs", "oeufs"),
            "egg", List.of("egg", "oeuf", "eggs", "oeufs")
        );

        // Récupérer les synonymes
        List<String> searchTerms = new ArrayList<>();
        searchTerms.add(searchQuery);

        if (translations.containsKey(searchQuery)) {
            searchTerms.addAll(translations.get(searchQuery));
        }

        // Chercher dans le nom de la recette
        for (String term : searchTerms) {
            if (recipeName.contains(term)) {
                return true;
            }
        }

        // Chercher dans les ingrédients
        for (String ingredient : recipe.getIngredientLines()) {
            String ingredientLower = ingredient.toLowerCase();
            for (String term : searchTerms) {
                if (ingredientLower.contains(term)) {
                    return true;
                }
            }
        }

        return false;
    }

    public List<RecipeResponse> getAllRecipes() {
        return new ArrayList<>(staticRecipes);
    }
}

