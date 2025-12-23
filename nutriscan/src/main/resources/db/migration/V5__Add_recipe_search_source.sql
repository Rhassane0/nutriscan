-- Migration V5: Add RECIPE_SEARCH to meals source enum
-- This migration updates the check constraint on the meals table to accept RECIPE_SEARCH source

-- First, drop the existing constraint
ALTER TABLE meals DROP CONSTRAINT IF EXISTS meals_source_check;

-- Then add the new constraint with all valid values
ALTER TABLE meals ADD CONSTRAINT meals_source_check
CHECK (source IN ('SCAN_PHOTO', 'MANUAL', 'BARCODE', 'MEAL_PLAN', 'API', 'RECIPE_SEARCH'));

