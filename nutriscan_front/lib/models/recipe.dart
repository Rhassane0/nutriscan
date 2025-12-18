class Recipe {
  final String? id;
  final String name;
  final String? image;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final int? prepTime;
  final int servings;
  final String? url;
  final List<String> ingredients;
  final List<String>? instructions;
  final List<String>? dietLabels;
  final List<String>? healthLabels;

  Recipe({
    this.id,
    required this.name,
    this.image,
    required this.calories,
    this.proteins = 0,
    this.carbs = 0,
    this.fats = 0,
    this.prepTime,
    this.servings = 1,
    this.url,
    this.ingredients = const [],
    this.instructions,
    this.dietLabels,
    this.healthLabels,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Parser les données nutritionnelles depuis le sous-objet 'nutrition' si présent
    final nutrition = json['nutrition'] as Map<String, dynamic>?;

    // Déterminer les valeurs nutritionnelles
    double calories = 0;
    double proteins = 0;
    double carbs = 0;
    double fats = 0;

    if (nutrition != null) {
      // Format avec sous-objet nutrition (format backend RecipeResponse)
      calories = _parseDouble(nutrition['calories'] ?? json['calories']);
      proteins = _parseDouble(nutrition['protein'] ?? nutrition['proteins']);
      carbs = _parseDouble(nutrition['carbs'] ?? nutrition['carbohydrates']);
      fats = _parseDouble(nutrition['fat'] ?? nutrition['fats']);
    } else {
      // Format plat (format direct)
      calories = _parseDouble(json['calories']);
      proteins = _parseDouble(json['proteins'] ?? json['protein']);
      carbs = _parseDouble(json['carbs'] ?? json['carbohydrates']);
      fats = _parseDouble(json['fats'] ?? json['fat']);
    }


    return Recipe(
      id: json['uri'] as String? ?? json['id'] as String?,
      // Backend utilise 'label', frontend peut utiliser 'name'
      name: json['label'] as String? ?? json['name'] as String? ?? 'Sans nom',
      image: json['image'] as String?,
      calories: calories,
      proteins: proteins,
      carbs: carbs,
      fats: fats,
      // Backend utilise 'totalTime', frontend peut utiliser 'prepTime'
      prepTime: _parseInt(json['totalTime'] ?? json['prepTime']),
      // Backend utilise 'servings' ou 'yield'
      servings: _parseInt(json['servings'] ?? json['yield']) ?? 1,
      url: json['url'] as String?,
      // Backend utilise 'ingredientLines', frontend peut utiliser 'ingredients'
      ingredients: _parseStringList(json['ingredientLines'] ?? json['ingredients']),
      instructions: _parseStringList(json['instructions']),
      dietLabels: _parseStringList(json['dietLabels']),
      healthLabels: _parseStringList(json['healthLabels']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (image != null) 'image': image,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      if (prepTime != null) 'prepTime': prepTime,
      'servings': servings,
      if (url != null) 'url': url,
      'ingredients': ingredients,
      if (instructions != null) 'instructions': instructions,
      if (dietLabels != null) 'dietLabels': dietLabels,
      if (healthLabels != null) 'healthLabels': healthLabels,
    };
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? image,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    int? prepTime,
    int? servings,
    String? url,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? dietLabels,
    List<String>? healthLabels,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      prepTime: prepTime ?? this.prepTime,
      servings: servings ?? this.servings,
      url: url ?? this.url,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      dietLabels: dietLabels ?? this.dietLabels,
      healthLabels: healthLabels ?? this.healthLabels,
    );
  }
}

