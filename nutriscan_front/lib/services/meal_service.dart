import 'api_service.dart';
import '../models/meal.dart';

class MealService {
  final ApiService _apiService;

  MealService(this._apiService);

  Future<List<Meal>> getMeals({DateTime? date}) async {
    try {
      final dateParam = date != null ? '?date=${date.toIso8601String().split('T')[0]}' : '';
      final response = await _apiService.get('/meals$dateParam');

      // Le backend retourne directement une liste
      if (response is List) {
        return response.map((json) => Meal.fromJson(json as Map<String, dynamic>)).toList();
      }

      // Fallback si c'est un objet avec 'items'
      if (response is Map && response['items'] != null) {
        return (response['items'] as List).map((json) => Meal.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Meal> getMealById(int id) async {
    try {
      final response = await _apiService.get('/meals/$id');
      return Meal.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Meal> createMeal(Map<String, dynamic> mealData) async {
    try {
      final response = await _apiService.post('/meals', mealData);
      return Meal.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Meal> updateMeal(int id, Map<String, dynamic> mealData) async {
    try {
      final response = await _apiService.put('/meals/$id', mealData);
      return Meal.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _apiService.delete('/meals/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDailyStats({DateTime? date}) async {
    try {
      final dateParam = date != null ? '?date=${date.toIso8601String().split('T')[0]}' : '';
      final response = await _apiService.get('/meals/stats/daily$dateParam');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}

