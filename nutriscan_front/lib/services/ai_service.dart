import 'api_service.dart';
import '../models/recipe.dart';
import '../models/scan_result.dart';

class AiService {
  final ApiService _apiService;

  AiService(this._apiService);

  /// Scan un code-barres et récupère les infos du produit via IA
  Future<ScanBarcodeResponse> scanBarcode(String barcode) async {
    try {
      final response = await _apiService.get('/ai/scan-barcode?barcode=$barcode');
      return ScanBarcodeResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Analyse une photo de repas avec l'IA Vision
  Future<MealPhotoAnalysisResponse> analyzeMealPhoto({
    required String imageBase64,
    String? mealType,
  }) async {
    try {
      final data = {
        'imageUrl': 'data:image/jpeg;base64,$imageBase64',
        if (mealType != null) 'mealType': mealType,
      };
      final response = await _apiService.post('/ai/analyze/meal-photo', data);
      return MealPhotoAnalysisResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtient l'explication IA pour une journée
  Future<Map<String, dynamic>> getDailyExplanation(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _apiService.get('/ai/explain/daily?date=$dateStr');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeFood(int foodId) async {
    try {
      final response = await _apiService.post('/ai/analyze', {
        'foodId': foodId,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAlternatives(int foodId) async {
    try {
      final response = await _apiService.get('/ai/alternatives/$foodId');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Recipe>> searchRecipes({
    required String query,
    String? dietType,
    List<String>? healthLabels,
    int? maxCalories,
  }) async {
    try {
      var url = '/meal-planner/recipes/search?query=${Uri.encodeComponent(query)}';

      if (dietType != null && dietType.isNotEmpty) {
        url += '&diet=${Uri.encodeComponent(dietType)}';
      }

      if (healthLabels != null && healthLabels.isNotEmpty) {
        for (var label in healthLabels) {
          url += '&health=${Uri.encodeComponent(label)}';
        }
      }

      if (maxCalories != null) {
        url += '&calories=$maxCalories';
      }

      print('🔍 Searching recipes with URL: $url');
      final response = await _apiService.get(url);
      print('📦 Recipe search response type: ${response.runtimeType}');

      if (response is List) {
        print('📦 Found ${response.length} recipes');
        final recipes = <Recipe>[];
        for (var json in response) {
          print('📄 Recipe JSON: $json');
          try {
            final recipe = Recipe.fromJson(json as Map<String, dynamic>);
            print('✅ Parsed recipe: ${recipe.name}, calories: ${recipe.calories}, proteins: ${recipe.proteins}');
            recipes.add(recipe);
          } catch (e) {
            print('⚠️ Error parsing recipe: $e');
          }
        }
        return recipes;
      }

      print('⚠️ Response is not a list');
      return [];
    } catch (e) {
      print('❌ searchRecipes error: $e');
      rethrow;
    }
  }
}

/// Réponse de l'analyse d'une photo de repas
class MealPhotoAnalysisResponse {
  final List<DetectedFood> detectedFoods;
  final String analysisText;
  final double confidenceScore;

  MealPhotoAnalysisResponse({
    required this.detectedFoods,
    required this.analysisText,
    required this.confidenceScore,
  });

  factory MealPhotoAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return MealPhotoAnalysisResponse(
      detectedFoods: (json['detectedFoods'] as List?)
          ?.map((e) => DetectedFood.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      analysisText: json['analysisText'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Calcul du total nutritionnel estimé
  NutritionInfo get totalNutrition {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var food in detectedFoods) {
      // Estimation basique par portion de 100g
      totalCalories += food.estimatedQuantityGrams ?? 0;
    }

    return NutritionInfo(
      calories: totalCalories,
      proteins: totalProteins,
      carbs: totalCarbs,
      fats: totalFats,
    );
  }
}

class DetectedFood {
  final String name;
  final double confidence;
  final double? estimatedQuantityGrams;
  final int? suggestedFoodId;
  final String matchStatus;
  final List<FoodCandidate> candidates;

  DetectedFood({
    required this.name,
    required this.confidence,
    this.estimatedQuantityGrams,
    this.suggestedFoodId,
    required this.matchStatus,
    required this.candidates,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) {
    return DetectedFood(
      name: json['name'] as String? ?? 'Aliment inconnu',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      estimatedQuantityGrams: (json['estimatedQuantityGrams'] as num?)?.toDouble(),
      suggestedFoodId: json['suggestedFoodId'] as int?,
      matchStatus: json['matchStatus'] as String? ?? 'NOT_FOUND',
      candidates: (json['candidates'] as List?)
          ?.map((e) => FoodCandidate.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class FoodCandidate {
  final int foodId;
  final String name;
  final double matchScore;

  FoodCandidate({
    required this.foodId,
    required this.name,
    required this.matchScore,
  });

  factory FoodCandidate.fromJson(Map<String, dynamic> json) {
    return FoodCandidate(
      foodId: json['foodId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0,
    );
  }
}
