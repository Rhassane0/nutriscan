import 'api_service.dart';
import '../models/meal_plan.dart';

class MealPlannerService {
  final ApiService _apiService;

  MealPlannerService(this._apiService);

  Future<List<MealPlan>> getMealPlans() async {
    try {
      // Backend endpoint: GET /api/meal-planner (retourne une liste)
      final response = await _apiService.get('/meal-planner');

      if (response is List) {
        return response.map((json) => MealPlan.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<MealPlan> getMealPlanById(int id) async {
    try {
      // Backend endpoint: GET /api/meal-planner/{id}
      final response = await _apiService.get('/meal-planner/$id');
      return MealPlan.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<MealPlan> generateMealPlan(Map<String, dynamic> preferences) async {
    try {
      // Backend endpoint: POST /api/meal-planner/generate
      final response = await _apiService.post('/meal-planner/generate', preferences);
      return MealPlan.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMealPlan(int id) async {
    try {
      // Backend endpoint: DELETE /api/meal-planner/{id}
      await _apiService.delete('/meal-planner/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<MealPlan?> getCurrentWeekPlan() async {
    try {
      // Backend endpoint: GET /api/meal-planner/latest
      final response = await _apiService.get('/meal-planner/latest');
      return MealPlan.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      // Retourner null si pas de plan (404)
      if (e.toString().contains('404') || e.toString().contains('non trouvée')) {
        return null;
      }
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
