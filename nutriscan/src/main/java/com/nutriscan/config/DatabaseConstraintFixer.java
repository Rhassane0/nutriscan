package com.nutriscan.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Component to fix database constraints on application startup.
 * This ensures the meals_source_check constraint includes all valid MealSource values.
 */
@Component
@Order(1)
@Slf4j
@RequiredArgsConstructor
public class DatabaseConstraintFixer implements CommandLineRunner {

    private final JdbcTemplate jdbcTemplate;

    @Override
    public void run(String... args) {
        fixMealsSourceConstraint();
    }

    private void fixMealsSourceConstraint() {
        try {
            log.info("🔧 Checking meals_source_check constraint...");

            // Drop the existing constraint
            try {
                jdbcTemplate.execute("ALTER TABLE meals DROP CONSTRAINT IF EXISTS meals_source_check");
                log.info("✅ Dropped old meals_source_check constraint");
            } catch (Exception e) {
                log.debug("Constraint might not exist: {}", e.getMessage());
            }

            // Add the new constraint with all valid values including RECIPE_SEARCH
            String addConstraintSql = """
                ALTER TABLE meals ADD CONSTRAINT meals_source_check 
                CHECK (source IN ('SCAN_PHOTO', 'MANUAL', 'BARCODE', 'MEAL_PLAN', 'API', 'RECIPE_SEARCH'))
                """;

            try {
                jdbcTemplate.execute(addConstraintSql);
                log.info("✅ Added new meals_source_check constraint with RECIPE_SEARCH");
            } catch (Exception e) {
                // Constraint might already exist with correct values
                log.debug("Constraint might already be correct: {}", e.getMessage());
            }

            log.info("🎉 Database constraints check completed!");

        } catch (Exception e) {
            log.error("❌ Error fixing database constraints: {}", e.getMessage());
            // Don't fail startup, just log the error
        }
    }
}

