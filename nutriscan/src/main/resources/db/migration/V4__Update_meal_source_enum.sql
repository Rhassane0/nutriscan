-- Migration V4: Add MEAL_PLAN and API to meals source enum
-- This migration updates the check constraint on the meals table to accept new source values

-- First, drop the existing constraint
ALTER TABLE meals DROP CONSTRAINT IF EXISTS meals_source_check;

-- Then add the new constraint with updated values
ALTER TABLE meals ADD CONSTRAINT meals_source_check
CHECK (source IN ('SCAN_PHOTO', 'MANUAL', 'BARCODE', 'MEAL_PLAN', 'API'));

