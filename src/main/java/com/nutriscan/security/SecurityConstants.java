package com.nutriscan.security;

public final class SecurityConstants {

    private SecurityConstants() {}

    public static final String[] PUBLIC_ENDPOINTS = {
            "/api/v1/auth/**",
            "/v3/api-docs/**",
            "/swagger-ui/**",
            "/swagger-ui.html"
    };
}
