package com.nutriscan.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;


@Configuration
public class CorsConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        System.out.println("🟢 CORS Configuration loaded!");

        CorsConfiguration configuration = new CorsConfiguration();

        // Autoriser TOUS les ports localhost pour le développement
        configuration.addAllowedOriginPattern("http://localhost:*");
        configuration.addAllowedOriginPattern("http://127.0.0.1:*");

        // Autoriser tous les headers
        configuration.addAllowedHeader("*");

        // Autoriser toutes les méthodes HTTP
        configuration.addAllowedMethod("*");

        // Autoriser les credentials (cookies, authorization headers, etc.)
        configuration.setAllowCredentials(true);

        // Exposer les headers d'autorisation dans les réponses
        configuration.addExposedHeader("Authorization");
        configuration.addExposedHeader("Content-Type");

        // Durée de cache pour les requêtes preflight
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }
}

