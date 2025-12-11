package com.nutriscan.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.lang.Nullable;

@Configuration
@Slf4j
public class GeminiConfig {

    @Value("${gemini.api.key:}")
    private String apiKey;

    @Value("${gemini.model:gemini-2.0-flash}")
    private String modelName;

    @Bean
    @ConditionalOnProperty(name = "gemini.api.key", matchIfMissing = false)
    @Nullable
    public Object generativeModel() {
        try {
            // Check if API key is configured
            if (apiKey == null || apiKey.isEmpty() || apiKey.equals("your-gemini-api-key-here")) {
                log.warn("⚠️  Gemini API key not configured. Set gemini.api.key in application.properties");
                log.warn("Get your API key from: https://aistudio.google.com/app/apikey");
                return null;
            }

            log.info("Initializing Gemini model: {}", modelName);

            // Try to load the Gemini class dynamically
            Class<?> generativeModelClass = Class.forName("com.google.generativeai.GenerativeModel");

            // Create instance using reflection
            Object instance = generativeModelClass
                    .getDeclaredConstructor(String.class, String.class)
                    .newInstance(modelName, apiKey);

            log.info("Gemini GenerativeModel bean created successfully");
            return instance;

        } catch (ClassNotFoundException e) {
            log.warn("⚠️  Gemini library not available on classpath. AI features will use fallback responses.");
            log.warn("To enable Gemini: ensure google-generativeai dependency is in pom.xml");
            return null;
        } catch (Exception e) {
            log.error("Error initializing Gemini model", e);
            return null;
        }
    }
}

