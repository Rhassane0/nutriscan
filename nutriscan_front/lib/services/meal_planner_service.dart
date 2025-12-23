import 'api_service.dart';
import '../models/meal_plan.dart';
import 'package:flutter/foundation.dart';

class MealPlannerService {
  final ApiService _apiService;

  MealPlannerService(this._apiService);

  void _log(String message) {
    if (kDebugMode) {
      print('🍽️ [MealPlanner] $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print('❌ [MealPlanner ERROR] $message');
    }
  }

  Future<List<MealPlan>> getMealPlans() async {
    try {
      _log('Fetching all meal plans...');
      // Backend endpoint: GET /api/meal-planner (retourne une liste)
      final response = await _apiService.get('/meal-planner');

      if (response is List) {
        _log('Got ${response.length} meal plans');
        return response.map((json) => MealPlan.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      _logError('getMealPlans: $e');
      rethrow;
    }
  }

  Future<MealPlan> getMealPlanById(int id) async {
    try {
      _log('Fetching meal plan #$id...');
      // Backend endpoint: GET /api/meal-planner/{id}
      final response = await _apiService.get('/meal-planner/$id');
      return MealPlan.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logError('getMealPlanById($id): $e');
      rethrow;
    }
  }

  Future<MealPlan> generateMealPlan(Map<String, dynamic> preferences) async {
    try {
      _log('Generating meal plan with preferences: $preferences');
      // Backend endpoint: POST /api/meal-planner/generate
      final response = await _apiService.post('/meal-planner/generate', preferences);
      _log('Meal plan generated successfully');
      return MealPlan.fromJson(response);
    } catch (e) {
      _logError('generateMealPlan: $e');
      rethrow;
    }
  }

  Future<void> deleteMealPlan(int id) async {
    try {
      _log('Deleting meal plan #$id...');
      // Backend endpoint: DELETE /api/meal-planner/{id}
      await _apiService.delete('/meal-planner/$id');
      _log('Meal plan #$id deleted');
    } catch (e) {
      _logError('deleteMealPlan($id): $e');
      rethrow;
    }
  }

  Future<MealPlan?> getCurrentWeekPlan() async {
    try {
      _log('Fetching current week plan...');
      // Backend endpoint: GET /api/meal-planner/latest
      final response = await _apiService.get('/meal-planner/latest');
      if (response == null) {
        _log('No current plan found');
        return null;
      }

      final plan = MealPlan.fromJson(response as Map<String, dynamic>);
      // Valider que le plan est bien formé
      if (plan.id <= 0 || plan.meals.isEmpty) {
        _log('Plan invalid (id=${plan.id}, meals=${plan.meals.length})');
        return null;
      }
      _log('Current plan loaded: #${plan.id} with ${plan.meals.length} meals');
      return plan;
    } catch (e) {
      _logError('getCurrentWeekPlan: $e');
      // Retourner null si pas de plan (404 ou toute autre erreur)
      return null;
    }
  }

  /// Ajouter une recette au plan existant
  Future<MealPlan> addRecipeToPlan(int planId, Map<String, dynamic> recipeData) async {
    try {
      _log('Adding recipe to plan #$planId: ${recipeData['recipeName']}');
      final response = await _apiService.post('/meal-planner/$planId/meals', recipeData);
      _log('Recipe added successfully to plan #$planId');
      return MealPlan.fromJson(response);
    } catch (e) {
      _logError('addRecipeToPlan($planId): $e');
      rethrow;
    }
  }

  /// Supprimer un repas du plan
  Future<MealPlan?> removeMealFromPlan(int planId, int mealId) async {
    try {
      await _apiService.delete('/meal-planner/$planId/meals/$mealId');
      // Recharger le plan après suppression
      return await getMealPlanById(planId);
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher des recettes
  Future<List<Map<String, dynamic>>> searchRecipes({
    required String query,
    List<String>? diet,
    List<String>? health,
    String? cuisineType,
    String? mealType,
    int? calories,
    int limit = 10,
  }) async {
    try {
      var url = '/meal-planner/recipes/search?query=$query&limit=$limit';

      if (diet != null && diet.isNotEmpty) {
        url += '&diet=${diet.join(",")}';
      }
      if (health != null && health.isNotEmpty) {
        url += '&health=${health.join(",")}';
      }
      if (cuisineType != null) {
        url += '&cuisineType=$cuisineType';
      }
      if (mealType != null) {
        url += '&mealType=$mealType';
      }
      if (calories != null) {
        url += '&calories=$calories';
      }

      final response = await _apiService.get(url);

      if (response is List) {
        return response.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
