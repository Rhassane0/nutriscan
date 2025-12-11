import 'api_service.dart';
import '../models/grocery_list.dart';

class GroceryService {
  final ApiService _apiService;

  GroceryService(this._apiService);

  Future<List<GroceryList>> getGroceryLists() async {
    try {
      final response = await _apiService.get('/grocery-list');

      // La réponse devrait être une liste de GroceryList
      List<dynamic> listData = [];

      if (response is List) {
        listData = response as List<dynamic>;
      } else if (response is Map<String, dynamic>) {
        // Chercher la liste dans différentes propriétés possibles
        if (response['items'] != null && response['items'] is List) {
          listData = response['items'] as List<dynamic>;
        } else if (response['data'] != null && response['data'] is List) {
          listData = response['data'] as List<dynamic>;
        }
      }

      return listData.map((json) => GroceryList.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<GroceryList> getGroceryListById(int id) async {
    try {
      final response = await _apiService.get('/grocery-list/$id');
      return GroceryList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<GroceryList> getLatestGroceryList() async {
    try {
      final response = await _apiService.get('/grocery-list/latest');
      return GroceryList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<GroceryList> createGroceryList(Map<String, dynamic> listData) async {
    try {
      final response = await _apiService.post('/grocery-list', listData);
      return GroceryList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<GroceryList> updateGroceryList(int id, Map<String, dynamic> listData) async {
    try {
      final response = await _apiService.put('/grocery-list/$id', listData);
      return GroceryList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroceryList(int id) async {
    try {
      await _apiService.delete('/grocery-list/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<GroceryList> generateFromMealPlan(int mealPlanId) async {
    try {
      final response = await _apiService.post('/grocery-list/from-meal-plan/$mealPlanId', {});
      return GroceryList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<GroceryList> updateItemStatus(int listId, int itemId, bool purchased) async {
    try {
      final response = await _apiService.patch(
        '/grocery-list/$listId/items/$itemId?purchased=$purchased',
        {},
      );
      return GroceryList.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}

