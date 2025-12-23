package com.nutriscan.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class NutritionApiConfig {

    @Value("${edamam.nutrition.app-id:2f1a97ee}")
    private String appId;

    @Value("${edamam.nutrition.app-key:ca00bfd3d535acc5785e1d31d25d3caa}")
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

