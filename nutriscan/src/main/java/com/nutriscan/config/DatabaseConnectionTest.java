package com.nutriscan.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;

@Configuration
public class DatabaseConnectionTest {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseConnectionTest.class);

    @Bean
    public CommandLineRunner testDatabaseConnection(DataSource dataSource) {
        return args -> {
            try (Connection connection = dataSource.getConnection()) {
                DatabaseMetaData metaData = connection.getMetaData();

                logger.info("=================================================");
                logger.info("📊 TEST DE CONNEXION À LA BASE DE DONNÉES");
                logger.info("=================================================");
                logger.info("✅ Connexion réussie !");
                logger.info("🗄️  URL: {}", metaData.getURL());
                logger.info("👤 Utilisateur: {}", metaData.getUserName());
                logger.info("🏷️  Base de données: {} {}", metaData.getDatabaseProductName(), metaData.getDatabaseProductVersion());
                logger.info("🔌 Driver: {} {}", metaData.getDriverName(), metaData.getDriverVersion());
                logger.info("📊 Catalogue: {}", connection.getCatalog());
                logger.info("🔒 Auto-commit: {}", connection.getAutoCommit());
                logger.info("🔐 Read-only: {}", connection.isReadOnly());
                logger.info("=================================================");

            } catch (Exception e) {
                logger.error("=================================================");
                logger.error("❌ ERREUR DE CONNEXION À LA BASE DE DONNÉES");
                logger.error("=================================================");
                logger.error("Message: {}", e.getMessage());
                logger.error("Type: {}", e.getClass().getName());
                logger.error("=================================================");
                throw new RuntimeException("Impossible de se connecter à la base de données", e);
            }
        };
    }
}

