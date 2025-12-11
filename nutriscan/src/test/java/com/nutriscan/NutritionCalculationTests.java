package com.nutriscan;

import com.nutriscan.util.NutritionCalculator;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
public class NutritionCalculationTests {

    private final NutritionCalculator calculator = new NutritionCalculator();

    @Test
    public void testBMRCalculation_Adult() {
        // Mifflin-St Jeor formula for a 30-year-old man, 180cm, 80kg
        // BMR = 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
        double bmr = calculator.calculateBMR(80, 180, 30, "MALE");
        assertTrue(bmr > 1700 && bmr < 1850, "BMR should be around 1780");
    }

    @Test
    public void testBMRCalculation_Female() {
        // BMR for a 25-year-old woman, 170cm, 65kg
        // BMR = 10*65 + 6.25*170 - 5*25 - 161 = 650 + 1062.5 - 125 - 161 = 1426.5
        double bmr = calculator.calculateBMR(65, 170, 25, "FEMALE");
        assertTrue(bmr > 1350 && bmr < 1500, "BMR should be around 1426");
    }

    @Test
    public void testTDEECalculation() {
        double bmr = 1800;
        // Moderate activity (MODERATE = 1.55)
        double tdee = calculator.calculateTDEE(bmr, "MODERATE");
        assertEquals(1800 * 1.55, tdee, 0.1);
    }

    @Test
    public void testCalorieAdjustmentForGoal_LoseWeight() {
        double tdee = 2000;
        // Lose weight: -400 kcal
        double adjusted = calculator.adjustCaloriesForGoal(tdee, "LOSE_WEIGHT");
        assertEquals(1600, adjusted, 10);
    }

    @Test
    public void testCalorieAdjustmentForGoal_GainWeight() {
        double tdee = 2000;
        // Gain weight: +300 kcal
        double adjusted = calculator.adjustCaloriesForGoal(tdee, "GAIN_WEIGHT");
        assertEquals(2300, adjusted, 10);
    }

    @Test
    public void testMacroCalculation_ProteinPerKg() {
        double weight = 80;
        // Protein for weight loss: 2.0 g/kg
        double protein = calculator.calculateProteinTarget(weight, "LOSE_WEIGHT");
        assertEquals(160, protein, 5);
    }

    @Test
    public void testBMICalculation() {
        double height = 180; // cm
        double weight = 80; // kg
        double bmi = calculator.calculateBMI(weight, height);
        double expected = weight / ((height / 100) * (height / 100));
        assertEquals(expected, bmi, 0.1);
    }
}

