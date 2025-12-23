import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/daily_nutrition_summary.dart';

class MealProvider with ChangeNotifier {
  final MealService _mealService;

  List<Meal> _meals = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateFormatter.getToday();
  DailySummaryData? _dailySummary;

  MealProvider(this._mealService);

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  DailySummaryData? get dailySummary => _dailySummary;

  // Changer la date sélectionnée
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    loadMealsForDate(date);
  }

  // Charger les repas pour une date
  Future<void> loadMealsForDate(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _meals = await _mealService.getMeals(date: date);
      // Charger aussi le résumé complet
      await _loadDailySummary(date);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger le résumé nutritionnel complet
  Future<void> _loadDailySummary(DateTime date) async {
    try {
      final summaryJson = await _mealService.getDailySummary(date: date);
      if (summaryJson.isNotEmpty) {
        _dailySummary = DailySummaryData.fromJson(summaryJson);
      } else {
        // Créer un résumé à partir des repas chargés localement
        _dailySummary = _buildSummaryFromMeals(date);
      }
    } catch (e) {
      debugPrint('Error loading daily summary: $e');
      // Créer un résumé à partir des repas chargés localement
      _dailySummary = _buildSummaryFromMeals(date);
    }
  }

  // Construire un résumé à partir des repas locaux (fallback)
  DailySummaryData _buildSummaryFromMeals(DateTime date) {
    final totals = getDailyTotals();
    final cal = totals['calories'] ?? 0;
    final pro = totals['proteins'] ?? 0;
    final carb = totals['carbs'] ?? 0;
    final fat = totals['fats'] ?? 0;

    // Estimations des micronutriments basées sur les macros
    final fiber = carb * 0.1;
    final sugars = carb * 0.3;
    final sodium = cal * 0.4;
    final calcium = cal * 0.15;
    final iron = cal * 0.003;
    final potassium = cal * 0.5;
    final vitaminC = cal * 0.02;
    final vitaminA = cal * 0.1;
    final vitaminD = cal * 0.002;
    final vitaminE = cal * 0.007;
    final vitaminB12 = cal * 0.001;
    final magnesium = cal * 0.15;
    final zinc = cal * 0.005;
    final cholesterol = cal * 0.05;
    final saturatedFat = fat * 0.35;
    final omega3 = fat * 0.05;

    // Calculer le score nutritionnel
    int score = _calculateNutritionScore(cal, pro, carb, fat, fiber);

    return DailySummaryData(
      date: date,
      totalCalories: cal,
      caloriesGoal: 2000,
      totalProtein: pro,
      proteinGoal: 50,
      totalCarbs: carb,
      carbsGoal: 260,
      totalFat: fat,
      fatGoal: 70,
      totalFiber: fiber,
      totalSugars: sugars,
      totalSodium: sodium,
      totalCalcium: calcium,
      totalIron: iron,
      totalVitaminC: vitaminC,
      totalVitaminA: vitaminA,
      totalVitaminD: vitaminD,
      totalVitaminE: vitaminE,
      totalVitaminB12: vitaminB12,
      totalPotassium: potassium,
      totalMagnesium: magnesium,
      totalZinc: zinc,
      totalCholesterol: cholesterol,
      totalSaturatedFat: saturatedFat,
      totalOmega3: omega3,
      nutritionScore: score,
      mealsCount: _meals.length,
      recommendation: _generateRecommendation(cal, pro, carb, fat, fiber, score),
    );
  }

  int _calculateNutritionScore(double cal, double pro, double carb, double fat, double fiber) {
    if (cal == 0) return 50;

    int score = 50;

    double proRatio = (pro * 4 / cal) * 100;
    if (proRatio >= 15 && proRatio <= 25) score += 15;
    else if (proRatio >= 10 && proRatio <= 30) score += 8;

    double carbRatio = (carb * 4 / cal) * 100;
    if (carbRatio >= 45 && carbRatio <= 55) score += 15;
    else if (carbRatio >= 40 && carbRatio <= 65) score += 8;

    double fatRatio = (fat * 9 / cal) * 100;
    if (fatRatio >= 20 && fatRatio <= 35) score += 15;
    else if (fatRatio >= 15 && fatRatio <= 40) score += 8;

    if (fiber >= 25) score += 5;
    else if (fiber >= 15) score += 3;

    return score.clamp(0, 100);
  }

  String _generateRecommendation(double cal, double pro, double carb, double fat, double fiber, int score) {
    List<String> tips = [];

    if (cal < 1200) {
      tips.add('Apport calorique faible');
    } else if (cal > 2500) {
      tips.add('Attention à l\'excès calorique');
    }

    double proRatio = cal > 0 ? (pro * 4 / cal) * 100 : 0;
    if (proRatio < 15) {
      tips.add('Augmentez vos protéines');
    }

    if (fiber < 20) {
      tips.add('Plus de fibres recommandé');
    }

    if (tips.isEmpty) {
      if (score >= 80) return 'Excellent équilibre nutritionnel ! 🌟';
      if (score >= 60) return 'Bon équilibre ! Continuez ainsi.';
      return 'Variez davantage votre alimentation.';
    }

    return tips.join(' • ');
  }

  // Créer un repas
  Future<bool> createMeal(Map<String, dynamic> mealData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final meal = await _mealService.createMeal(mealData);
      _meals.add(meal);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour un repas
  Future<bool> updateMeal(int id, Map<String, dynamic> mealData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final meal = await _mealService.updateMeal(id, mealData);
      final index = _meals.indexWhere((m) => m.id == id);
      if (index != -1) {
        _meals[index] = meal;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Supprimer un repas
  Future<bool> deleteMeal(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _mealService.deleteMeal(id);
      _meals.removeWhere((m) => m.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtenir les totaux nutritionnels pour la date sélectionnée
  Map<String, double> getDailyTotals() {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var meal in _meals) {
      totalCalories += meal.totalCalories;
      totalProteins += meal.totalProteins;
      totalCarbs += meal.totalCarbs;
      totalFats += meal.totalFats;
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

