class CalorieCalculator {
  // Mifflin-St Jeor
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    final s = gender.toLowerCase() == 'male' || gender.toLowerCase() == 'm' ? 5.0 : -161.0;
    return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) + s;
  }

  static double calculateDailyCalories({
    required double bmr,
    required String activityLevel,
    required String goalType,
  }) {
    final activityMap = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'veryActive': 1.9,
    };
    final multiplier = activityMap[activityLevel] ?? 1.2;
    final maintenance = bmr * multiplier;
    double target;
    if (goalType == 'gain') {
      target = maintenance + 500.0;
    } else if (goalType == 'lose') {
      target = (maintenance - 500.0).clamp(1200.0, double.infinity);
    } else {
      target = maintenance;
    }
    return target;
  }
}

