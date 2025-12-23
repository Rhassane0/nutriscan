package com.nutriscan.config;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;

/**
 * Configuration pour l'API Gemini (Google AI)
 * Utilise l'API REST directe - pas besoin de SDK
 */
@Configuration
@Slf4j
@Getter
public class GeminiConfig {

    @Value("${gemini.api.key:}")
    private String apiKey;

    @Value("${gemini.model:gemma-3-27b-it}")
    private String modelName;

    @PostConstruct
    public void init() {
        if (apiKey == null || apiKey.isEmpty() || apiKey.equals("your-gemini-api-key-here")) {
            log.warn("⚠️  Gemini API key not configured. Set gemini.api.key in application.properties");
            log.warn("Get your API key from: https://aistudio.google.com/app/apikey");
            log.warn("AI features will use fallback responses until configured.");
        } else {
            log.info("✅ Gemini AI configured with model: {}", modelName);
            log.info("📍 API endpoint: https://generativelanguage.googleapis.com/v1beta/models/{}", modelName);
        }
    }

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isEmpty() && !apiKey.equals("your-gemini-api-key-here");
    }
}

