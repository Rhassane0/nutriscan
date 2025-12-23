import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan_front/services/calorie_calculator.dart';

void main() {
  test('BMR calculation male example', () {
    final bmr = CalorieCalculator.calculateBmr(weightKg: 70, heightCm: 175, age: 30, gender: 'male');
    expect(bmr, closeTo(1648.75, 0.5));
  });

  test('Daily calories maintenance moderate', () {
    final bmr = 1648.75;
    final calories = CalorieCalculator.calculateDailyCalories(bmr: bmr, activityLevel: 'moderate', goalType: 'maintain');
    expect(calories, closeTo(1648.75 * 1.55, 1.0));
  });

  test('Daily calories lose clamps', () {
    final bmr = 1000.0;
    final calories = CalorieCalculator.calculateDailyCalories(bmr: bmr, activityLevel: 'sedentary', goalType: 'lose');
    expect(calories >= 1200.0, true);
  });
}
