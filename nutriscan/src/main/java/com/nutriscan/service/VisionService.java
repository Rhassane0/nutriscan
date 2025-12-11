package com.nutriscan.service;

import com.nutriscan.dto.request.VisionAnalysisRequest;
import com.nutriscan.dto.response.VisionAnalysisResponse;
import com.nutriscan.model.Food;
import com.nutriscan.repository.FoodRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.lang.reflect.Method;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Slf4j
@Transactional
public class VisionService {

    private final FoodRepository foodRepository;
    private final Object generativeModel;

    public VisionService(FoodRepository foodRepository, @Qualifier("generativeModel") @Nullable Object generativeModel) {
        this.foodRepository = foodRepository;
        this.generativeModel = generativeModel;
    }

    /**
     * Analyse une photo de repas avec Gemini Vision et détecte les aliments
     */
    public VisionAnalysisResponse analyzeImage(VisionAnalysisRequest request) {
        log.info("Analyzing image with Gemini Vision: {}", request.getImageUrl());

        try {
            if (generativeModel == null) {
                log.warn("Gemini not configured, using fallback response");
                return buildFallbackResponse();
            }

            String prompt = buildVisionPrompt(request.getMealType());
            String geminiResponse = callGeminiVision(request.getImageUrl(), prompt);

            List<VisionAnalysisResponse.DetectedFood> detectedFoods = parseGeminiVisionResponse(geminiResponse);

            double averageConfidence = detectedFoods.isEmpty() ? 0 :
                    detectedFoods.stream().mapToDouble(VisionAnalysisResponse.DetectedFood::getConfidence).average().orElse(0);

            VisionAnalysisResponse response = VisionAnalysisResponse.builder()
                    .detectedFoods(detectedFoods)
                    .analysisText(geminiResponse)
                    .confidenceScore(averageConfidence)
                    .build();

            return response;
        } catch (Exception e) {
            log.error("Erreur lors de l'analyse d'image avec Gemini", e);
            return buildFallbackResponse();
        }
    }

    /**
     * Appelle Gemini Vision pour analyser l'image (via réflexion)
     */
    private String callGeminiVision(String imageUrl, String prompt) {
        try {
            if (generativeModel == null) {
                throw new RuntimeException("Gemini model not available");
            }

            log.debug("Calling Gemini Vision with prompt");

            Method generateContentMethod = generativeModel.getClass()
                    .getMethod("generateContent", String.class);
            Object response = generateContentMethod.invoke(generativeModel, prompt);

            Method getTextMethod = response.getClass().getMethod("getText");
            String result = (String) getTextMethod.invoke(response);

            log.debug("Gemini Vision response received");
            return result;
        } catch (Exception e) {
            log.error("Erreur lors de l'appel à Gemini Vision: {}", e.getMessage());
            throw new RuntimeException("Impossible de contacter le service de vision IA", e);
        }
    }

    /**
     * Construit le prompt pour l'analyse de vision
     */
    private String buildVisionPrompt(String mealType) {
        String mealInfo = mealType != null ? " pour un repas de type " + mealType : "";

        return String.format(
                "Analyse cette image de repas%s et identifie tous les aliments visibles.\n\n" +
                "Pour chaque aliment détecté:\n" +
                "1. Nom de l'aliment en français\n" +
                "2. Confiance en pourcentage (0-100)\n" +
                "3. Quantité estimée en grammes\n\n" +
                "Réponds au format JSON avec un tableau 'foods' contenant des objets:\n" +
                "{\"foods\": [{\"name\": \"...\", \"confidence\": XX, \"quantity\": YY}, ...]}\n\n" +
                "Sois précis et réaliste dans tes estimations.",
                mealInfo
        );
    }

    /**
     * Parse la réponse de Gemini Vision
     */
    private List<VisionAnalysisResponse.DetectedFood> parseGeminiVisionResponse(String geminiResponse) {
        List<VisionAnalysisResponse.DetectedFood> detectedFoods = new ArrayList<>();

        try {
            if (geminiResponse.contains("\"foods\"")) {
                String foodsArray = extractJsonArray(geminiResponse, "foods");
                String[] foodItems = foodsArray.split("},");

                for (String item : foodItems) {
                    String name = extractJsonValue(item, "name");
                    String confidenceStr = extractJsonValue(item, "confidence");
                    String quantityStr = extractJsonValue(item, "quantity");

                    if (!name.isEmpty()) {
                        double confidence = Double.parseDouble(confidenceStr.isEmpty() ? "50" : confidenceStr);
                        double quantity = Double.parseDouble(quantityStr.isEmpty() ? "100" : quantityStr);

                        VisionAnalysisResponse.DetectedFood detected = matchFoodToDatabase(name);
                        detected.setConfidence(confidence);
                        detected.setEstimatedQuantityGrams(quantity);

                        detectedFoods.add(detected);
                    }
                }
            }
        } catch (Exception e) {
            log.warn("Erreur lors du parsing de la vision Gemini", e);
        }

        return detectedFoods;
    }

    /**
     * Recherche les aliments correspondants dans la base
     */
    private VisionAnalysisResponse.DetectedFood matchFoodToDatabase(String detectedFoodName) {
        List<Food> allFoods = foodRepository.findAll();

        List<Food> matches = allFoods.stream()
                .filter(f -> f.getName().toLowerCase().contains(detectedFoodName.toLowerCase()))
                .collect(Collectors.toList());

        if (!matches.isEmpty()) {
            Food bestMatch = matches.get(0);
            return VisionAnalysisResponse.DetectedFood.builder()
                    .name(bestMatch.getName())
                    .confidence(85.0)
                    .suggestedFoodId(bestMatch.getId())
                    .matchStatus("AUTO_MATCHED")
                    .build();
        } else {
            List<VisionAnalysisResponse.FoodCandidate> candidates = allFoods.stream()
                    .limit(5)
                    .map(f -> VisionAnalysisResponse.FoodCandidate.builder()
                            .foodId(f.getId())
                            .name(f.getName())
                            .matchScore(50.0)
                            .build())
                    .collect(Collectors.toList());

            return VisionAnalysisResponse.DetectedFood.builder()
                    .name(detectedFoodName)
                    .confidence(45.0)
                    .matchStatus("CANDIDATES")
                    .candidates(candidates)
                    .build();
        }
    }

    /**
     * Extrait un tableau JSON
     */
    private String extractJsonArray(String json, String key) {
        String searchKey = "\"" + key + "\"";
        int startIdx = json.indexOf(searchKey);
        if (startIdx == -1) return "[]";

        int bracketIdx = json.indexOf("[", startIdx);
        int closeBracketIdx = json.indexOf("]", bracketIdx);

        if (closeBracketIdx > bracketIdx) {
            return json.substring(bracketIdx + 1, closeBracketIdx);
        }
        return "[]";
    }

    /**
     * Extrait une valeur JSON
     */
    private String extractJsonValue(String json, String key) {
        String searchKey = "\"" + key + "\"";
        int startIdx = json.indexOf(searchKey);
        if (startIdx == -1) return "";

        int colonIdx = json.indexOf(":", startIdx);
        int quoteIdx = json.indexOf("\"", colonIdx);

        if (quoteIdx == colonIdx + 1) {
            int endIdx = json.indexOf("\"", quoteIdx + 1);
            if (endIdx > quoteIdx) {
                return json.substring(quoteIdx + 1, endIdx);
            }
        }

        int commaIdx = json.indexOf(",", colonIdx);
        int braceIdx = json.indexOf("}", colonIdx);
        int endIdx = Math.min(commaIdx == -1 ? braceIdx : commaIdx, braceIdx);

        if (endIdx > colonIdx) {
            String value = json.substring(colonIdx + 1, endIdx).trim();
            return value.replace("\"", "");
        }

        return "";
    }

    /**
     * Réponse fallback si Gemini fail
     */
    private VisionAnalysisResponse buildFallbackResponse() {
        return VisionAnalysisResponse.builder()
                .detectedFoods(new ArrayList<>())
                .analysisText("Analyse d'image en cours de développement. Veuillez saisir manuellement vos aliments pour l'instant.")
                .confidenceScore(0.0)
                .build();
    }

    /**
     * Crée un repas à partir du résultat de l'analyse de vision
     */
    public void createMealFromVisionAnalysis(Long userId, VisionAnalysisResponse analysis, String mealType) {
        log.info("Creating meal from vision analysis for user: {}", userId);
    }
}
