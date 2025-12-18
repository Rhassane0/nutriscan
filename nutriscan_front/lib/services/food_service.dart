import 'api_service.dart';
import '../models/food.dart';

class FoodService {
  final ApiService _apiService;

  FoodService(this._apiService);

  Future<Food> searchByBarcode(String barcode) async {
    try {
      final response = await _apiService.get('/foods/barcode/$barcode');
      return Food.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Recherche combinée dans la base locale ET OpenFoodFacts
  Future<List<Food>> searchByName(String query) async {
    List<Food> allResults = [];

    // 1. Recherche dans la base de données locale
    try {
      final localResponse = await _apiService.get('/foods/search?query=$query');
      if (localResponse is List) {
        final localFoods = localResponse
            .map((json) => Food.fromLocalJson(json as Map<String, dynamic>))
            .toList();
        allResults.addAll(localFoods);
      }
    } catch (e) {
      // Ignorer les erreurs de recherche locale
    }

    // 2. Recherche dans OpenFoodFacts (organic)
    try {
      final organicResponse = await _apiService.get('/foods/search/organic?query=$query&limit=15');

      if (organicResponse is List) {
        final organicFoods = <Food>[];
        for (var json in organicResponse) {
          if (json == null) continue;

          final mapJson = json as Map<String, dynamic>;

          // Vérifier si le produit a un nom valide
          final product = mapJson['product'] as Map<String, dynamic>?;
          if (product == null) continue;

          final productName = product['productName'] ?? product['product_name'];
          if (productName == null || productName.toString().isEmpty) continue;

          try {
            final food = Food.fromOpenFoodFactsJson(mapJson);
            if (food.label.isNotEmpty && food.label != 'Aliment inconnu') {
              organicFoods.add(food);
            }
          } catch (_) {
            // Ignorer les erreurs de parsing
          }
        }

        allResults.addAll(organicFoods);
      }
    } catch (e) {
      // Ignorer les erreurs OpenFoodFacts
    }

    // Supprimer les doublons par nom
    final seen = <String>{};
    allResults = allResults.where((food) {
      final key = food.label.toLowerCase();
      if (seen.contains(key)) return false;
      seen.add(key);
      return true;
    }).toList();

    return allResults;
  }

  /// Recherche uniquement dans la base locale
  Future<List<Food>> searchLocalFoods(String query) async {
    try {
      final response = await _apiService.get('/foods/search?query=$query');
      if (response is List) {
        return response.map((json) => Food.fromLocalJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Recherche uniquement dans OpenFoodFacts
  Future<List<Food>> searchOrganicFoods(String query, {int limit = 20}) async {
    try {
      final response = await _apiService.get('/foods/search/organic?query=$query&limit=$limit');

      if (response is List) {
        final foods = <Food>[];
        for (var json in response) {
          if (json == null) continue;

          final mapJson = json as Map<String, dynamic>;
          final product = mapJson['product'] as Map<String, dynamic>?;

          if (product == null) continue;

          final productName = product['productName'] ?? product['product_name'];
          if (productName == null || productName.toString().isEmpty) continue;

          try {
            final food = Food.fromOpenFoodFactsJson(mapJson);
            if (food.label.isNotEmpty && food.label != 'Aliment inconnu') {
              foods.add(food);
            }
          } catch (_) {
            // Ignorer les erreurs de parsing
          }
        }

        return foods;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Food> getFoodById(int id) async {
    try {
      final response = await _apiService.get('/foods/$id');
      return Food.fromLocalJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Food>> getUserFavorites() async {
    try {
      final response = await _apiService.get('/foods/favorites');
      if (response is List) {
        return response.map((json) => Food.fromLocalJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToFavorites(int foodId) async {
    try {
      await _apiService.post('/foods/$foodId/favorite', {});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavorites(int foodId) async {
    try {
      await _apiService.delete('/foods/$foodId/favorite');
    } catch (e) {
      rethrow;
    }
  }
}
