import 'api_service.dart';
import '../models/recipe.dart';
import '../models/scan_result.dart';
import 'package:flutter/foundation.dart';

class AiService {
  final ApiService _apiService;

  AiService(this._apiService);

  void _log(String message) {
    if (kDebugMode) {
      print('🤖 [AI Service] $message');
    }
  }

  // ======================== RECOMMANDATIONS ========================

  /// Obtenir des recommandations alimentaires personnalisées
  Future<List<FoodRecommendation>> getRecommendations({String mealType = 'LUNCH'}) async {
    try {
      _log('Getting recommendations for $mealType');
      final response = await _apiService.get('/ai/recommendations?mealType=$mealType');
      if (response is List) {
        return response.map((e) => FoodRecommendation.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      _log('Error getting recommendations: $e');
      return _getDefaultRecommendations(mealType);
    }
  }

  /// Obtenir des conseils nutritionnels basés sur l'apport du jour
  Future<NutritionAdvice> getNutritionAdvice(Map<String, double> dailyIntake) async {
    try {
      _log('Getting nutrition advice');
      final response = await _apiService.post('/ai/advice', dailyIntake);
      return NutritionAdvice.fromJson(response);
    } catch (e) {
      _log('Error getting advice: $e');
      return NutritionAdvice.defaultAdvice();
    }
  }

  // ======================== ANALYSE ========================

  /// Analyser des ingrédients et obtenir les infos nutritionnelles
  Future<NutritionAnalysisResult> analyzeIngredients(List<String> ingredients) async {
    try {
      _log('Analyzing ${ingredients.length} ingredients');
      final response = await _apiService.post('/ai/analyze/ingredients', {'ingredients': ingredients});
      return NutritionAnalysisResult.fromJson(response);
    } catch (e) {
      _log('Error analyzing ingredients: $e');
      return NutritionAnalysisResult.empty();
    }
  }

  /// Analyser une image de repas avec l'IA
  Future<ImageAnalysisResult> analyzeImage(String imageBase64) async {
    try {
      _log('Analyzing meal image');
      final response = await _apiService.post('/ai/analyze/image', {'image': imageBase64});
      return ImageAnalysisResult.fromJson(response);
    } catch (e) {
      _log('Error analyzing image: $e');
      return ImageAnalysisResult.empty();
    }
  }

  // ======================== RECETTES ========================

  /// Générer des recettes personnalisées avec l'IA
  Future<List<Recipe>> generateRecipes({
    String mealType = 'LUNCH',
    int calories = 500,
    List<String>? preferences,
    List<String>? exclude,
  }) async {
    try {
      _log('Generating recipes for $mealType (~$calories cal)');
      var url = '/ai/recipes?mealType=$mealType&calories=$calories';
      if (preferences != null && preferences.isNotEmpty) {
        url += '&preferences=${preferences.join(",")}';
      }
      if (exclude != null && exclude.isNotEmpty) {
        url += '&exclude=${exclude.join(",")}';
      }
      final response = await _apiService.get(url);
      if (response is List) {
        return response.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      _log('Error generating recipes: $e');
      return [];
    }
  }

  // ======================== CHATBOT ========================

  /// Chat avec l'assistant nutritionnel
  Future<String> chatWithAssistant(String message, {List<String>? history}) async {
    try {
      _log('Chat message: ${message.length > 30 ? message.substring(0, 30) + "..." : message}');
      final response = await _apiService.post('/ai/chat', {
        'message': message,
        if (history != null) 'history': history,
      });
      return response['response'] as String? ?? 'Je n\'ai pas pu répondre.';
    } catch (e) {
      _log('Error in chat: $e');
      return 'Désolé, une erreur s\'est produite. Réessayez plus tard.';
    }
  }

  // ======================== RÉSUMÉ ========================

  /// Obtenir un résumé AI de la journée
  Future<AISummary> getAISummary({String? date}) async {
    try {
      _log('Getting AI summary');
      var url = '/ai/summary';
      if (date != null) url += '?date=$date';
      final response = await _apiService.get(url);
      return AISummary.fromJson(response);
    } catch (e) {
      _log('Error getting summary: $e');
      return AISummary.empty();
    }
  }

  // ======================== MÉTHODES EXISTANTES ========================

  /// Scan un code-barres et récupère les infos du produit via IA
  Future<ScanBarcodeResponse> scanBarcode(String barcode) async {
    try {
      final response = await _apiService.get('/ai/scan-barcode?barcode=$barcode');
      return ScanBarcodeResponse.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Analyse une photo de repas avec l'IA Vision (ancienne méthode)
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

      final response = await _apiService.get(url);

      if (response is List) {
        final recipes = <Recipe>[];
        for (var json in response) {
          try {
            final recipe = Recipe.fromJson(json as Map<String, dynamic>);
            recipes.add(recipe);
          } catch (e) {
            // Ignorer les erreurs de parsing silencieusement
          }
        }
        return recipes;
      }

      return [];
    } catch (e) {
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

  /// Calcul du total nutritionnel estimé à partir des aliments détectés
  NutritionInfo get totalNutrition {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var food in detectedFoods) {
      totalCalories += food.estimatedCalories ?? 0;
      totalProteins += food.estimatedProteins ?? 0;
      totalCarbs += food.estimatedCarbs ?? 0;
      totalFats += food.estimatedFats ?? 0;
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
  final double? estimatedCalories;
  final double? estimatedProteins;
  final double? estimatedCarbs;
  final double? estimatedFats;
  final int? suggestedFoodId;
  final String matchStatus;
  final List<FoodCandidate> candidates;

  DetectedFood({
    required this.name,
    required this.confidence,
    this.estimatedQuantityGrams,
    this.estimatedCalories,
    this.estimatedProteins,
    this.estimatedCarbs,
    this.estimatedFats,
    this.suggestedFoodId,
    required this.matchStatus,
    required this.candidates,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) {
    return DetectedFood(
      name: json['name'] as String? ?? 'Aliment inconnu',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      estimatedQuantityGrams: (json['estimatedQuantityGrams'] as num?)?.toDouble(),
      estimatedCalories: (json['estimatedCalories'] as num?)?.toDouble(),
      estimatedProteins: (json['estimatedProteins'] as num?)?.toDouble(),
      estimatedCarbs: (json['estimatedCarbs'] as num?)?.toDouble(),
      estimatedFats: (json['estimatedFats'] as num?)?.toDouble(),
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

// ======================== NOUVEAUX DTOS AI ========================

/// Recommandation alimentaire générée par l'IA
class FoodRecommendation {
  final String name;
  final String reason;
  final double calories;
  final List<String> benefits;

  FoodRecommendation({
    required this.name,
    required this.reason,
    required this.calories,
    required this.benefits,
  });

  factory FoodRecommendation.fromJson(Map<String, dynamic> json) {
    return FoodRecommendation(
      name: json['name'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      benefits: (json['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

List<FoodRecommendation> _getDefaultRecommendations(String mealType) {
  switch (mealType.toUpperCase()) {
    case 'BREAKFAST':
      return [
        FoodRecommendation(name: 'Flocons d\'avoine', reason: 'Riche en fibres', calories: 150, benefits: ['Énergie durable']),
        FoodRecommendation(name: 'Œufs', reason: 'Protéines complètes', calories: 140, benefits: ['Satiété']),
        FoodRecommendation(name: 'Yaourt grec', reason: 'Probiotiques', calories: 100, benefits: ['Digestion']),
      ];
    case 'LUNCH':
      return [
        FoodRecommendation(name: 'Quinoa', reason: 'Protéine végétale', calories: 220, benefits: ['Acides aminés']),
        FoodRecommendation(name: 'Poulet grillé', reason: 'Protéines maigres', calories: 165, benefits: ['Muscles']),
      ];
    default:
      return [
        FoodRecommendation(name: 'Fruits frais', reason: 'Vitamines', calories: 80, benefits: ['Antioxydants']),
        FoodRecommendation(name: 'Noix', reason: 'Bons lipides', calories: 180, benefits: ['Oméga-3']),
      ];
  }
}

/// Conseils nutritionnels de l'IA
class NutritionAdvice {
  final int score;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> tips;

  NutritionAdvice({
    required this.score,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.tips,
  });

  factory NutritionAdvice.fromJson(Map<String, dynamic> json) {
    return NutritionAdvice(
      score: (json['score'] as num?)?.toInt() ?? 70,
      summary: json['summary'] as String? ?? '',
      strengths: (json['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [],
      improvements: (json['improvements'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tips: (json['tips'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  factory NutritionAdvice.defaultAdvice() {
    return NutritionAdvice(
      score: 70,
      summary: 'Continuez vos efforts pour une alimentation équilibrée!',
      strengths: ['Vous suivez vos repas régulièrement'],
      improvements: ['Augmentez votre consommation de légumes'],
      tips: ['Buvez au moins 8 verres d\'eau par jour'],
    );
  }
}

/// Résultat d'analyse nutritionnelle détaillée
class NutritionAnalysisResult {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double saturatedFat;
  final double cholesterol;
  final double potassium;
  final double vitaminA;
  final double vitaminC;
  final double vitaminD;
  final double calcium;
  final double iron;
  final int healthScore;
  final List<String> warnings;
  final List<String> benefits;
  final List<String> tips;

  NutritionAnalysisResult({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.saturatedFat = 0,
    this.cholesterol = 0,
    this.potassium = 0,
    this.vitaminA = 0,
    this.vitaminC = 0,
    this.vitaminD = 0,
    this.calcium = 0,
    this.iron = 0,
    this.healthScore = 70,
    this.warnings = const [],
    this.benefits = const [],
    this.tips = const [],
  });

  factory NutritionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysisResult(
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      saturatedFat: (json['saturatedFat'] as num?)?.toDouble() ?? 0,
      cholesterol: (json['cholesterol'] as num?)?.toDouble() ?? 0,
      potassium: (json['potassium'] as num?)?.toDouble() ?? 0,
      vitaminA: (json['vitaminA'] as num?)?.toDouble() ?? 0,
      vitaminC: (json['vitaminC'] as num?)?.toDouble() ?? 0,
      vitaminD: (json['vitaminD'] as num?)?.toDouble() ?? 0,
      calcium: (json['calcium'] as num?)?.toDouble() ?? 0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 70,
      warnings: (json['warnings'] as List?)?.map((e) => e.toString()).toList() ?? [],
      benefits: (json['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [],
      tips: (json['tips'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  factory NutritionAnalysisResult.empty() {
    return NutritionAnalysisResult(
      calories: 0, protein: 0, carbs: 0, fat: 0,
    );
  }
}

/// Résultat d'analyse d'image
class ImageAnalysisResult {
  final List<String> detectedFoods;
  final double estimatedCalories;
  final double protein;
  final double carbs;
  final double fat;
  final int healthScore;
  final List<String> tips;
  final double confidence;

  ImageAnalysisResult({
    required this.detectedFoods,
    required this.estimatedCalories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.healthScore = 50,
    this.tips = const [],
    this.confidence = 0.5,
  });

  factory ImageAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisResult(
      detectedFoods: (json['detectedFoods'] as List?)?.map((e) => e.toString()).toList() ?? [],
      estimatedCalories: (json['estimatedCalories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 50,
      tips: (json['tips'] as List?)?.map((e) => e.toString()).toList() ?? [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
    );
  }

  factory ImageAnalysisResult.empty() {
    return ImageAnalysisResult(
      detectedFoods: ['Non analysé'],
      estimatedCalories: 0,
      confidence: 0,
    );
  }
}

/// Résumé AI de la journée
class AISummary {
  final NutritionAdvice advice;
  final List<FoodRecommendation> recommendations;
  final String generatedAt;

  AISummary({
    required this.advice,
    required this.recommendations,
    required this.generatedAt,
  });

  factory AISummary.fromJson(Map<String, dynamic> json) {
    return AISummary(
      advice: json['advice'] != null
          ? NutritionAdvice.fromJson(json['advice'] as Map<String, dynamic>)
          : NutritionAdvice.defaultAdvice(),
      recommendations: (json['recommendations'] as List?)
          ?.map((e) => FoodRecommendation.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      generatedAt: json['generatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  factory AISummary.empty() {
    return AISummary(
      advice: NutritionAdvice.defaultAdvice(),
      recommendations: [],
      generatedAt: DateTime.now().toIso8601String(),
    );
  }
}

