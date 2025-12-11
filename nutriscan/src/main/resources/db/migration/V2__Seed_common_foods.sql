-- Seed data for common foods in the database
-- V2__Seed_common_foods.sql

INSERT INTO foods (name, category, serving_size, serving_unit, calories_kcal, protein_gr, carbs_gr, fat_gr, fiber_gr, sugar_gr, image_url, source) VALUES
-- Fruits
('Apple, raw', 'Fruits', 100.0, 'g', 52.0, 0.3, 14.0, 0.2, 2.4, 10.0, NULL, 'USDA'),
('Banana, raw', 'Fruits', 100.0, 'g', 89.0, 1.1, 23.0, 0.3, 2.6, 12.0, NULL, 'USDA'),
('Orange, raw', 'Fruits', 100.0, 'g', 47.0, 0.9, 12.0, 0.1, 2.4, 9.0, NULL, 'USDA'),
('Strawberries, raw', 'Fruits', 100.0, 'g', 32.0, 0.7, 7.7, 0.3, 2.0, 4.9, NULL, 'USDA'),
('Blueberries, raw', 'Fruits', 100.0, 'g', 57.0, 0.7, 14.5, 0.3, 2.4, 10.0, NULL, 'USDA'),

-- Vegetables
('Broccoli, raw', 'Vegetables', 100.0, 'g', 34.0, 2.8, 7.0, 0.4, 2.6, 1.7, NULL, 'USDA'),
('Carrot, raw', 'Vegetables', 100.0, 'g', 41.0, 0.9, 10.0, 0.2, 2.8, 4.7, NULL, 'USDA'),
('Spinach, raw', 'Vegetables', 100.0, 'g', 23.0, 2.9, 3.6, 0.4, 2.2, 0.4, NULL, 'USDA'),
('Tomato, raw', 'Vegetables', 100.0, 'g', 18.0, 0.9, 3.9, 0.2, 1.2, 2.6, NULL, 'USDA'),
('Cucumber, raw', 'Vegetables', 100.0, 'g', 15.0, 0.7, 3.6, 0.1, 0.5, 1.7, NULL, 'USDA'),
('Lettuce, raw', 'Vegetables', 100.0, 'g', 15.0, 1.4, 2.9, 0.2, 1.3, 0.8, NULL, 'USDA'),

-- Proteins
('Chicken breast, cooked', 'Proteins', 100.0, 'g', 165.0, 31.0, 0.0, 3.6, 0.0, 0.0, NULL, 'USDA'),
('Chicken breast, raw', 'Proteins', 100.0, 'g', 120.0, 22.5, 0.0, 2.6, 0.0, 0.0, NULL, 'USDA'),
('Beef, ground, cooked', 'Proteins', 100.0, 'g', 250.0, 26.0, 0.0, 15.0, 0.0, 0.0, NULL, 'USDA'),
('Salmon, cooked', 'Proteins', 100.0, 'g', 208.0, 20.0, 0.0, 13.0, 0.0, 0.0, NULL, 'USDA'),
('Tuna, canned in water', 'Proteins', 100.0, 'g', 116.0, 26.0, 0.0, 0.8, 0.0, 0.0, NULL, 'USDA'),
('Egg, whole, cooked', 'Proteins', 100.0, 'g', 155.0, 13.0, 1.1, 11.0, 0.0, 1.1, NULL, 'USDA'),
('Egg, white, cooked', 'Proteins', 100.0, 'g', 52.0, 11.0, 0.7, 0.2, 0.0, 0.7, NULL, 'USDA'),
('Turkey breast, cooked', 'Proteins', 100.0, 'g', 135.0, 30.0, 0.0, 0.7, 0.0, 0.0, NULL, 'USDA'),

-- Dairy
('Milk, whole', 'Dairy', 100.0, 'ml', 61.0, 3.2, 4.8, 3.3, 0.0, 5.0, NULL, 'USDA'),
('Milk, skim', 'Dairy', 100.0, 'ml', 34.0, 3.4, 5.0, 0.1, 0.0, 5.0, NULL, 'USDA'),
('Greek yogurt, plain', 'Dairy', 100.0, 'g', 97.0, 9.0, 3.6, 5.0, 0.0, 3.2, NULL, 'USDA'),
('Cheese, cheddar', 'Dairy', 100.0, 'g', 403.0, 25.0, 1.3, 33.0, 0.0, 0.5, NULL, 'USDA'),
('Cottage cheese, low fat', 'Dairy', 100.0, 'g', 72.0, 12.0, 2.7, 1.0, 0.0, 2.7, NULL, 'USDA'),

-- Grains
('Rice, white, cooked', 'Grains', 100.0, 'g', 130.0, 2.7, 28.0, 0.3, 0.4, 0.0, NULL, 'USDA'),
('Rice, brown, cooked', 'Grains', 100.0, 'g', 112.0, 2.6, 24.0, 0.9, 1.8, 0.4, NULL, 'USDA'),
('Pasta, cooked', 'Grains', 100.0, 'g', 131.0, 5.0, 25.0, 1.1, 1.8, 0.6, NULL, 'USDA'),
('Bread, white', 'Grains', 100.0, 'g', 265.0, 9.0, 49.0, 3.2, 2.7, 5.0, NULL, 'USDA'),
('Bread, whole wheat', 'Grains', 100.0, 'g', 247.0, 13.0, 41.0, 3.4, 6.0, 6.0, NULL, 'USDA'),
('Oatmeal, cooked', 'Grains', 100.0, 'g', 68.0, 2.4, 12.0, 1.4, 1.7, 0.5, NULL, 'USDA'),
('Quinoa, cooked', 'Grains', 100.0, 'g', 120.0, 4.4, 21.0, 1.9, 2.8, 0.9, NULL, 'USDA'),

-- Legumes
('Lentils, cooked', 'Legumes', 100.0, 'g', 116.0, 9.0, 20.0, 0.4, 7.9, 1.8, NULL, 'USDA'),
('Chickpeas, cooked', 'Legumes', 100.0, 'g', 164.0, 8.9, 27.0, 2.6, 7.6, 4.8, NULL, 'USDA'),
('Black beans, cooked', 'Legumes', 100.0, 'g', 132.0, 8.9, 24.0, 0.5, 8.7, 0.3, NULL, 'USDA'),

-- Nuts & Seeds
('Almonds', 'Nuts', 100.0, 'g', 579.0, 21.0, 22.0, 50.0, 12.5, 4.4, NULL, 'USDA'),
('Peanuts', 'Nuts', 100.0, 'g', 567.0, 26.0, 16.0, 49.0, 8.5, 4.7, NULL, 'USDA'),
('Walnuts', 'Nuts', 100.0, 'g', 654.0, 15.0, 14.0, 65.0, 6.7, 2.6, NULL, 'USDA'),

-- Oils & Fats
('Olive oil', 'Fats', 100.0, 'ml', 884.0, 0.0, 0.0, 100.0, 0.0, 0.0, NULL, 'USDA'),
('Butter', 'Fats', 100.0, 'g', 717.0, 0.9, 0.1, 81.0, 0.0, 0.1, NULL, 'USDA'),
('Avocado', 'Fats', 100.0, 'g', 160.0, 2.0, 9.0, 15.0, 7.0, 0.7, NULL, 'USDA'),

-- Beverages
('Orange juice', 'Beverages', 100.0, 'ml', 45.0, 0.7, 10.0, 0.2, 0.2, 8.4, NULL, 'USDA'),
('Coffee, black', 'Beverages', 100.0, 'ml', 2.0, 0.3, 0.0, 0.0, 0.0, 0.0, NULL, 'USDA'),
('Green tea', 'Beverages', 100.0, 'ml', 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, NULL, 'USDA'),

-- Snacks
('Dark chocolate (70%)', 'Snacks', 100.0, 'g', 598.0, 7.8, 46.0, 43.0, 11.0, 24.0, NULL, 'USDA'),
('Honey', 'Snacks', 100.0, 'g', 304.0, 0.3, 82.0, 0.0, 0.2, 82.0, NULL, 'USDA'),

-- Common dishes
('Pizza, cheese', 'Dishes', 100.0, 'g', 266.0, 11.0, 33.0, 10.0, 2.3, 3.6, NULL, 'USDA'),
('Hamburger', 'Dishes', 100.0, 'g', 295.0, 17.0, 24.0, 14.0, 1.3, 5.0, NULL, 'USDA'),
('French fries', 'Dishes', 100.0, 'g', 312.0, 3.4, 41.0, 15.0, 3.8, 0.3, NULL, 'USDA'),
('Salad, mixed greens', 'Dishes', 100.0, 'g', 17.0, 1.3, 3.3, 0.2, 1.8, 1.3, NULL, 'USDA');
