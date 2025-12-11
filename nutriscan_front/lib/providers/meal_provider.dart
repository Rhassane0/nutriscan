import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../utils/date_formatter.dart';

class MealProvider with ChangeNotifier {
  final MealService _mealService;

  List<Meal> _meals = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateFormatter.getToday();

  MealProvider(this._mealService);

  List<Meal> get meals => _meals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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

