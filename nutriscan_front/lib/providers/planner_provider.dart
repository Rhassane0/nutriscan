import 'package:flutter/foundation.dart';
import '../models/meal_plan.dart';
import '../models/grocery_list.dart';
import '../services/meal_planner_service.dart';
import '../services/grocery_service.dart';

class PlannerProvider with ChangeNotifier {
  final MealPlannerService _mealPlannerService;
  final GroceryService _groceryService;

  MealPlan? _currentPlan;
  GroceryList? _currentGroceryList;
  bool _isLoading = false;
  String? _error;

  PlannerProvider(this._mealPlannerService, this._groceryService);

  MealPlan? get currentPlan => _currentPlan;
  GroceryList? get currentGroceryList => _currentGroceryList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Générer un plan de repas
  Future<bool> generateMealPlan(Map<String, dynamic> preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPlan = await _mealPlannerService.generateMealPlan(preferences);
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

  // Charger le plan de la semaine en cours
  Future<void> loadCurrentWeekPlan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPlan = await _mealPlannerService.getCurrentWeekPlan();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Si c'est une erreur 404, ce n'est pas une vraie erreur, juste pas de plan
      if (e.toString().contains('404') || e.toString().contains('non trouvée')) {
        _currentPlan = null;
        _error = null;
      } else {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer le plan
  Future<bool> deleteMealPlan() async {
    if (_currentPlan == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _mealPlannerService.deleteMealPlan(_currentPlan!.id);
      _currentPlan = null;
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

  // Générer une liste de courses depuis le plan actuel
  Future<bool> generateGroceryListFromPlan() async {
    if (_currentPlan == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentGroceryList = await _groceryService.generateFromMealPlan(_currentPlan!.id);
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

  // Charger les listes de courses
  Future<void> loadGroceryLists() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charger la liste la plus récente
      _currentGroceryList = await _groceryService.getLatestGroceryList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Si c'est une erreur 404, ce n'est pas une vraie erreur
      if (e.toString().contains('404') || e.toString().contains('non trouvée')) {
        _currentGroceryList = null;
        _error = null;
      } else {
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le statut d'un article
  Future<void> toggleItemPurchased(int itemId, bool purchased) async {
    if (_currentGroceryList == null) return;

    try {
      _currentGroceryList = await _groceryService.updateItemStatus(
        _currentGroceryList!.id,
        itemId,
        purchased,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

