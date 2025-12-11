package com.nutriscan.security;

public final class SecurityConstants {

    private SecurityConstants() {}

    public static final String[] PUBLIC_ENDPOINTS = {
            "/api/auth/**",           // Endpoints d'authentification (login, register)
            "/api/v1/auth/**",        // Alternative avec versioning
            "/v3/api-docs/**",        // Documentation OpenAPI
            "/swagger-ui/**",         // Swagger UI
            "/swagger-ui.html"        // Swagger UI HTML
    };
}
