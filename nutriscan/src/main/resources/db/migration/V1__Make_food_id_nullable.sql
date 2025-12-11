-- Migration: Make food_id nullable in meal_items table
-- This allows storing API foods that don't have a local database reference

ALTER TABLE meal_items
ALTER COLUMN food_id DROP NOT NULL;

-- Also add the new columns if they don't exist (Hibernate should create them)
-- But just in case, here's the SQL:
ALTER TABLE meal_items
ADD COLUMN IF NOT EXISTS food_name VARCHAR(255);

ALTER TABLE meal_items
ADD COLUMN IF NOT EXISTS serving_unit VARCHAR(50);

