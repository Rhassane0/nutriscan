class ScanBarcodeResponse {
  final String productName;
  final String? brand;
  final String barcode;
  final String? nutriScore;
  final String? ecoScore;
  final int? novaScore;
  final NutritionInfo nutritionInfo;
  final String? aiAnalysis;
  final String? recommendation;
  final bool isOrganic;
  final List<String> allergens;
  final String? ingredients;
  final String? imageUrl;
  final String? servingSize;
  final String? quantity;
  final List<String> additives;
  final List<String> labels;
  final String? origin;
  final String? packaging;
  final Map<String, double> dailyValuePercentages;

  ScanBarcodeResponse({
    required this.productName,
    this.brand,
    required this.barcode,
    this.nutriScore,
    this.ecoScore,
    this.novaScore,
    required this.nutritionInfo,
    this.aiAnalysis,
    this.recommendation,
    required this.isOrganic,
    required this.allergens,
    this.ingredients,
    this.imageUrl,
    this.servingSize,
    this.quantity,
    this.additives = const [],
    this.labels = const [],
    this.origin,
    this.packaging,
    this.dailyValuePercentages = const {},
  });

  factory ScanBarcodeResponse.fromJson(Map<String, dynamic> json) {
    // Le backend peut retourner deux formats:
    // 1. Format direct avec product_name, brand, etc.
    // 2. Format OpenFoodFacts avec { code, product: {...} }

    if (json.containsKey('product') && json['product'] != null) {
      // Format OpenFoodFacts
      return ScanBarcodeResponse._fromOpenFoodFactsJson(json);
    } else if (json.containsKey('productName')) {
      // Format direct (si le backend est modifié pour ce format)
      return ScanBarcodeResponse._fromDirectJson(json);
    } else {
      // Fallback: essayer de parser comme OpenFoodFacts
      return ScanBarcodeResponse._fromOpenFoodFactsJson(json);
    }
  }

  /// Parser pour le format OpenFoodFacts
  factory ScanBarcodeResponse._fromOpenFoodFactsJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    // Parser les nutriments avec les différentes clés possibles
    double? parseNutriment(List<String> keys) {
      for (var key in keys) {
        if (nutriments.containsKey(key) && nutriments[key] != null) {
          final value = nutriments[key];
          if (value is num) return value.toDouble();
          if (value is String) return double.tryParse(value);
        }
      }
      return null;
    }

    // Extraire les allergènes
    List<String> allergens = [];
    if (product['allergens_tags'] != null) {
      allergens = (product['allergens_tags'] as List)
          .map((e) => e.toString().replaceFirst('en:', '').replaceFirst('fr:', ''))
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (product['allergens'] != null && product['allergens'].toString().isNotEmpty) {
      allergens = product['allergens'].toString().split(',').map((e) => e.trim()).toList();
    }

    // Extraire les additifs
    List<String> additives = [];
    if (product['additives_tags'] != null) {
      additives = (product['additives_tags'] as List)
          .map((e) => e.toString().replaceFirst('en:', '').toUpperCase())
          .toList();
    }

    // Extraire les labels
    List<String> labels = [];
    final labelsData = product['labels_tags'] as List? ?? [];
    labels = labelsData.map((e) => e.toString()
        .replaceFirst('en:', '')
        .replaceFirst('fr:', '')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' '))
        .toList();

    // Vérifier si bio/organic
    bool isOrganic = labelsData.any((label) =>
      label.toString().contains('bio') ||
      label.toString().contains('organic'));

    // Extraire le score NOVA
    int? novaScore;
    if (product['nova_group'] != null) {
      novaScore = int.tryParse(product['nova_group'].toString());
    } else if (nutriments['nova-group'] != null) {
      novaScore = int.tryParse(nutriments['nova-group'].toString());
    }

    // Calculer les pourcentages d'apports journaliers recommandés
    Map<String, double> dailyValues = {};
    final calories = parseNutriment(['energy-kcal_100g', 'energy-kcal', 'energy_kcal_100g']);
    final proteins = parseNutriment(['proteins_100g', 'proteins', 'protein_100g']);
    final carbs = parseNutriment(['carbohydrates_100g', 'carbohydrates', 'carbs_100g']);
    final fats = parseNutriment(['fat_100g', 'fat', 'fats_100g']);
    final sugars = parseNutriment(['sugars_100g', 'sugars', 'sugar_100g']);
    final fiber = parseNutriment(['fiber_100g', 'fiber', 'fibres_100g']);
    final sodium = parseNutriment(['sodium_100g', 'sodium']);
    final saturatedFats = parseNutriment(['saturated-fat_100g', 'saturated_fat_100g', 'saturated-fat']);
    final salt = parseNutriment(['salt_100g', 'salt']);

    // Apports journaliers recommandés (pour un adulte de 2000 kcal)
    if (calories != null) dailyValues['calories'] = (calories / 2000 * 100);
    if (proteins != null) dailyValues['proteins'] = (proteins / 50 * 100);
    if (carbs != null) dailyValues['carbs'] = (carbs / 260 * 100);
    if (fats != null) dailyValues['fats'] = (fats / 70 * 100);
    if (sugars != null) dailyValues['sugars'] = (sugars / 90 * 100);
    if (fiber != null) dailyValues['fiber'] = (fiber / 25 * 100);
    if (saturatedFats != null) dailyValues['saturatedFats'] = (saturatedFats / 20 * 100);
    if (salt != null) dailyValues['salt'] = (salt / 6 * 100);

    return ScanBarcodeResponse(
      productName: product['product_name']?.toString() ??
                   product['product_name_fr']?.toString() ??
                   product['product_name_en']?.toString() ??
                   'Produit inconnu',
      brand: product['brands']?.toString(),
      barcode: json['code']?.toString() ?? '',
      nutriScore: product['nutrition_grades']?.toString()?.toUpperCase() ??
                  product['nutriscore_grade']?.toString()?.toUpperCase(),
      ecoScore: product['ecoscore_grade']?.toString()?.toUpperCase(),
      novaScore: novaScore,
      nutritionInfo: NutritionInfo(
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        sugars: sugars,
        fiber: fiber,
        sodium: sodium != null ? sodium * 1000 : (salt != null ? salt * 400 : null), // Convertir en mg
        saturatedFats: saturatedFats,
        salt: salt,
        polyunsaturatedFat: parseNutriment(['polyunsaturated-fat_100g']),
        monounsaturatedFat: parseNutriment(['monounsaturated-fat_100g']),
        cholesterol: parseNutriment(['cholesterol_100g']),
        potassium: parseNutriment(['potassium_100g']),
        calcium: parseNutriment(['calcium_100g']),
        iron: parseNutriment(['iron_100g']),
        vitaminA: parseNutriment(['vitamin-a_100g']),
        vitaminC: parseNutriment(['vitamin-c_100g']),
        vitaminD: parseNutriment(['vitamin-d_100g']),
        vitaminE: parseNutriment(['vitamin-e_100g']),
      ),
      aiAnalysis: null,
      recommendation: null,
      isOrganic: isOrganic,
      allergens: allergens,
      additives: additives,
      labels: labels,
      ingredients: product['ingredients_text']?.toString() ??
                   product['ingredients_text_fr']?.toString() ??
                   product['ingredients_text_en']?.toString(),
      imageUrl: product['image_url']?.toString() ??
                product['image_front_url']?.toString() ??
                product['image_front_small_url']?.toString(),
      servingSize: product['serving_size']?.toString(),
      quantity: product['quantity']?.toString(),
      origin: product['origins']?.toString() ?? product['origin']?.toString(),
      packaging: product['packaging']?.toString(),
      dailyValuePercentages: dailyValues,
    );
  }

  /// Parser pour le format direct (si backend modifié)
  factory ScanBarcodeResponse._fromDirectJson(Map<String, dynamic> json) {
    return ScanBarcodeResponse(
      productName: json['productName'] as String? ?? 'Produit inconnu',
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String? ?? '',
      nutriScore: json['nutriScore'] as String?,
      ecoScore: json['ecoScore'] as String?,
      novaScore: json['novaScore'] as int?,
      nutritionInfo: json['nutritionInfo'] != null
          ? NutritionInfo.fromJson(json['nutritionInfo'] as Map<String, dynamic>)
          : NutritionInfo(),
      aiAnalysis: json['aiAnalysis'] as String?,
      recommendation: json['recommendation'] as String?,
      isOrganic: json['isOrganic'] as bool? ?? false,
      allergens: (json['allergens'] as List?)?.map((e) => e.toString()).toList() ?? [],
      additives: (json['additives'] as List?)?.map((e) => e.toString()).toList() ?? [],
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      ingredients: json['ingredients'] as String?,
      imageUrl: json['imageUrl'] as String?,
      servingSize: json['servingSize'] as String?,
      quantity: json['quantity'] as String?,
      origin: json['origin'] as String?,
      packaging: json['packaging'] as String?,
      dailyValuePercentages: (json['dailyValuePercentages'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
    );
  }
}

class NutritionInfo {
  final double? calories;
  final double? proteins;
  final double? carbs;
  final double? fats;
  final double? sugars;
  final double? fiber;
  final double? sodium;
  final double? saturatedFats;
  final double? salt;
  final double? polyunsaturatedFat;
  final double? monounsaturatedFat;
  final double? cholesterol;
  final double? potassium;
  final double? calcium;
  final double? iron;
  final double? vitaminA;
  final double? vitaminC;
  final double? vitaminD;
  final double? vitaminE;

  NutritionInfo({
    this.calories,
    this.proteins,
    this.carbs,
    this.fats,
    this.sugars,
    this.fiber,
    this.sodium,
    this.saturatedFats,
    this.salt,
    this.polyunsaturatedFat,
    this.monounsaturatedFat,
    this.cholesterol,
    this.potassium,
    this.calcium,
    this.iron,
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num?)?.toDouble(),
      proteins: (json['proteins'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fats: (json['fats'] as num?)?.toDouble(),
      sugars: (json['sugars'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      saturatedFats: (json['saturatedFats'] as num?)?.toDouble(),
      salt: (json['salt'] as num?)?.toDouble(),
      polyunsaturatedFat: (json['polyunsaturatedFat'] as num?)?.toDouble(),
      monounsaturatedFat: (json['monounsaturatedFat'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      iron: (json['iron'] as num?)?.toDouble(),
      vitaminA: (json['vitaminA'] as num?)?.toDouble(),
      vitaminC: (json['vitaminC'] as num?)?.toDouble(),
      vitaminD: (json['vitaminD'] as num?)?.toDouble(),
      vitaminE: (json['vitaminE'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'sugars': sugars,
      'fiber': fiber,
      'sodium': sodium,
      'saturatedFats': saturatedFats,
      'salt': salt,
      'polyunsaturatedFat': polyunsaturatedFat,
      'monounsaturatedFat': monounsaturatedFat,
      'cholesterol': cholesterol,
      'potassium': potassium,
      'calcium': calcium,
      'iron': iron,
      'vitaminA': vitaminA,
      'vitaminC': vitaminC,
      'vitaminD': vitaminD,
      'vitaminE': vitaminE,
    };
  }

  /// Vérifie si des vitamines/minéraux sont disponibles
  bool get hasVitaminsOrMinerals =>
      calcium != null || iron != null || potassium != null ||
      vitaminA != null || vitaminC != null || vitaminD != null || vitaminE != null;

  /// Vérifie si des détails sur les lipides sont disponibles
  bool get hasFatDetails =>
      saturatedFats != null || polyunsaturatedFat != null || monounsaturatedFat != null;
}
