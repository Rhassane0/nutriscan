package com.nutriscan.service;

import com.nutriscan.dto.request.VisionAnalysisRequest;
import com.nutriscan.dto.response.VisionAnalysisResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@Slf4j
@Transactional
public class VisionService {

    private final RestTemplate restTemplate;

    @Value("${gemini.api.key:}")
    private String geminiApiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String modelName;

    public VisionService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Analyse une photo de repas avec Gemini Vision et détecte les aliments
     */
    public VisionAnalysisResponse analyzeImage(VisionAnalysisRequest request) {
        log.info("Analyzing meal image with Gemini Vision");

        // Vérifier si une clé API Gemini valide est configurée
        if (geminiApiKey == null || geminiApiKey.isEmpty() || geminiApiKey.equals("your-gemini-api-key-here")) {
            log.warn("⚠️ Gemini API key not configured!");
            log.warn("Pour activer l'analyse d'images par IA:");
            log.warn("1. Obtenez une clé gratuite sur: https://aistudio.google.com/app/apikey");
            log.warn("2. Ajoutez-la dans application.properties: gemini.api.key=VOTRE_CLE");
            return buildFallbackWithInstructions();
        }

        try {
            String imageData = request.getImageUrl();
            // Extraire le base64 si c'est un data URL
            if (imageData != null && imageData.contains("base64,")) {
                imageData = imageData.split("base64,")[1];
            }

            if (imageData == null || imageData.isEmpty()) {
                log.error("No image data provided");
                return buildFallbackWithInstructions();
            }

            String prompt = buildVisionPrompt(request.getMealType());
            String geminiResponse = callGeminiVisionAPI(imageData, prompt);

            if (geminiResponse == null || geminiResponse.isEmpty()) {
                log.warn("Empty response from Gemini");
                return buildFallbackWithInstructions();
            }

            log.info("Gemini response: {}", geminiResponse);

            List<VisionAnalysisResponse.DetectedFood> detectedFoods = parseGeminiVisionResponse(geminiResponse);

            if (detectedFoods.isEmpty()) {
                log.warn("No foods detected from Gemini response");
                return buildFallbackWithInstructions();
            }

            double averageConfidence = detectedFoods.stream()
                    .mapToDouble(VisionAnalysisResponse.DetectedFood::getConfidence)
                    .average().orElse(0);

            return VisionAnalysisResponse.builder()
                    .detectedFoods(detectedFoods)
                    .analysisText(cleanAnalysisText(geminiResponse))
                    .confidenceScore(averageConfidence)
                    .build();

        } catch (Exception e) {
            log.error("Error analyzing image with Gemini: {}", e.getMessage(), e);
            return buildFallbackWithInstructions();
        }
    }

    /**
     * Appelle l'API REST de Gemini Vision
     */
    private String callGeminiVisionAPI(String base64Image, String prompt) {
        try {
            String url = "https://generativelanguage.googleapis.com/v1beta/models/" + modelName + ":generateContent?key=" + geminiApiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            // Construire le body avec l'image inline
            Map<String, Object> requestBody = new HashMap<>();
            List<Map<String, Object>> contents = new ArrayList<>();
            Map<String, Object> content = new HashMap<>();
            List<Map<String, Object>> parts = new ArrayList<>();

            // Partie texte (prompt)
            Map<String, Object> textPart = new HashMap<>();
            textPart.put("text", prompt);
            parts.add(textPart);

            // Partie image
            Map<String, Object> imagePart = new HashMap<>();
            Map<String, Object> inlineData = new HashMap<>();
            inlineData.put("mimeType", "image/jpeg");
            inlineData.put("data", base64Image);
            imagePart.put("inlineData", inlineData);
            parts.add(imagePart);

            content.put("parts", parts);
            contents.add(content);
            requestBody.put("contents", contents);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            log.info("🚀 Calling Gemini Vision API with model: {}", modelName);
            log.info("📍 API URL: https://generativelanguage.googleapis.com/v1beta/models/{}", modelName);

            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.POST, entity, Map.class);

            log.info("📥 Gemini response status: {}", response.getStatusCode());

            if (response.getBody() != null) {
                // Vérifier les erreurs
                if (response.getBody().containsKey("error")) {
                    Map<String, Object> error = (Map<String, Object>) response.getBody().get("error");
                    log.error("❌ Gemini API error: {}", error);
                    log.error("❌ Error code: {}, message: {}", error.get("code"), error.get("message"));
                    return null;
                }

                List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.getBody().get("candidates");
                if (candidates != null && !candidates.isEmpty()) {
                    Map<String, Object> candidate = candidates.get(0);
                    Map<String, Object> contentResp = (Map<String, Object>) candidate.get("content");
                    if (contentResp != null) {
                        List<Map<String, Object>> partsResp = (List<Map<String, Object>>) contentResp.get("parts");
                        if (partsResp != null && !partsResp.isEmpty()) {
                            String text = (String) partsResp.get(0).get("text");
                            log.info("✅ Gemini Vision response received ({} chars)", text.length());
                            return text;
                        }
                    }
                }

                log.warn("⚠️ No candidates in response. Full response: {}", response.getBody());
            }

            log.warn("⚠️ No valid response from Gemini API");
            return null;
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            log.error("❌ HTTP Client Error calling Gemini API: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            return null;
        } catch (org.springframework.web.client.HttpServerErrorException e) {
            log.error("❌ HTTP Server Error calling Gemini API: {} - {}", e.getStatusCode(), e.getResponseBodyAsString());
            return null;
        } catch (Exception e) {
            log.error("❌ Error calling Gemini Vision API: {} - {}", e.getClass().getSimpleName(), e.getMessage());
            return null;
        }
    }

    /**
     * Construit le prompt pour l'analyse de vision
     */
    private String buildVisionPrompt(String mealType) {
        String mealInfo = mealType != null ? " (type de repas: " + mealType + ")" : "";

        return "Tu es un expert nutritionniste. Analyse cette photo de repas" + mealInfo + " et identifie TOUS les aliments visibles.\n\n" +
                "Pour CHAQUE aliment que tu vois, donne:\n" +
                "- name: nom de l'aliment en français\n" +
                "- quantity: quantité estimée en grammes\n" +
                "- calories: calories estimées pour cette portion\n" +
                "- proteins: protéines en grammes\n" +
                "- carbs: glucides en grammes\n" +
                "- fats: lipides en grammes\n\n" +
                "IMPORTANT: Réponds UNIQUEMENT avec un JSON valide, sans texte avant ou après, sans ```:\n" +
                "{\"foods\": [{\"name\": \"...\", \"quantity\": 100, \"calories\": 150, \"proteins\": 10, \"carbs\": 20, \"fats\": 5}]}\n\n" +
                "Sois précis et réaliste. Analyse bien l'image.";
    }

    /**
     * Parse la réponse de Gemini Vision
     */
    private List<VisionAnalysisResponse.DetectedFood> parseGeminiVisionResponse(String geminiResponse) {
        List<VisionAnalysisResponse.DetectedFood> detectedFoods = new ArrayList<>();

        try {
            // Nettoyer la réponse (enlever markdown si présent)
            String cleanResponse = geminiResponse
                    .replaceAll("```json\\s*", "")
                    .replaceAll("```\\s*", "")
                    .replaceAll("```", "")
                    .trim();

            log.debug("Cleaned response: {}", cleanResponse);

            // Trouver le JSON dans la réponse
            int jsonStart = cleanResponse.indexOf("{");
            int jsonEnd = cleanResponse.lastIndexOf("}");

            if (jsonStart >= 0 && jsonEnd > jsonStart) {
                cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
            }

            // Extraire le tableau foods
            Pattern foodsPattern = Pattern.compile("\"foods\"\\s*:\\s*\\[(.*?)\\]", Pattern.DOTALL);
            Matcher foodsMatcher = foodsPattern.matcher(cleanResponse);

            if (foodsMatcher.find()) {
                String foodsArray = foodsMatcher.group(1);
                log.debug("Foods array: {}", foodsArray);

                // Parser chaque aliment avec une regex plus robuste
                Pattern foodPattern = Pattern.compile("\\{[^{}]*\\}");
                Matcher foodMatcher = foodPattern.matcher(foodsArray);

                while (foodMatcher.find()) {
                    String foodJson = foodMatcher.group();
                    log.debug("Parsing food: {}", foodJson);

                    String name = extractJsonStringValue(foodJson, "name");
                    double quantity = extractJsonNumberValue(foodJson, "quantity", 100);
                    double calories = extractJsonNumberValue(foodJson, "calories", 0);
                    double proteins = extractJsonNumberValue(foodJson, "proteins", 0);
                    double carbs = extractJsonNumberValue(foodJson, "carbs", 0);
                    double fats = extractJsonNumberValue(foodJson, "fats", 0);

                    if (!name.isEmpty()) {
                        VisionAnalysisResponse.DetectedFood detected = VisionAnalysisResponse.DetectedFood.builder()
                                .name(name)
                                .confidence(85.0)
                                .estimatedQuantityGrams(quantity)
                                .estimatedCalories(calories)
                                .estimatedProteins(proteins)
                                .estimatedCarbs(carbs)
                                .estimatedFats(fats)
                                .matchStatus("AI_DETECTED")
                                .candidates(new ArrayList<>())
                                .build();

                        detectedFoods.add(detected);
                        log.info("✅ Detected: {} - {}g, {}kcal, P:{}g, C:{}g, F:{}g",
                                name, quantity, calories, proteins, carbs, fats);
                    }
                }
            } else {
                log.warn("Could not find 'foods' array in response");
            }
        } catch (Exception e) {
            log.error("Error parsing Gemini response: {}", e.getMessage(), e);
        }

        return detectedFoods;
    }

    private String extractJsonStringValue(String json, String key) {
        // Essayer avec guillemets doubles
        Pattern pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return matcher.group(1);
        }
        // Essayer avec guillemets simples
        pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*'([^']+)'");
        matcher = pattern.matcher(json);
        return matcher.find() ? matcher.group(1) : "";
    }

    private double extractJsonNumberValue(String json, String key, double defaultValue) {
        Pattern pattern = Pattern.compile("\"" + key + "\"\\s*:\\s*([\\d.]+)");
        Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            try {
                return Double.parseDouble(matcher.group(1));
            } catch (NumberFormatException e) {
                return defaultValue;
            }
        }
        return defaultValue;
    }

    private String cleanAnalysisText(String geminiResponse) {
        // Nettoyer pour extraire un texte lisible
        String clean = geminiResponse
                .replaceAll("```json\\s*", "")
                .replaceAll("```\\s*", "")
                .replaceAll("\\{.*\\}", "")
                .trim();

        if (clean.isEmpty()) {
            return "Analyse effectuée avec succès par l'IA.";
        }
        return clean.length() > 500 ? clean.substring(0, 500) + "..." : clean;
    }

    /**
     * Réponse fallback avec instructions pour configurer Gemini - sans données de démonstration
     */
    private VisionAnalysisResponse buildFallbackWithInstructions() {
        // Message explicatif pour l'utilisateur
        String message = "⚠️ L'analyse d'image par IA n'est pas configurée.\n\n" +
                "Pour activer cette fonctionnalité:\n" +
                "1. Obtenez une clé API Gemini gratuite sur aistudio.google.com\n" +
                "2. Configurez-la dans le backend (application.properties: gemini.api.key=VOTRE_CLE)\n\n" +
                "Veuillez configurer l'API pour utiliser cette fonctionnalité.";

        return VisionAnalysisResponse.builder()
                .detectedFoods(new ArrayList<>())
                .analysisText(message)
                .confidenceScore(0.0)
                .build();
    }
}
