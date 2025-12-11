package com.nutriscan.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenFoodFactsConfig {

    @Value("${openfoodfacts.base-url:https://world.openfoodfacts.org/api}")
    private String baseUrl;

    @Value("${openfoodfacts.user-agent:NutriScan/1.0}")
    private String userAgent;

    public String getBaseUrl() {
        return baseUrl;
    }

    public String getUserAgent() {
        return userAgent;
    }
}

