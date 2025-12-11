package com.nutriscan.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class NutritionApiConfig {

    @Value("${edamam.nutrition.app-id:2f1a97ee}")
    private String appId;

    @Value("${edamam.nutrition.app-key:a142242e62efb0ad2b8f7ecfd48d81f5}")
    private String appKey;

    @Value("${edamam.nutrition.base-url:https://api.edamam.com}")
    private String baseUrl;

    public String getAppId() {
        return appId;
    }

    public String getAppKey() {
        return appKey;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    // Legacy methods for backward compatibility
    public String getApiId() {
        return appId;
    }

    public String getApiKey() {
        return appKey;
    }
}

