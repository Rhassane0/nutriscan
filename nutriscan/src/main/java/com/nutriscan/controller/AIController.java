package com.nutriscan.controller;

import com.nutriscan.dto.response.RecipeResponse;
import com.nutriscan.security.CustomUserDetails;
import com.nutriscan.service.GeminiAIService;
import com.nutriscan.service.GeminiAIService.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour toutes les fonctionnalités AI de NutriScan
 * Utilise Gemma/Gemini pour:
 * - Analyse nutritionnelle
 * - Recommandations personnalisées
 * - Génération de plans de repas
 * - Conseils nutritionnels
 * - Analyse d'images
 * - Assistant chatbot
 */
@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
@Slf4j
public class AIController {

    private final GeminiAIService aiService;

    /**
     * Obtenir des recommandations alimentaires personnalisées
     */
    @GetMapping("/recommendations")
    public ResponseEntity<List<FoodRecommendation>> getRecommendations(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(defaultValue = "LUNCH") String mealType
    ) {
        log.info("🤖 Getting AI recommendations for user {} - {}", currentUser.getId(), mealType);
        List<FoodRecommendation> recommendations = aiService.getPersonalizedRecommendations(
                currentUser.getId(), mealType);
        return ResponseEntity.ok(recommendations);
    }

    /**
     * Obtenir des conseils nutritionnels basés sur l'apport du jour
     */
    @PostMapping("/advice")
    public ResponseEntity<NutritionAdvice> getNutritionAdvice(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestBody Map<String, Double> dailyIntake
    ) {
        log.info("🤖 Getting AI nutrition advice for user {}", currentUser.getId());
        NutritionAdvice advice = aiService.getNutritionAdvice(currentUser.getId(), dailyIntake);
        return ResponseEntity.ok(advice);
    }

    /**
     * Analyser des ingrédients et obtenir les informations nutritionnelles
     */
    @PostMapping("/analyze/ingredients")
    public ResponseEntity<NutritionAnalysisResult> analyzeIngredients(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestBody Map<String, Object> request
    ) {
        @SuppressWarnings("unchecked")
        List<String> ingredients = (List<String>) request.get("ingredients");
        if (ingredients == null || ingredients.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        log.info("🤖 Analyzing {} ingredients for user {}", ingredients.size(), currentUser.getId());
        NutritionAnalysisResult result = aiService.analyzeIngredients(ingredients);
        return ResponseEntity.ok(result);
    }

    /**
     * Analyser une image de repas
     */
    @PostMapping("/analyze/image")
    public ResponseEntity<ImageAnalysisResult> analyzeImage(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestBody Map<String, String> request
    ) {
        String imageBase64 = request.get("image");
        if (imageBase64 == null || imageBase64.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        log.info("🤖 Analyzing image for user {}", currentUser.getId());
        ImageAnalysisResult result = aiService.analyzeImage(imageBase64);
        return ResponseEntity.ok(result);
    }

    /**
     * Générer des recettes personnalisées
     */
    @GetMapping("/recipes")
    public ResponseEntity<List<RecipeResponse>> generateRecipes(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(defaultValue = "LUNCH") String mealType,
            @RequestParam(defaultValue = "500") int calories,
            @RequestParam(required = false) List<String> preferences,
            @RequestParam(required = false) List<String> exclude
    ) {
        log.info("🤖 Generating AI recipes for user {} - {} ~{} cal", currentUser.getId(), mealType, calories);
        List<RecipeResponse> recipes = aiService.generateRecipes(
                currentUser.getId(), mealType, calories, preferences, exclude);
        return ResponseEntity.ok(recipes);
    }

    /**
     * Chat avec l'assistant nutritionnel
     */
    @PostMapping("/chat")
    public ResponseEntity<Map<String, String>> chat(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestBody Map<String, Object> request
    ) {
        String message = (String) request.get("message");
        @SuppressWarnings("unchecked")
        List<String> history = (List<String>) request.get("history");

        if (message == null || message.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("response", "Message vide"));
        }

        log.info("🤖 AI Chat for user {}: {}", currentUser.getId(),
                message.length() > 50 ? message.substring(0, 50) + "..." : message);

        String response = aiService.chatWithAssistant(currentUser.getId(), message, history);
        return ResponseEntity.ok(Map.of("response", response));
    }

    /**
     * Obtenir un résumé nutritionnel intelligent
     */
    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getAISummary(
            @AuthenticationPrincipal CustomUserDetails currentUser,
            @RequestParam(required = false) String date
    ) {
        log.info("🤖 Getting AI summary for user {}", currentUser.getId());

        // Créer un résumé basé sur les données de l'utilisateur
        NutritionAdvice advice = aiService.getNutritionAdvice(currentUser.getId(), null);
        List<FoodRecommendation> recommendations = aiService.getPersonalizedRecommendations(
                currentUser.getId(), "SNACK");

        return ResponseEntity.ok(Map.of(
                "advice", advice,
                "recommendations", recommendations,
                "generatedAt", LocalDate.now().toString()
        ));
    }
}

