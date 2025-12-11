class Meal {
  final int? id;
  final String date;
  final String? time;
  final String mealType;
  final String? source;
  final List<MealItem> items;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  Meal({
    this.id,
    required this.date,
    this.time,
    required this.mealType,
    this.source,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  // Getter pour compatibilité
  String get name => '${_getMealTypeName(mealType)} - $date';
  List<MealItem> get foods => items;
  double get totalProteins => totalProtein;
  double get totalFats => totalFat;

  String _getMealTypeName(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
        return 'Petit-déjeuner';
      case 'LUNCH':
        return 'Déjeuner';
      case 'DINNER':
        return 'Dîner';
      case 'SNACK':
        return 'Collation';
      default:
        return type;
    }
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as int?,
      date: json['date'] as String,
      time: json['time'] as String?,
      mealType: json['mealType'] as String,
      source: json['source'] as String?,
      items: (json['items'] as List?)
          ?.map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date,
      if (time != null) 'time': time,
      'mealType': mealType,
      if (source != null) 'source': source,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class MealItem {
  final int? id;
  final int? foodId;
  final String foodName;
  final double quantity;
  final String? servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealItem({
    this.id,
    this.foodId,
    required this.foodName,
    required this.quantity,
    this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  // Getters pour compatibilité
  String get unit => servingUnit ?? 'g';
  double get proteins => protein;
  double get fats => fat;

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] as int?,
      foodId: json['foodId'] as int?,
      foodName: json['foodName'] as String? ?? 'Aliment',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      servingUnit: json['servingUnit'] as String?,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (foodId != null) 'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      if (servingUnit != null) 'servingUnit': servingUnit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// Ancienne classe renommée pour compatibilité
typedef MealFood = MealItem;

class CreateMealRequest {
  final String name;
  final String mealType;
  final String date;
  final List<MealFood> foods;

  CreateMealRequest({
    required this.name,
    required this.mealType,
    required this.date,
    required this.foods,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mealType': mealType,
      'date': date,
      'foods': foods.map((f) => f.toJson()).toList(),
    };
  }
}

