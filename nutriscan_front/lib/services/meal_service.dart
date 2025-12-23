import 'api_service.dart';
import '../models/meal.dart';
import 'package:flutter/foundation.dart';

class MealService {
  final ApiService _apiService;

  MealService(this._apiService);

  void _log(String message) {
    if (kDebugMode) {
      print('🍴 [MealService] $message');
    }
  }

  void _logError(String message) {
    if (kDebugMode) {
      print('❌ [MealService ERROR] $message');
    }
  }

  Future<List<Meal>> getMeals({DateTime? date}) async {
    try {
      final dateParam = date != null ? '?date=${date.toIso8601String().split('T')[0]}' : '';
      _log('Fetching meals$dateParam...');
      final response = await _apiService.get('/meals$dateParam');

      // Le backend retourne directement une liste
      if (response is List) {
        _log('Got ${response.length} meals');
        return response.map((json) => Meal.fromJson(json as Map<String, dynamic>)).toList();
      }

      // Fallback si c'est un objet avec 'items'
      if (response is Map && response['items'] != null) {
        return (response['items'] as List).map((json) => Meal.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      _logError('getMeals: $e');
      rethrow;
    }
  }

  Future<Meal> getMealById(int id) async {
    try {
      _log('Fetching meal #$id...');
      final response = await _apiService.get('/meals/$id');
      return Meal.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logError('getMealById($id): $e');
      rethrow;
    }
  }

  Future<Meal> createMeal(Map<String, dynamic> mealData) async {
    try {
      _log('Creating meal: ${mealData['mealType']} with ${(mealData['items'] as List?)?.length ?? 0} items');
      _log('Meal data: $mealData');
      final response = await _apiService.post('/meals', mealData);
      _log('Meal created successfully with id: ${response['id']}');
      return Meal.fromJson(response);
    } catch (e) {
      _logError('createMeal: $e');
      _logError('Meal data was: $mealData');
      rethrow;
    }
  }

  Future<Meal> updateMeal(int id, Map<String, dynamic> mealData) async {
    try {
      _log('Updating meal #$id...');
      final response = await _apiService.put('/meals/$id', mealData);
      return Meal.fromJson(response);
    } catch (e) {
      _logError('updateMeal($id): $e');
      rethrow;
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      _log('Deleting meal #$id...');
      await _apiService.delete('/meals/$id');
      _log('Meal #$id deleted');
    } catch (e) {
      _logError('deleteMeal($id): $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDailyStats({DateTime? date}) async {
    try {
      final dateParam = date != null ? '?date=${date.toIso8601String().split('T')[0]}' : '';
      _log('Fetching daily stats$dateParam...');
      final response = await _apiService.get('/meals/stats/daily$dateParam');
      return response as Map<String, dynamic>;
    } catch (e) {
      _logError('getDailyStats: $e');
      rethrow;
    }
  }

  /// Récupère le résumé nutritionnel complet avec tous les micronutriments
  Future<Map<String, dynamic>> getDailySummary({DateTime? date}) async {
    try {
      final dateParam = date != null ? '?date=${date.toIso8601String().split('T')[0]}' : '';
      _log('Fetching daily summary$dateParam...');
      final response = await _apiService.get('/meals/summary$dateParam');
      _log('Daily summary: $response');
      return response as Map<String, dynamic>;
    } catch (e) {
      _logError('getDailySummary: $e');
      // Retourner un objet vide en cas d'erreur
      return {};
    }
  }
}

