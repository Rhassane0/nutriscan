package com.nutriscan.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutriscan.dto.request.MealScanRequest;
import com.nutriscan.dto.response.GoalsResponse;
import com.nutriscan.dto.response.MealScanResponse;
import com.nutriscan.dto.response.MealScanResponse.*;
import com.nutriscan.dto.response.OffProductResponse;
import com.nutriscan.model.Food;
import com.nutriscan.model.enums.GoalType;
import com.nutriscan.repository.FoodRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.*;

/**
 * Service complet pour le scan de repas (code-barres + images)
 * Utilise Gemini Vision API pour l'analyse d'images
 */
@Service
@Slf4j
@Transactional
public class MealScanService {

    private final OpenFoodFactsService openFoodFactsService;
    private final FoodRepository foodRepository;
    private final GoalsService goalsService;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String geminiModel;

    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s";

    // Daily Values for percentage calculations (based on 2000 kcal diet)
    private static final double DV_CALORIES = 2000.0;
    private static final double DV_PROTEIN = 50.0;
    private static final double DV_CARBS = 300.0;
    private static final double DV_FAT = 65.0;
    private static final double DV_FIBER = 25.0;

    public MealScanService(OpenFoodFactsService openFoodFactsService,
                          FoodRepository foodRepository,
                          GoalsService goalsService,
                          RestTemplate restTemplate) {
        this.openFoodFactsService = openFoodFactsService;
        this.foodRepository = foodRepository;
        this.goalsService = goalsService;
        this.restTemplate = restTemplate;
        this.objectMapper = new ObjectMapper();
    }

    /**
     * Point d'entrée principal pour scanner un repas
     */
    public MealScanResponse scanMeal(MealScanRequest request, Long userId) {
        log.info("Scanning meal for user {}: type={}", userId, request.getScanType());

        try {
            return switch (request.getScanType().toUpperCase()) {
                case "BARCODE" -> scanByBarcode(request, userId);
                case "IMAGE_URL" -> scanByImageUrl(request, userId);
                case "IMAGE_BASE64" -> scanByImageBase64(request, userId);
                default -> MealScanResponse.builder()
                        .status("ERROR")
                        .errorMessage("Type de scan non supporté: " + request.getScanType())
                        .build();
            };
        } catch (Exception e) {
            log.error("Error scanning meal", e);
            return MealScanResponse.builder()
                    .status("ERROR")
                    .errorMessage("Erreur lors du scan: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Scan par code-barres avec OpenFoodFacts
     */
    private MealScanResponse scanByBarcode(MealScanRequest request, Long userId) {
        String barcode = request.getData();
        log.info("Scanning barcode: {}", barcode);

        OffProductResponse offResponse = openFoodFactsService.getProductByBarcode(barcode);

        if (offResponse == null || offResponse.getStatus() == 0 || offResponse.getProduct() == null) {
            return MealScanResponse.builder()
                    .scanType("BARCODE")
                    .status("NOT_FOUND")
                    .errorMessage("Produit non trouvé pour le code-barres: " + barcode)
                    .detectedItems(new ArrayList<>())
                    .build();
        }

        // Convertir le produit OpenFoodFacts en DetectedItem
        DetectedItem item = convertOffProductToDetectedItem(offResponse, request.getEstimatedQuantityGrams());

        // Calculer les totaux nutritionnels
        NutritionSummary summary = calculateNutritionSummary(List.of(item));

        // Générer l'analyse IA
        AIAnalysis aiAnalysis = generateAIAnalysis(List.of(item), userId, request.getMealType());

        // Calculer le score global
        int mealScore = calculateMealScore(item, summary);

        return MealScanResponse.builder()
                .scanType("BARCODE")
                .status("SUCCESS")
                .detectedItems(List.of(item))
                .totalNutrition(summary)
                .aiAnalysis(aiAnalysis)
                .mealScore(mealScore)
                .build();
    }

    /**
     * Scan par URL d'image
     */
    private MealScanResponse scanByImageUrl(MealScanRequest request, Long userId) {
        log.info("Scanning image from URL");

        // Télécharger l'image et la convertir en base64
        try {
            byte[] imageBytes = restTemplate.getForObject(request.getData(), byte[].class);
            if (imageBytes != null) {
                String base64Image = Base64.getEncoder().encodeToString(imageBytes);
                request.setData(base64Image);
                request.setScanType("IMAGE_BASE64");
                return scanByImageBase64(request, userId);
            }
        } catch (Exception e) {
            log.error("Error downloading image from URL", e);
        }

        return MealScanResponse.builder()
                .scanType("IMAGE_URL")
                .status("ERROR")
                .errorMessage("Impossible de télécharger l'image depuis l'URL")
                .build();
    }

    /**
     * Scan par image base64 avec Gemini Vision
     */
    private MealScanResponse scanByImageBase64(MealScanRequest request, Long userId) {
        log.info("Analyzing meal image with Gemini Vision");

        if (geminiApiKey == null || geminiApiKey.isEmpty() || geminiApiKey.equals("your-gemini-api-key-here")) {
            log.warn("Gemini API key not configured");
            return buildFallbackImageResponse(request);
        }

        try {
            // Appeler Gemini Vision API
            String geminiResponse = callGeminiVisionAPI(request.getData(), request.getMealType());

            // Parser la réponse et détecter les aliments
            List<DetectedItem> detectedItems = parseGeminiVisionResponse(geminiResponse);

            if (detectedItems.isEmpty()) {
                return MealScanResponse.builder()
                        .scanType("IMAGE")
                        .status("PARTIAL")
                        .detectedItems(detectedItems)
                        .errorMessage("Aucun aliment détecté dans l'image. Essayez une photo plus claire.")
                        .build();
            }

            // Enrichir avec les données de notre base
            enrichWithDatabaseMatches(detectedItems);

            // Calculer les totaux nutritionnels
            NutritionSummary summary = calculateNutritionSummary(detectedItems);

            // Générer l'analyse IA complète
            AIAnalysis aiAnalysis = generateAIAnalysis(detectedItems, userId, request.getMealType());

            // Calculer le score moyen
            int mealScore = (int) detectedItems.stream()
                    .filter(item -> item.getNutrition() != null)
                    .mapToDouble(item -> calculateItemScore(item))
                    .average()
                    .orElse(50.0);

            return MealScanResponse.builder()
                    .scanType("IMAGE")
                    .status("SUCCESS")
                    .detectedItems(detectedItems)
                    .totalNutrition(summary)
                    .aiAnalysis(aiAnalysis)
                    .mealScore(mealScore)
                    .build();

        } catch (Exception e) {
            log.error("Error analyzing image with Gemini", e);
            return MealScanResponse.builder()
                    .scanType("IMAGE")
                    .status("ERROR")
                    .errorMessage("Erreur lors de l'analyse de l'image: " + e.getMessage())
                    .build();
        }
    }

    /**
     * Appeler l'API Gemini Vision avec une image base64
     */
    private String callGeminiVisionAPI(String base64Image, String mealType) {
        String url = String.format(GEMINI_API_URL, geminiModel, geminiApiKey);

        String mealTypeInfo = mealType != null ? " (type de repas: " + mealType + ")" : "";

        // Construire le prompt
        String prompt = String.format("""
            Tu es un nutritionniste expert. Analyse cette photo de repas%s et identifie TOUS les aliments visibles.
            
            Pour CHAQUE aliment détecté, fournis:
            1. Nom en français
            2. Quantité estimée en grammes (sois réaliste basé sur la taille apparente)
            3. Calories estimées (pour la quantité)
            4. Protéines en grammes
            5. Glucides en grammes
            6. Lipides en grammes
            7. Fibres en grammes (si applicable)
            8. Sucres en grammes (si applicable)
            9. Confiance de la détection (0-100)
            
            Réponds UNIQUEMENT en JSON valide avec ce format exact:
            {
                "foods": [
                    {
                        "name": "Nom de l'aliment",
                        "quantity": 150,
                        "confidence": 85,
                        "nutrition": {
                            "calories": 250,
                            "proteins": 20,
                            "carbs": 30,
                            "fats": 8,
                            "fiber": 5,
                            "sugars": 3
                        }
                    }
                ],
                "mealDescription": "Description courte du repas",
                "healthTips": ["conseil 1", "conseil 2"]
            }
            
            Sois précis dans tes estimations de quantités et valeurs nutritionnelles.
            """, mealTypeInfo);

        // Construire le body de la requête
        Map<String, Object> requestBody = new HashMap<>();
        List<Map<String, Object>> contents = new ArrayList<>();
        Map<String, Object> content = new HashMap<>();
        List<Map<String, Object>> parts = new ArrayList<>();

        // Partie texte (prompt)
        Map<String, Object> textPart = new HashMap<>();
        textPart.put("text", prompt);
        parts.add(textPart);

        // Partie image (base64)
        Map<String, Object> imagePart = new HashMap<>();
        Map<String, Object> inlineData = new HashMap<>();

        // Nettoyer le préfixe base64 si présent
        String cleanBase64 = base64Image;
        if (base64Image.contains(",")) {
            cleanBase64 = base64Image.substring(base64Image.indexOf(",") + 1);
        }

        inlineData.put("mimeType", "image/jpeg");
        inlineData.put("data", cleanBase64);
        imagePart.put("inlineData", inlineData);
        parts.add(imagePart);

        content.put("parts", parts);
        contents.add(content);
        requestBody.put("contents", contents);

        // Configuration de génération
        Map<String, Object> generationConfig = new HashMap<>();
        generationConfig.put("temperature", 0.2);
        generationConfig.put("maxOutputTokens", 2048);
        requestBody.put("generationConfig", generationConfig);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        log.debug("Calling Gemini Vision API");
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);

        if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
            // Extraire le texte de la réponse Gemini
            try {
                JsonNode root = objectMapper.readTree(response.getBody());
                JsonNode candidates = root.path("candidates");
                if (candidates.isArray() && candidates.size() > 0) {
                    JsonNode textNode = candidates.get(0).path("content").path("parts").get(0).path("text");
                    return textNode.asText();
                }
            } catch (Exception e) {
                log.error("Error parsing Gemini response", e);
            }
        }

        throw new RuntimeException("Failed to get response from Gemini Vision API");
    }

    /**
     * Parser la réponse JSON de Gemini Vision
     */
    private List<DetectedItem> parseGeminiVisionResponse(String geminiResponse) {
        List<DetectedItem> items = new ArrayList<>();

        try {
            // Extraire le JSON de la réponse
            String jsonContent = geminiResponse;
            if (geminiResponse.contains("```json")) {
                int start = geminiResponse.indexOf("```json") + 7;
                int end = geminiResponse.indexOf("```", start);
                jsonContent = geminiResponse.substring(start, end).trim();
            } else if (geminiResponse.contains("{")) {
                int start = geminiResponse.indexOf("{");
                int end = geminiResponse.lastIndexOf("}") + 1;
                jsonContent = geminiResponse.substring(start, end);
            }

            JsonNode root = objectMapper.readTree(jsonContent);
            JsonNode foodsArray = root.path("foods");

            if (foodsArray.isArray()) {
                for (JsonNode food : foodsArray) {
                    DetectedItem item = DetectedItem.builder()
                            .name(food.path("name").asText("Aliment inconnu"))
                            .quantityGrams(food.path("quantity").asDouble(100))
                            .confidence(food.path("confidence").asDouble(70))
                            .source("AI_DETECTED")
                            .build();

                    // Extraire les infos nutritionnelles
                    JsonNode nutritionNode = food.path("nutrition");
                    if (!nutritionNode.isMissingNode()) {
                        NutritionInfo nutrition = NutritionInfo.builder()
                                .calories(nutritionNode.path("calories").asDouble(0))
                                .proteins(nutritionNode.path("proteins").asDouble(0))
                                .carbs(nutritionNode.path("carbs").asDouble(0))
                                .fats(nutritionNode.path("fats").asDouble(0))
                                .fiber(nutritionNode.path("fiber").asDouble(0))
                                .sugars(nutritionNode.path("sugars").asDouble(0))
                                .build();
                        item.setNutrition(nutrition);
                    }

                    items.add(item);
                }
            }
        } catch (Exception e) {
            log.error("Error parsing Gemini Vision response: {}", e.getMessage());
        }

        return items;
    }

    /**
     * Convertir un produit OpenFoodFacts en DetectedItem
     */
    private DetectedItem convertOffProductToDetectedItem(OffProductResponse offResponse, Double quantity) {
        OffProductResponse.OffProduct product = offResponse.getProduct();
        Map<String, Object> nutriments = product.getNutriments();

        double qty = quantity != null ? quantity : 100.0;
        double factor = qty / 100.0; // Les valeurs OFF sont pour 100g

        NutritionInfo nutrition = NutritionInfo.builder()
                .calories(extractNutrientValue(nutriments, "energy-kcal_100g", "energy-kcal") * factor)
                .proteins(extractNutrientValue(nutriments, "proteins_100g", "proteins") * factor)
                .carbs(extractNutrientValue(nutriments, "carbohydrates_100g", "carbohydrates") * factor)
                .fats(extractNutrientValue(nutriments, "fat_100g", "fat") * factor)
                .fiber(extractNutrientValue(nutriments, "fiber_100g", "fiber") * factor)
                .sugars(extractNutrientValue(nutriments, "sugars_100g", "sugars") * factor)
                .saturatedFat(extractNutrientValue(nutriments, "saturated-fat_100g", "saturated-fat") * factor)
                .sodium(extractNutrientValue(nutriments, "sodium_100g", "sodium") * factor)
                .build();

        // Extraire les ingrédients et allergènes
        List<String> ingredients = extractIngredients(product);
        List<String> allergens = extractAllergens(product);

        return DetectedItem.builder()
                .name(product.getProductName())
                .brand(product.getBrands())
                .barcode(offResponse.getCode())
                .imageUrl(product.getImageUrl())
                .nutriScore(product.getNutritionGrades())
                .quantityGrams(qty)
                .confidence(95.0) // Haute confiance pour les code-barres
                .source("OPEN_FOOD_FACTS")
                .nutrition(nutrition)
                .ingredients(ingredients)
                .allergens(allergens)
                .build();
    }

    /**
     * Extraire une valeur nutritionnelle des nutriments OFF
     */
    private double extractNutrientValue(Map<String, Object> nutriments, String... keys) {
        if (nutriments == null) return 0.0;

        for (String key : keys) {
            Object value = nutriments.get(key);
            if (value instanceof Number) {
                return ((Number) value).doubleValue();
            }
        }
        return 0.0;
    }

    /**
     * Extraire les ingrédients du produit OFF
     */
    @SuppressWarnings("unchecked")
    private List<String> extractIngredients(OffProductResponse.OffProduct product) {
        // À implémenter si les données sont disponibles
        return new ArrayList<>();
    }

    /**
     * Extraire les allergènes du produit OFF
     */
    private List<String> extractAllergens(OffProductResponse.OffProduct product) {
        // À implémenter si les données sont disponibles
        return new ArrayList<>();
    }

    /**
     * Enrichir les items détectés avec les correspondances de notre base
     */
    private void enrichWithDatabaseMatches(List<DetectedItem> items) {
        for (DetectedItem item : items) {
            try {
                List<Food> matches = foodRepository.findByNameContainingIgnoreCase(item.getName());
                if (!matches.isEmpty()) {
                    Food bestMatch = matches.get(0);
                    item.setMatchedFoodId(bestMatch.getId());

                    // Si pas de nutrition, utiliser celle de la base
                    if (item.getNutrition() == null) {
                        double factor = item.getQuantityGrams() / 100.0;
                        NutritionInfo nutrition = NutritionInfo.builder()
                                .calories(bestMatch.getCaloriesKcal() != null ? bestMatch.getCaloriesKcal() * factor : 0)
                                .proteins(bestMatch.getProteinGr() != null ? bestMatch.getProteinGr() * factor : 0)
                                .carbs(bestMatch.getCarbsGr() != null ? bestMatch.getCarbsGr() * factor : 0)
                                .fats(bestMatch.getFatGr() != null ? bestMatch.getFatGr() * factor : 0)
                                .fiber(bestMatch.getFiberGr() != null ? bestMatch.getFiberGr() * factor : 0)
                                .build();
                        item.setNutrition(nutrition);
                    }
                }
            } catch (Exception e) {
                log.warn("Error matching food {}: {}", item.getName(), e.getMessage());
            }
        }
    }

    /**
     * Calculer le résumé nutritionnel total
     */
    private NutritionSummary calculateNutritionSummary(List<DetectedItem> items) {
        double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0, totalFiber = 0, totalSugars = 0;

        for (DetectedItem item : items) {
            if (item.getNutrition() != null) {
                NutritionInfo n = item.getNutrition();
                totalCal += n.getCalories() != null ? n.getCalories() : 0;
                totalProt += n.getProteins() != null ? n.getProteins() : 0;
                totalCarbs += n.getCarbs() != null ? n.getCarbs() : 0;
                totalFat += n.getFats() != null ? n.getFats() : 0;
                totalFiber += n.getFiber() != null ? n.getFiber() : 0;
                totalSugars += n.getSugars() != null ? n.getSugars() : 0;
            }
        }

        return NutritionSummary.builder()
                .totalCalories(totalCal)
                .totalProteins(totalProt)
                .totalCarbs(totalCarbs)
                .totalFats(totalFat)
                .totalFiber(totalFiber)
                .totalSugars(totalSugars)
                .caloriesPercentDV((totalCal / DV_CALORIES) * 100)
                .proteinsPercentDV((totalProt / DV_PROTEIN) * 100)
                .carbsPercentDV((totalCarbs / DV_CARBS) * 100)
                .fatsPercentDV((totalFat / DV_FAT) * 100)
                .fiberPercentDV((totalFiber / DV_FIBER) * 100)
                .build();
    }

    /**
     * Générer l'analyse IA du repas
     */
    private AIAnalysis generateAIAnalysis(List<DetectedItem> items, Long userId, String mealType) {
        List<String> positives = new ArrayList<>();
        List<String> negatives = new ArrayList<>();
        List<String> recommendations = new ArrayList<>();

        // Récupérer les objectifs de l'utilisateur
        GoalsResponse goals = null;
        try {
            goals = goalsService.getGoalsForUser(userId);
        } catch (Exception e) {
            log.warn("Could not get user goals", e);
        }

        // Calculer les totaux
        double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0, totalFiber = 0;
        for (DetectedItem item : items) {
            if (item.getNutrition() != null) {
                NutritionInfo n = item.getNutrition();
                totalCal += n.getCalories() != null ? n.getCalories() : 0;
                totalProt += n.getProteins() != null ? n.getProteins() : 0;
                totalCarbs += n.getCarbs() != null ? n.getCarbs() : 0;
                totalFat += n.getFats() != null ? n.getFats() : 0;
                totalFiber += n.getFiber() != null ? n.getFiber() : 0;
            }
        }

        // Analyse des points positifs/négatifs
        if (totalProt > 20) {
            positives.add("Bonne source de protéines (" + String.format("%.1f", totalProt) + "g)");
        } else if (totalProt < 10) {
            negatives.add("Faible en protéines - considérez ajouter des œufs, viande, ou légumineuses");
        }

        if (totalFiber > 5) {
            positives.add("Bon apport en fibres (" + String.format("%.1f", totalFiber) + "g)");
        } else if (totalFiber < 2) {
            negatives.add("Faible en fibres - ajoutez des légumes ou des céréales complètes");
        }

        if (totalFat < 30 && totalCal > 0) {
            double fatPercent = (totalFat * 9 / totalCal) * 100;
            if (fatPercent < 35) {
                positives.add("Bon équilibre en lipides");
            }
        }

        // Vérifier les items avec NutriScore
        for (DetectedItem item : items) {
            if (item.getNutriScore() != null) {
                if (item.getNutriScore().equalsIgnoreCase("A") || item.getNutriScore().equalsIgnoreCase("B")) {
                    positives.add(item.getName() + " a un excellent Nutri-Score (" + item.getNutriScore().toUpperCase() + ")");
                } else if (item.getNutriScore().equalsIgnoreCase("D") || item.getNutriScore().equalsIgnoreCase("E")) {
                    negatives.add(item.getName() + " a un Nutri-Score à améliorer (" + item.getNutriScore().toUpperCase() + ")");
                }
            }
        }

        // Recommandations basées sur les objectifs
        String goalCompatibility = "Non déterminé";
        if (goals != null) {
            GoalType goalType = goals.getGoalType();
            if (GoalType.LOSE_WEIGHT == goalType) {
                if (totalCal > 600) {
                    negatives.add("Ce repas est assez calorique pour un objectif de perte de poids");
                    recommendations.add("Réduisez les portions ou remplacez par des alternatives moins caloriques");
                } else {
                    positives.add("Ce repas est adapté à votre objectif de perte de poids");
                }
                goalCompatibility = totalCal <= 600 ? "Excellent" : "Modéré";
            } else if (GoalType.GAIN_WEIGHT == goalType) {
                if (totalProt < 30) {
                    negatives.add("Pas assez de protéines pour la prise de poids/muscle");
                    recommendations.add("Ajoutez une source de protéines (poulet, thon, œufs)");
                } else {
                    positives.add("Bon apport protéique pour la prise de poids");
                }
                goalCompatibility = totalProt >= 30 ? "Excellent" : "À améliorer";
            }
        }

        // Générer le résumé
        String summary = String.format("Repas de %d aliment(s) - %.0f kcal, %.1fg protéines, %.1fg glucides, %.1fg lipides",
                items.size(), totalCal, totalProt, totalCarbs, totalFat);

        // Analyse santé
        StringBuilder healthAnalysis = new StringBuilder();
        if (!positives.isEmpty()) {
            healthAnalysis.append("Points forts: ").append(String.join(", ", positives.subList(0, Math.min(2, positives.size())))).append(". ");
        }
        if (!negatives.isEmpty()) {
            healthAnalysis.append("À améliorer: ").append(String.join(", ", negatives.subList(0, Math.min(2, negatives.size())))).append(".");
        }

        // Score global
        double score = 50.0;
        score += positives.size() * 10;
        score -= negatives.size() * 8;
        score = Math.max(0, Math.min(100, score));

        return AIAnalysis.builder()
                .summary(summary)
                .healthAnalysis(healthAnalysis.toString())
                .positivePoints(positives)
                .negativePoints(negatives)
                .recommendations(recommendations)
                .goalCompatibility(goalCompatibility)
                .overallScore(score)
                .build();
    }

    /**
     * Calculer le score d'un item individuel
     */
    private double calculateItemScore(DetectedItem item) {
        double score = 50.0;

        if (item.getNutriScore() != null) {
            switch (item.getNutriScore().toUpperCase()) {
                case "A" -> score = 90;
                case "B" -> score = 75;
                case "C" -> score = 60;
                case "D" -> score = 40;
                case "E" -> score = 20;
            }
        } else if (item.getNutrition() != null) {
            NutritionInfo n = item.getNutrition();
            double protPerCal = n.getProteins() / Math.max(1, n.getCalories() / 100);
            if (protPerCal > 3) score += 15;
            if (n.getFiber() != null && n.getFiber() > 3) score += 10;
            if (n.getSugars() != null && n.getSugars() > 15) score -= 10;
        }

        return Math.max(0, Math.min(100, score));
    }

    /**
     * Calculer le score global du repas
     */
    private int calculateMealScore(DetectedItem item, NutritionSummary summary) {
        double score = calculateItemScore(item);

        // Ajuster selon les pourcentages des apports journaliers
        if (summary.getCaloriesPercentDV() != null) {
            if (summary.getCaloriesPercentDV() > 50) {
                score -= 10; // Repas trop calorique pour un seul repas
            } else if (summary.getCaloriesPercentDV() < 15) {
                score -= 5; // Repas trop léger
            }
        }

        return (int) Math.max(0, Math.min(100, score));
    }

    /**
     * Réponse fallback si Gemini n'est pas disponible
     */
    private MealScanResponse buildFallbackImageResponse(MealScanRequest request) {
        return MealScanResponse.builder()
                .scanType("IMAGE")
                .status("PARTIAL")
                .detectedItems(new ArrayList<>())
                .errorMessage("L'analyse d'image par IA n'est pas configurée. " +
                        "Veuillez configurer votre clé API Gemini ou utiliser le scan par code-barres.")
                .aiAnalysis(AIAnalysis.builder()
                        .summary("Analyse automatique non disponible")
                        .healthAnalysis("Configurez l'API Gemini pour activer l'analyse d'images")
                        .recommendations(List.of("Utilisez le scan de code-barres pour une analyse précise"))
                        .build())
                .build();
    }
}

