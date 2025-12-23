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

  void _log(String message) {
    if (kDebugMode) {
      print('📅 [PlannerProvider] $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print('❌ [PlannerProvider ERROR] $message');
    }
  }

  // Générer un plan de repas
  Future<bool> generateMealPlan(Map<String, dynamic> preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log('Generating meal plan with preferences: $preferences');
      _currentPlan = await _mealPlannerService.generateMealPlan(preferences);
      _log('Meal plan generated successfully: ${_currentPlan?.id}');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logError('generateMealPlan: $e');
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
      _log('Loading current week plan...');
      final plan = await _mealPlannerService.getCurrentWeekPlan();
      // Vérifier que le plan est valide (id > 0 et a des repas)
      if (plan != null && plan.id > 0 && plan.meals.isNotEmpty) {
        _currentPlan = plan;
        _log('Current plan loaded: #${plan.id} with ${plan.meals.length} meals');
      } else {
        _currentPlan = null;
        _log('No valid current plan found');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Si c'est une erreur 404, ce n'est pas une vraie erreur, juste pas de plan
      if (e.toString().contains('404') || e.toString().contains('non trouvée') || e.toString().contains('No meal plans')) {
        _currentPlan = null;
        _error = null;
        _log('No meal plans found (404)');
      } else {
        _logError('loadCurrentWeekPlan: $e');
        _error = e.toString();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer le plan
  Future<bool> deleteMealPlan() async {
    if (_currentPlan == null) {
      _log('No plan to delete');
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log('Deleting meal plan #${_currentPlan!.id}...');
      await _mealPlannerService.deleteMealPlan(_currentPlan!.id);
      _log('Meal plan deleted successfully');
      _currentPlan = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logError('deleteMealPlan: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ajouter une recette au plan existant
  Future<bool> addRecipeToPlan(Map<String, dynamic> recipeData) async {
    if (_currentPlan == null) {
      _logError('addRecipeToPlan: No current plan');
      _error = 'Aucun plan actif. Créez d\'abord un plan de repas.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _log('Adding recipe to plan #${_currentPlan!.id}: ${recipeData['recipeName']}');
      _currentPlan = await _mealPlannerService.addRecipeToPlan(_currentPlan!.id, recipeData);
      _log('Recipe added successfully');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _logError('addRecipeToPlan: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Supprimer un repas du plan
  Future<bool> removeMealFromPlan(int mealId) async {
    if (_currentPlan == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPlan = await _mealPlannerService.removeMealFromPlan(_currentPlan!.id, mealId);
      if (updatedPlan != null) {
        _currentPlan = updatedPlan;
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

