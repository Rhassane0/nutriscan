-- Add fiber and sugar columns to foods table
ALTER TABLE foods ADD COLUMN IF NOT EXISTS fiber_gr DOUBLE;
ALTER TABLE foods ADD COLUMN IF NOT EXISTS sugar_gr DOUBLE;

