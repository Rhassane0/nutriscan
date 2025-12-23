package com.nutriscan.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.response.RecipeResponse;
import com.nutriscan.model.Meal;
import com.nutriscan.model.MealItem;
import com.nutriscan.model.User;
import com.nutriscan.model.enums.GoalType;
import com.nutriscan.repository.UserRepository;
import lombok.Builder;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.*;

/**
 * Service IA unifié utilisant Gemma/Gemini pour toutes les fonctionnalités AI de NutriScan
 * - Analyse nutritionnelle détaillée (remplace Edamam Nutrition Analysis)
 * - Génération de plans de repas personnalisés
 * - Recommandations alimentaires intelligentes
 * - Conseils nutritionnels personnalisés
 * - Analyse d'images de repas
 */
@Service
@Slf4j
public class GeminiAIService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final UserRepository userRepository;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String modelName;

    public GeminiAIService(RestTemplate restTemplate, UserRepository userRepository) {
        this.restTemplate = restTemplate;
        this.userRepository = userRepository;
    }

    // ======================== ANALYSE NUTRITIONNELLE ========================

    /**
     * Analyse nutritionnelle complète d'un repas via Gemma AI
     * Remplace Edamam Nutrition Analysis avec plus de détails
     */
    public NutritionAnalysisResult analyzeNutrition(Meal meal) {
        if (!isConfigured()) {
            log.warn("⚠️ Gemini API not configured, using fallback analysis");
            return buildFallbackAnalysis(meal);
        }

        try {
            String prompt = buildNutritionAnalysisPrompt(meal);
            String response = callGemini(prompt);

            if (response == null || response.isEmpty()) {
                return buildFallbackAnalysis(meal);
            }

            return parseNutritionAnalysis(response, meal);
        } catch (Exception e) {
            log.error("❌ Error analyzing nutrition: {}", e.getMessage());
            return buildFallbackAnalysis(meal);
        }
    }

    /**
     * Analyse nutritionnelle d'une liste d'ingrédients
     */
    public NutritionAnalysisResult analyzeIngredients(List<String> ingredients) {
        if (!isConfigured() || ingredients == null || ingredients.isEmpty()) {
            return NutritionAnalysisResult.builder()
                    .calories(0).protein(0).carbs(0).fat(0)
                    .healthScore(50).build();
        }

        try {
            String prompt = buildIngredientsAnalysisPrompt(ingredients);
            String response = callGemini(prompt);
            return parseIngredientsAnalysis(response);
        } catch (Exception e) {
            log.error("Error analyzing ingredients: {}", e.getMessage());
            return NutritionAnalysisResult.builder()
                    .calories(0).protein(0).carbs(0).fat(0)
                    .healthScore(50).build();
        }
    }

    // ======================== RECOMMANDATIONS ========================

    /**
     * Génère des recommandations alimentaires personnalisées basées sur le profil utilisateur
     */
    public List<FoodRecommendation> getPersonalizedRecommendations(Long userId, String mealType) {
        if (!isConfigured()) {
            return getDefaultRecommendations(mealType);
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            String prompt = buildRecommendationPrompt(user, mealType);
            String response = callGemini(prompt);
            return parseRecommendations(response);
        } catch (Exception e) {
            log.error("Error getting recommendations: {}", e.getMessage());
            return getDefaultRecommendations(mealType);
        }
    }

    /**
     * Génère des conseils nutritionnels personnalisés pour l'utilisateur
     */
    public NutritionAdvice getNutritionAdvice(Long userId, Map<String, Double> dailyIntake) {
        if (!isConfigured()) {
            return getDefaultAdvice();
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            String prompt = buildAdvicePrompt(user, dailyIntake);
            String response = callGemini(prompt);
            return parseAdvice(response);
        } catch (Exception e) {
            log.error("Error getting nutrition advice: {}", e.getMessage());
            return getDefaultAdvice();
        }
    }

    // ======================== PLANS DE REPAS ========================

    /**
     * Génère un plan de repas complet pour plusieurs jours
     */
    public Map<String, Map<String, RecipeResponse>> generateFullMealPlan(
            Long userId, LocalDate startDate, int days, int dailyCalories,
            List<String> preferences, List<String> allergies) {

        if (!isConfigured()) {
            log.warn("⚠️ Gemini API not configured");
            return Collections.emptyMap();
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            log.info("🤖 Generating {} day meal plan with Gemini AI ({} cal/day)", days, dailyCalories);

            String prompt = buildMealPlanPrompt(days, dailyCalories, preferences, allergies, user);
            String response = callGemini(prompt);

            if (response == null || response.isEmpty()) {
                return Collections.emptyMap();
            }

            return parseMealPlanResponse(response, startDate, days);
        } catch (Exception e) {
            log.error("❌ Error generating meal plan: {}", e.getMessage());
            return Collections.emptyMap();
        }
    }

    /**
     * Génère des recettes pour un type de repas spécifique
     */
    public List<RecipeResponse> generateRecipes(Long userId, String mealType, int calories,
                                                 List<String> preferences, List<String> allergies) {
        if (!isConfigured()) {
            return Collections.emptyList();
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            String prompt = buildRecipePrompt(mealType, calories, preferences, allergies, user);
            String response = callGemini(prompt);
            return parseRecipes(response);
        } catch (Exception e) {
            log.error("Error generating recipes: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    // ======================== ANALYSE D'IMAGE ========================

    /**
     * Analyse une image de repas et retourne les informations nutritionnelles
     */
    public ImageAnalysisResult analyzeImage(String imageBase64) {
        if (!isConfigured()) {
            return ImageAnalysisResult.builder()
                    .detectedFoods(List.of("Aliment non identifié"))
                    .estimatedCalories(300)
                    .confidence(0.5)
                    .build();
        }

        try {
            String prompt = "Analyse cette image de repas. Identifie tous les aliments visibles et estime:\n" +
                    "1. Les aliments présents (liste)\n" +
                    "2. Les calories totales estimées\n" +
                    "3. Les macros (protéines, glucides, lipides)\n" +
                    "4. Un score de santé (0-100)\n\n" +
                    "Réponds UNIQUEMENT en JSON:\n" +
                    "{\"foods\":[\"...\"],\"calories\":500,\"protein\":25,\"carbs\":60,\"fat\":15,\"healthScore\":75,\"tips\":[\"...\"]}";

            String response = callGeminiWithImage(prompt, imageBase64);
            return parseImageAnalysis(response);
        } catch (Exception e) {
            log.error("Error analyzing image: {}", e.getMessage());
            return ImageAnalysisResult.builder()
                    .detectedFoods(List.of("Erreur d'analyse"))
                    .estimatedCalories(0)
                    .confidence(0)
                    .build();
        }
    }

    // ======================== ASSISTANT NUTRITIONNEL ========================

    /**
     * Chat avec l'assistant nutritionnel AI
     */
    public String chatWithAssistant(Long userId, String message, List<String> conversationHistory) {
        if (!isConfigured()) {
            return "Désolé, l'assistant AI n'est pas disponible pour le moment.";
        }

        try {
            User user = userRepository.findById(userId).orElse(null);
            String prompt = buildChatPrompt(user, message, conversationHistory);
            String response = callGemini(prompt);
            return response != null ? cleanResponse(response) : "Je n'ai pas pu traiter votre demande.";
        } catch (Exception e) {
            log.error("Error in chat: {}", e.getMessage());
            return "Une erreur s'est produite. Veuillez réessayer.";
        }
    }

    // ======================== PROMPTS ========================

    private String buildNutritionAnalysisPrompt(Meal meal) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tu es un nutritionniste expert. Analyse ce repas en détail:\n\n");
        sb.append("Type de repas: ").append(meal.getMealType()).append("\n");
        sb.append("Aliments:\n");

        for (MealItem item : meal.getItems()) {
            sb.append("- ").append(item.getFoodName());
            if (item.getQuantity() != null) {
                sb.append(" (").append(item.getQuantity()).append(" ").append(item.getServingUnit()).append(")");
            }
            sb.append("\n");
        }

        sb.append("\nAnalyse et retourne UNIQUEMENT ce JSON (pas de texte avant/après):\n");
        sb.append("{\n");
        sb.append("  \"calories\": 500,\n");
        sb.append("  \"protein\": 25.0,\n");
        sb.append("  \"carbs\": 60.0,\n");
        sb.append("  \"fat\": 20.0,\n");
        sb.append("  \"fiber\": 8.0,\n");
        sb.append("  \"sugar\": 15.0,\n");
        sb.append("  \"sodium\": 500,\n");
        sb.append("  \"saturatedFat\": 5.0,\n");
        sb.append("  \"cholesterol\": 50,\n");
        sb.append("  \"potassium\": 400,\n");
        sb.append("  \"vitaminA\": 10,\n");
        sb.append("  \"vitaminC\": 15,\n");
        sb.append("  \"vitaminD\": 5,\n");
        sb.append("  \"calcium\": 100,\n");
        sb.append("  \"iron\": 8,\n");
        sb.append("  \"healthScore\": 75,\n");
        sb.append("  \"warnings\": [\"Riche en sodium\"],\n");
        sb.append("  \"benefits\": [\"Bonne source de protéines\"],\n");
        sb.append("  \"tips\": [\"Ajoutez des légumes pour plus de fibres\"]\n");
        sb.append("}");

        return sb.toString();
    }

    private String buildIngredientsAnalysisPrompt(List<String> ingredients) {
        StringBuilder sb = new StringBuilder();
        sb.append("Analyse nutritionnelle de ces ingrédients:\n");
        for (String ing : ingredients) {
            sb.append("- ").append(ing).append("\n");
        }
        sb.append("\nRetourne UNIQUEMENT ce JSON:\n");
        sb.append("{\"calories\":0,\"protein\":0,\"carbs\":0,\"fat\":0,\"fiber\":0,\"sugar\":0,\"healthScore\":50}");
        return sb.toString();
    }

    private String buildRecommendationPrompt(User user, String mealType) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tu es un nutritionniste. Recommande 5 aliments pour un ");
        sb.append(mealTypeFr(mealType)).append(".\n\n");

        if (user != null) {
            if (user.getGoalType() != null) {
                sb.append("Objectif: ").append(goalToString(user.getGoalType())).append("\n");
            }
            if (user.getDietPreferences() != null) {
                sb.append("Régime: ").append(user.getDietPreferences()).append("\n");
            }
            if (user.getAllergies() != null) {
                sb.append("Allergies à éviter: ").append(user.getAllergies()).append("\n");
            }
        }

        sb.append("\nRetourne UNIQUEMENT ce JSON:\n");
        sb.append("[{\"name\":\"...\",\"reason\":\"...\",\"calories\":100,\"benefits\":[\"...\"]}]");
        return sb.toString();
    }

    private String buildAdvicePrompt(User user, Map<String, Double> dailyIntake) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tu es un nutritionniste. Analyse l'apport journalier et donne des conseils.\n\n");

        if (dailyIntake != null) {
            sb.append("Apport du jour:\n");
            dailyIntake.forEach((k, v) -> sb.append("- ").append(k).append(": ").append(v).append("\n"));
        }

        if (user != null && user.getGoalType() != null) {
            sb.append("\nObjectif: ").append(goalToString(user.getGoalType())).append("\n");
        }

        sb.append("\nRetourne UNIQUEMENT ce JSON:\n");
        sb.append("{\"score\":75,\"summary\":\"...\",\"strengths\":[\"...\"],\"improvements\":[\"...\"],\"tips\":[\"...\"]}");
        return sb.toString();
    }

    private String buildMealPlanPrompt(int days, int dailyCalories, List<String> preferences,
                                        List<String> allergies, User user) {
        StringBuilder p = new StringBuilder();
        p.append("Tu es un chef nutritionniste expert. Génère un plan de repas COMPLET et VARIÉ pour ").append(days);
        p.append(" jours avec ").append(dailyCalories).append(" calories/jour.\n\n");

        if (user != null) {
            if (user.getGoalType() != null) {
                p.append("🎯 Objectif: ").append(goalToString(user.getGoalType())).append("\n");
            }
            if (user.getDietPreferences() != null && !user.getDietPreferences().isEmpty()) {
                p.append("🥗 Régime: ").append(user.getDietPreferences()).append("\n");
            }
            if (user.getAllergies() != null && !user.getAllergies().isEmpty()) {
                p.append("⚠️ Allergies: ").append(user.getAllergies()).append("\n");
            }
        }

        if (preferences != null && !preferences.isEmpty()) {
            p.append("✅ Préférences: ").append(String.join(", ", preferences)).append("\n");
        }
        if (allergies != null && !allergies.isEmpty()) {
            p.append("🚫 EXCLURE ABSOLUMENT: ").append(String.join(", ", allergies)).append("\n");
        }

        p.append("\n📊 Distribution calorique:\n");
        p.append("- Petit-déjeuner: 25% (~").append(dailyCalories * 25 / 100).append(" cal)\n");
        p.append("- Déjeuner: 35% (~").append(dailyCalories * 35 / 100).append(" cal)\n");
        p.append("- Dîner: 30% (~").append(dailyCalories * 30 / 100).append(" cal)\n");
        p.append("- Collation: 10% (~").append(dailyCalories * 10 / 100).append(" cal)\n");

        p.append("\n🍽️ IMPORTANT: Propose des recettes VARIÉES et RÉALISTES avec des noms concrets.\n\n");
        p.append("RÉPONDS UNIQUEMENT EN JSON VALIDE (sans texte avant/après):\n");
        p.append("[{\"day\":1,");
        p.append("\"breakfast\":{\"name\":\"Nom du plat\",\"calories\":").append(dailyCalories * 25 / 100);
        p.append(",\"protein\":20,\"carbs\":50,\"fat\":15,\"fiber\":5,\"ingredients\":[\"ingrédient 1\",\"ingrédient 2\"]},");
        p.append("\"lunch\":{\"name\":\"Nom du plat\",\"calories\":").append(dailyCalories * 35 / 100);
        p.append(",\"protein\":30,\"carbs\":60,\"fat\":20,\"fiber\":8,\"ingredients\":[\"...\"]},");
        p.append("\"dinner\":{\"name\":\"Nom du plat\",\"calories\":").append(dailyCalories * 30 / 100);
        p.append(",\"protein\":25,\"carbs\":45,\"fat\":18,\"fiber\":6,\"ingredients\":[\"...\"]},");
        p.append("\"snack\":{\"name\":\"Nom du snack\",\"calories\":").append(dailyCalories * 10 / 100);
        p.append(",\"protein\":8,\"carbs\":20,\"fat\":5,\"fiber\":3,\"ingredients\":[\"...\"]}}]");

        return p.toString();
    }

    private String buildRecipePrompt(String mealType, int calories, List<String> preferences,
                                      List<String> allergies, User user) {
        StringBuilder p = new StringBuilder();
        p.append("Génère 5 recettes délicieuses pour un ").append(mealTypeFr(mealType));
        p.append(" d'environ ").append(calories).append(" calories.\n\n");

        if (user != null && user.getGoalType() != null) {
            p.append("Objectif: ").append(goalToString(user.getGoalType())).append("\n");
        }
        if (preferences != null && !preferences.isEmpty()) {
            p.append("Préférences: ").append(String.join(", ", preferences)).append("\n");
        }
        if (allergies != null && !allergies.isEmpty()) {
            p.append("EXCLURE: ").append(String.join(", ", allergies)).append("\n");
        }

        p.append("\nRÉPONDS UNIQUEMENT EN JSON:\n");
        p.append("[{\"name\":\"Nom de la recette\",\"calories\":").append(calories);
        p.append(",\"protein\":25,\"carbs\":40,\"fat\":15,\"fiber\":5,\"prepTime\":20,");
        p.append("\"ingredients\":[\"ingrédient 1\",\"ingrédient 2\"],");
        p.append("\"instructions\":[\"Étape 1\",\"Étape 2\"],");
        p.append("\"tips\":\"Conseil pour cette recette\"}]");

        return p.toString();
    }

    private String buildChatPrompt(User user, String message, List<String> history) {
        StringBuilder sb = new StringBuilder();
        sb.append("Tu es NutriBot, un assistant nutritionnel intelligent et amical.\n");
        sb.append("Tu donnes des conseils de nutrition personnalisés, des idées de repas, ");
        sb.append("et réponds aux questions sur l'alimentation saine.\n\n");

        if (user != null) {
            sb.append("Profil utilisateur:\n");
            if (user.getGoalType() != null) {
                sb.append("- Objectif: ").append(goalToString(user.getGoalType())).append("\n");
            }
            if (user.getDietPreferences() != null) {
                sb.append("- Régime: ").append(user.getDietPreferences()).append("\n");
            }
            sb.append("\n");
        }

        if (history != null && !history.isEmpty()) {
            sb.append("Historique de conversation:\n");
            for (String h : history) {
                sb.append(h).append("\n");
            }
            sb.append("\n");
        }

        sb.append("Message de l'utilisateur: ").append(message).append("\n\n");
        sb.append("Réponds de manière concise, utile et encourageante.");

        return sb.toString();
    }

    // ======================== PARSING ========================

    private NutritionAnalysisResult parseNutritionAnalysis(String response, Meal meal) {
        try {
            String json = extractJsonObject(response);
            if (json == null) return buildFallbackAnalysis(meal);

            Map<String, Object> data = objectMapper.readValue(json, new TypeReference<>() {});

            return NutritionAnalysisResult.builder()
                    .calories(toDouble(data.get("calories")))
                    .protein(toDouble(data.get("protein")))
                    .carbs(toDouble(data.get("carbs")))
                    .fat(toDouble(data.get("fat")))
                    .fiber(toDouble(data.get("fiber")))
                    .sugar(toDouble(data.get("sugar")))
                    .sodium(toDouble(data.get("sodium")))
                    .saturatedFat(toDouble(data.get("saturatedFat")))
                    .cholesterol(toDouble(data.get("cholesterol")))
                    .potassium(toDouble(data.get("potassium")))
                    .vitaminA(toDouble(data.get("vitaminA")))
                    .vitaminC(toDouble(data.get("vitaminC")))
                    .vitaminD(toDouble(data.get("vitaminD")))
                    .calcium(toDouble(data.get("calcium")))
                    .iron(toDouble(data.get("iron")))
                    .healthScore(toInt(data.get("healthScore")))
                    .warnings(toStringList(data.get("warnings")))
                    .benefits(toStringList(data.get("benefits")))
                    .tips(toStringList(data.get("tips")))
                    .build();
        } catch (Exception e) {
            log.error("Parse nutrition error: {}", e.getMessage());
            return buildFallbackAnalysis(meal);
        }
    }

    private NutritionAnalysisResult parseIngredientsAnalysis(String response) {
        try {
            String json = extractJsonObject(response);
            if (json == null) return NutritionAnalysisResult.builder().build();

            Map<String, Object> data = objectMapper.readValue(json, new TypeReference<>() {});
            return NutritionAnalysisResult.builder()
                    .calories(toDouble(data.get("calories")))
                    .protein(toDouble(data.get("protein")))
                    .carbs(toDouble(data.get("carbs")))
                    .fat(toDouble(data.get("fat")))
                    .fiber(toDouble(data.get("fiber")))
                    .sugar(toDouble(data.get("sugar")))
                    .healthScore(toInt(data.get("healthScore")))
                    .build();
        } catch (Exception e) {
            return NutritionAnalysisResult.builder().build();
        }
    }

    @SuppressWarnings("unchecked")
    private List<FoodRecommendation> parseRecommendations(String response) {
        List<FoodRecommendation> result = new ArrayList<>();
        try {
            String json = extractJsonArray(response);
            if (json == null) return result;

            List<Map<String, Object>> list = objectMapper.readValue(json, new TypeReference<>() {});
            for (Map<String, Object> data : list) {
                result.add(FoodRecommendation.builder()
                        .name((String) data.get("name"))
                        .reason((String) data.get("reason"))
                        .calories(toDouble(data.get("calories")))
                        .benefits(toStringList(data.get("benefits")))
                        .build());
            }
        } catch (Exception e) {
            log.error("Parse recommendations error: {}", e.getMessage());
        }
        return result;
    }

    private NutritionAdvice parseAdvice(String response) {
        try {
            String json = extractJsonObject(response);
            if (json == null) return getDefaultAdvice();

            Map<String, Object> data = objectMapper.readValue(json, new TypeReference<>() {});
            return NutritionAdvice.builder()
                    .score(toInt(data.get("score")))
                    .summary((String) data.get("summary"))
                    .strengths(toStringList(data.get("strengths")))
                    .improvements(toStringList(data.get("improvements")))
                    .tips(toStringList(data.get("tips")))
                    .build();
        } catch (Exception e) {
            return getDefaultAdvice();
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Map<String, RecipeResponse>> parseMealPlanResponse(String response, LocalDate startDate, int days) {
        Map<String, Map<String, RecipeResponse>> result = new LinkedHashMap<>();

        try {
            String json = extractJsonArray(response);
            if (json == null) return result;

            List<Map<String, Object>> dayPlans = objectMapper.readValue(json, new TypeReference<>() {});

            for (int i = 0; i < Math.min(dayPlans.size(), days); i++) {
                Map<String, Object> dayPlan = dayPlans.get(i);
                LocalDate date = startDate.plusDays(i);
                Map<String, RecipeResponse> dayMeals = new HashMap<>();

                for (String meal : List.of("breakfast", "lunch", "dinner", "snack")) {
                    Object data = dayPlan.get(meal);
                    if (data instanceof Map) {
                        RecipeResponse recipe = toRecipeResponse((Map<String, Object>) data);
                        if (recipe != null) dayMeals.put(meal.toUpperCase(), recipe);
                    }
                }
                result.put(date.toString(), dayMeals);
            }
            log.info("✅ Parsed {} days meal plan from AI", result.size());
        } catch (Exception e) {
            log.error("Parse meal plan error: {}", e.getMessage());
        }
        return result;
    }

    @SuppressWarnings("unchecked")
    private List<RecipeResponse> parseRecipes(String response) {
        List<RecipeResponse> recipes = new ArrayList<>();
        try {
            String json = extractJsonArray(response);
            if (json == null) return recipes;

            List<Map<String, Object>> list = objectMapper.readValue(json, new TypeReference<>() {});
            for (Map<String, Object> data : list) {
                RecipeResponse r = toRecipeResponse(data);
                if (r != null) recipes.add(r);
            }
        } catch (Exception e) {
            log.error("Parse recipes error: {}", e.getMessage());
        }
        return recipes;
    }

    private ImageAnalysisResult parseImageAnalysis(String response) {
        try {
            String json = extractJsonObject(response);
            if (json == null) {
                return ImageAnalysisResult.builder()
                        .detectedFoods(List.of("Non identifié"))
                        .estimatedCalories(300)
                        .confidence(0.5)
                        .build();
            }

            Map<String, Object> data = objectMapper.readValue(json, new TypeReference<>() {});
            return ImageAnalysisResult.builder()
                    .detectedFoods(toStringList(data.get("foods")))
                    .estimatedCalories(toDouble(data.get("calories")))
                    .protein(toDouble(data.get("protein")))
                    .carbs(toDouble(data.get("carbs")))
                    .fat(toDouble(data.get("fat")))
                    .healthScore(toInt(data.get("healthScore")))
                    .tips(toStringList(data.get("tips")))
                    .confidence(0.8)
                    .build();
        } catch (Exception e) {
            return ImageAnalysisResult.builder()
                    .detectedFoods(List.of("Erreur"))
                    .estimatedCalories(0)
                    .confidence(0)
                    .build();
        }
    }

    // ======================== HELPERS ========================

    @SuppressWarnings("unchecked")
    private RecipeResponse toRecipeResponse(Map<String, Object> data) {
        try {
            RecipeResponse r = new RecipeResponse();
            r.setLabel((String) data.get("name"));
            r.setCalories(toDouble(data.get("calories")));
            r.setUri("ai-recipe-" + UUID.randomUUID());
            r.setSource("NutriScan AI");
            r.setServings(2);
            r.setTotalTime(toDouble(data.get("prepTime")));

            RecipeResponse.NutritionInfo n = new RecipeResponse.NutritionInfo();
            n.setCalories(toDouble(data.get("calories")));
            n.setProtein(toDouble(data.get("protein")));
            n.setCarbs(toDouble(data.get("carbs")));
            n.setFat(toDouble(data.get("fat")));
            n.setFiber(toDouble(data.get("fiber")));
            r.setNutrition(n);

            Object ing = data.get("ingredients");
            if (ing instanceof List) {
                r.setIngredientLines(new ArrayList<>((List<String>) ing));
            }

            return r;
        } catch (Exception e) {
            return null;
        }
    }

    private NutritionAnalysisResult buildFallbackAnalysis(Meal meal) {
        double totalCal = 0, totalPro = 0, totalCarb = 0, totalFat = 0;

        if (meal != null && meal.getItems() != null) {
            for (MealItem item : meal.getItems()) {
                totalCal += item.getCalories() != null ? item.getCalories() : 0;
                totalPro += item.getProtein() != null ? item.getProtein() : 0;
                totalCarb += item.getCarbs() != null ? item.getCarbs() : 0;
                totalFat += item.getFat() != null ? item.getFat() : 0;
            }
        }

        // Estimer les autres nutriments
        double fiber = totalCarb * 0.1;
        double sugar = totalCarb * 0.3;
        int healthScore = calculateHealthScore(totalCal, totalPro, totalCarb, totalFat);

        return NutritionAnalysisResult.builder()
                .calories(totalCal)
                .protein(totalPro)
                .carbs(totalCarb)
                .fat(totalFat)
                .fiber(fiber)
                .sugar(sugar)
                .sodium(totalCal * 0.8)
                .saturatedFat(totalFat * 0.3)
                .healthScore(healthScore)
                .benefits(List.of("Apport énergétique"))
                .tips(List.of("Variez votre alimentation pour un meilleur équilibre"))
                .build();
    }

    private int calculateHealthScore(double cal, double pro, double carb, double fat) {
        if (cal == 0) return 50;
        double proRatio = (pro * 4 / cal) * 100;
        double carbRatio = (carb * 4 / cal) * 100;
        double fatRatio = (fat * 9 / cal) * 100;

        int score = 50;
        if (proRatio >= 15 && proRatio <= 30) score += 15;
        if (carbRatio >= 45 && carbRatio <= 65) score += 15;
        if (fatRatio >= 20 && fatRatio <= 35) score += 15;

        return Math.min(100, Math.max(0, score));
    }

    private List<FoodRecommendation> getDefaultRecommendations(String mealType) {
        List<FoodRecommendation> recs = new ArrayList<>();
        switch (mealType.toUpperCase()) {
            case "BREAKFAST" -> {
                recs.add(FoodRecommendation.builder().name("Flocons d'avoine").reason("Riche en fibres").calories(150).build());
                recs.add(FoodRecommendation.builder().name("Œufs").reason("Protéines complètes").calories(140).build());
                recs.add(FoodRecommendation.builder().name("Yaourt grec").reason("Probiotiques").calories(100).build());
            }
            case "LUNCH" -> {
                recs.add(FoodRecommendation.builder().name("Quinoa").reason("Protéine végétale").calories(220).build());
                recs.add(FoodRecommendation.builder().name("Poulet grillé").reason("Protéines maigres").calories(165).build());
                recs.add(FoodRecommendation.builder().name("Légumes variés").reason("Vitamines et fibres").calories(50).build());
            }
            default -> {
                recs.add(FoodRecommendation.builder().name("Fruits frais").reason("Vitamines").calories(80).build());
                recs.add(FoodRecommendation.builder().name("Noix").reason("Bons lipides").calories(180).build());
            }
        }
        return recs;
    }

    private NutritionAdvice getDefaultAdvice() {
        return NutritionAdvice.builder()
                .score(70)
                .summary("Continuez vos efforts pour une alimentation équilibrée!")
                .strengths(List.of("Vous suivez vos repas régulièrement"))
                .improvements(List.of("Augmentez votre consommation de légumes"))
                .tips(List.of("Buvez au moins 8 verres d'eau par jour"))
                .build();
    }

    private String mealTypeFr(String type) {
        return switch (type.toUpperCase()) {
            case "BREAKFAST" -> "petit-déjeuner";
            case "LUNCH" -> "déjeuner";
            case "DINNER" -> "dîner";
            case "SNACK" -> "collation";
            default -> "repas";
        };
    }

    private String goalToString(GoalType goal) {
        return switch (goal) {
            case LOSE_WEIGHT -> "Perdre du poids";
            case GAIN_WEIGHT -> "Prendre du poids";
            case MAINTAIN -> "Maintenir le poids";
        };
    }

    // ======================== API CALLS ========================

    private boolean isConfigured() {
        return geminiApiKey != null && !geminiApiKey.isEmpty() && !geminiApiKey.equals("your-gemini-api-key-here");
    }

    private String callGemini(String prompt) {
        for (String model : List.of(modelName, "gemini-1.5-flash", "gemini-2.0-flash-exp")) {
            try {
                String result = callModel(model, prompt);
                if (result != null && !result.isEmpty()) return result;
            } catch (Exception e) {
                log.warn("Model {} failed: {}", model, e.getMessage());
            }
        }
        return null;
    }

    private String callGeminiWithImage(String prompt, String imageBase64) {
        try {
            String url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + geminiApiKey;

            List<Map<String, Object>> parts = new ArrayList<>();
            parts.add(Map.of("text", prompt));
            parts.add(Map.of("inline_data", Map.of(
                    "mime_type", "image/jpeg",
                    "data", imageBase64
            )));

            Map<String, Object> body = Map.of(
                    "contents", List.of(Map.of("parts", parts)),
                    "generationConfig", Map.of("temperature", 0.4, "maxOutputTokens", 4096)
            );

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return extractText(response.getBody());
            }
        } catch (Exception e) {
            log.error("Error calling Gemini with image: {}", e.getMessage());
        }
        return null;
    }

    private String callModel(String model, String prompt) {
        try {
            String url = "https://generativelanguage.googleapis.com/v1beta/models/" + model +
                    ":generateContent?key=" + geminiApiKey;

            Map<String, Object> body = Map.of(
                    "contents", List.of(Map.of("parts", List.of(Map.of("text", prompt)))),
                    "generationConfig", Map.of("temperature", 0.7, "maxOutputTokens", 8192)
            );

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);

            log.debug("🤖 Calling AI model: {}", model);
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                String text = extractText(response.getBody());
                if (text != null) {
                    log.debug("✅ Got response from {}", model);
                    return text;
                }
            }
        } catch (Exception e) {
            log.warn("Error calling {}: {}", model, e.getMessage());
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private String extractText(Map<String, Object> body) {
        try {
            List<Map<String, Object>> candidates = (List<Map<String, Object>>) body.get("candidates");
            if (candidates != null && !candidates.isEmpty()) {
                Map<String, Object> content = (Map<String, Object>) candidates.get(0).get("content");
                if (content != null) {
                    List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
                    if (parts != null && !parts.isEmpty()) {
                        return (String) parts.get(0).get("text");
                    }
                }
            }
        } catch (Exception e) {
            log.error("Extract text error: {}", e.getMessage());
        }
        return null;
    }

    private String extractJsonObject(String response) {
        if (response == null) return null;
        String clean = response.replaceAll("```json\\s*", "").replaceAll("```\\s*", "").trim();
        int s = clean.indexOf('{');
        int e = clean.lastIndexOf('}');
        return (s >= 0 && e > s) ? clean.substring(s, e + 1) : null;
    }

    private String extractJsonArray(String response) {
        if (response == null) return null;
        String clean = response.replaceAll("```json\\s*", "").replaceAll("```\\s*", "").trim();
        int s = clean.indexOf('[');
        int e = clean.lastIndexOf(']');
        return (s >= 0 && e > s) ? clean.substring(s, e + 1) : null;
    }

    private String cleanResponse(String response) {
        if (response == null) return "";
        return response.replaceAll("```.*?```", "").trim();
    }

    private double toDouble(Object v) {
        if (v == null) return 0;
        if (v instanceof Number) return ((Number) v).doubleValue();
        try {
            return Double.parseDouble(v.toString().replaceAll("[^0-9.]", ""));
        } catch (Exception e) {
            return 0;
        }
    }

    private int toInt(Object v) {
        return (int) toDouble(v);
    }

    @SuppressWarnings("unchecked")
    private List<String> toStringList(Object v) {
        if (v == null) return List.of();
        if (v instanceof List) {
            return ((List<?>) v).stream().map(Object::toString).toList();
        }
        return List.of();
    }

    // ======================== DTOs ========================

    @Data
    @Builder
    public static class NutritionAnalysisResult {
        private double calories;
        private double protein;
        private double carbs;
        private double fat;
        private double fiber;
        private double sugar;
        private double sodium;
        private double saturatedFat;
        private double cholesterol;
        private double potassium;
        private double vitaminA;
        private double vitaminC;
        private double vitaminD;
        private double calcium;
        private double iron;
        private int healthScore;
        private List<String> warnings;
        private List<String> benefits;
        private List<String> tips;
    }

    @Data
    @Builder
    public static class FoodRecommendation {
        private String name;
        private String reason;
        private double calories;
        private List<String> benefits;
    }

    @Data
    @Builder
    public static class NutritionAdvice {
        private int score;
        private String summary;
        private List<String> strengths;
        private List<String> improvements;
        private List<String> tips;
    }

    @Data
    @Builder
    public static class ImageAnalysisResult {
        private List<String> detectedFoods;
        private double estimatedCalories;
        private double protein;
        private double carbs;
        private double fat;
        private int healthScore;
        private List<String> tips;
        private double confidence;
    }
}

