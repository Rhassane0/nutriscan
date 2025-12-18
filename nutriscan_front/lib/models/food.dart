class Food {
  final String foodId;
  final String label;
  final String? category;
  final String? image;
  final String? brand;
  final String? source;
  final Nutrients nutrients;

  Food({
    required this.foodId,
    required this.label,
    this.category,
    this.image,
    this.brand,
    this.source,
    required this.nutrients,
  });

  /// Parser générique qui détecte le format
  factory Food.fromJson(Map<String, dynamic> json) {
    // Si c'est un format OpenFoodFacts (contient 'product')
    if (json['product'] != null) {
      return Food.fromOpenFoodFactsJson(json);
    }
    // Sinon c'est le format local
    return Food.fromLocalJson(json);
  }

  /// Parser pour le format de la base locale (FoodResponse)
  factory Food.fromLocalJson(Map<String, dynamic> json) {
    return Food(
      foodId: (json['id'] ?? json['foodId'] ?? '').toString(),
      label: json['name']?.toString() ?? json['label']?.toString() ?? 'Aliment inconnu',
      category: json['category']?.toString(),
      image: json['imageUrl']?.toString() ?? json['image']?.toString(),
      source: json['source']?.toString() ?? 'local',
      nutrients: Nutrients(
        calories: _parseDouble(json['caloriesKcal'] ?? json['calories']),
        proteins: _parseDouble(json['proteinGr'] ?? json['protein'] ?? json['proteins']),
        carbs: _parseDouble(json['carbsGr'] ?? json['carbs']),
        fats: _parseDouble(json['fatGr'] ?? json['fat'] ?? json['fats']),
        fiber: _parseDouble(json['fiberGr'] ?? json['fiber']),
        sugars: _parseDouble(json['sugarGr'] ?? json['sugars']),
      ),
    );
  }

  /// Parser pour le format OpenFoodFacts (OffProductResponse)
  factory Food.fromOpenFoodFactsJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    if (product == null) {
      return Food(
        foodId: json['code']?.toString() ?? 'unknown',
        label: 'Aliment inconnu',
        nutrients: Nutrients(),
      );
    }

    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};


    // Support both camelCase (from Java backend) and snake_case (direct from OFF API)
    final productName = product['productName']?.toString() ??
                        product['product_name']?.toString() ??
                        'Aliment inconnu';

    final imageUrl = product['imageUrl']?.toString() ??
                     product['image_url']?.toString();

    final brands = product['brands']?.toString();
    final categories = product['categories']?.toString();

    // Extraire les calories - essayer toutes les clés possibles
    double? calories = _parseDouble(nutriments['energy-kcal_100g']) ??
                       _parseDouble(nutriments['energy-kcal']) ??
                       _parseDouble(nutriments['energy_kcal_100g']) ??
                       _parseDouble(nutriments['energy_kcal']) ??
                       _parseDouble(nutriments['energy_100g']) ??
                       _parseDouble(nutriments['energy']);

    // Si energy est en kJ, convertir en kcal
    if (calories == null && nutriments['energy_100g'] != null) {
      final energyKj = _parseDouble(nutriments['energy_100g']);
      if (energyKj != null && energyKj > 500) { // Probablement en kJ
        calories = energyKj / 4.184;
      }
    }

    final proteins = _parseDouble(nutriments['proteins_100g']) ??
                     _parseDouble(nutriments['proteins']) ??
                     _parseDouble(nutriments['protein_100g']) ??
                     _parseDouble(nutriments['protein']);

    final carbs = _parseDouble(nutriments['carbohydrates_100g']) ??
                  _parseDouble(nutriments['carbohydrates']) ??
                  _parseDouble(nutriments['carbs_100g']) ??
                  _parseDouble(nutriments['carbs']);

    final fats = _parseDouble(nutriments['fat_100g']) ??
                 _parseDouble(nutriments['fat']) ??
                 _parseDouble(nutriments['fats_100g']) ??
                 _parseDouble(nutriments['fats']);


    return Food(
      foodId: json['code']?.toString() ?? 'unknown',
      label: productName,
      brand: brands,
      image: imageUrl,
      category: categories,
      source: 'openfoodfacts',
      nutrients: Nutrients(
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        fiber: _parseDouble(nutriments['fiber_100g']) ?? _parseDouble(nutriments['fiber']),
        sugars: _parseDouble(nutriments['sugars_100g']) ?? _parseDouble(nutriments['sugars']),
      ),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'label': label,
      'category': category,
      'image': image,
      'brand': brand,
      'source': source,
      'nutrients': nutrients.toJson(),
    };
  }
}

class Nutrients {
  final double? calories;
  final double? proteins;
  final double? fats;
  final double? carbs;
  final double? fiber;
  final double? sugars;

  Nutrients({
    this.calories,
    this.proteins,
    this.fats,
    this.carbs,
    this.fiber,
    this.sugars,
  });

  factory Nutrients.fromJson(Map<String, dynamic> json) {
    return Nutrients(
      calories: _parseDouble(json['ENERC_KCAL'] ?? json['calories'] ?? json['caloriesKcal']),
      proteins: _parseDouble(json['PROCNT'] ?? json['proteins'] ?? json['proteinGr']),
      fats: _parseDouble(json['FAT'] ?? json['fats'] ?? json['fatGr']),
      carbs: _parseDouble(json['CHOCDF'] ?? json['carbs'] ?? json['carbsGr']),
      fiber: _parseDouble(json['FIBTG'] ?? json['fiber'] ?? json['fiberGr']),
      sugars: _parseDouble(json['SUGAR'] ?? json['sugars'] ?? json['sugarGr']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
      'fiber': fiber,
      'sugars': sugars,
    };
  }
}

class FoodSearchResponse {
  final List<Food> foods;

  FoodSearchResponse({required this.foods});

  factory FoodSearchResponse.fromJson(Map<String, dynamic> json) {
    return FoodSearchResponse(
      foods: (json['foods'] as List)
          .map((item) => Food.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
