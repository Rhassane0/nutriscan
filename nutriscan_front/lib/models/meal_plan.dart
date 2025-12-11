class MealPlan {
  final int id;
  final String startDate;
  final String endDate;
  final String? planType;
  final String? dietType;
  final double totalCalories;
  final double? totalProtein;
  final double? totalCarbs;
  final double? totalFat;
  final List<MealItem> meals;

  MealPlan({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.planType,
    this.dietType,
    required this.totalCalories,
    this.totalProtein,
    this.totalCarbs,
    this.totalFat,
    required this.meals,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: (json['id'] as num?)?.toInt() ?? 0,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      planType: json['planType']?.toString(),
      dietType: json['dietType']?.toString() ?? json['planType']?.toString(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble(),
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble(),
      totalFat: (json['totalFat'] as num?)?.toDouble(),
      meals: (json['meals'] as List?)
          ?.map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Getter pour obtenir les repas groupés par jour
  List<DailyMeal> get dailyMeals {
    final Map<String, List<MealItem>> grouped = {};
    for (var meal in meals) {
      if (!grouped.containsKey(meal.date)) {
        grouped[meal.date] = [];
      }
      grouped[meal.date]!.add(meal);
    }

    return grouped.entries.map((entry) {
      final dayMeals = entry.value;
      return DailyMeal(
        date: entry.key,
        breakfast: dayMeals.where((m) => m.mealType == 'BREAKFAST').firstOrNull,
        lunch: dayMeals.where((m) => m.mealType == 'LUNCH').firstOrNull,
        dinner: dayMeals.where((m) => m.mealType == 'DINNER').firstOrNull,
        snack: dayMeals.where((m) => m.mealType == 'SNACK').firstOrNull,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }
}

class MealItem {
  final String date;
  final String mealType;
  final String recipeName;
  final String? recipeUri;
  final String? recipeImage;
  final int servings;
  final double calories;
  final List<String> ingredients;

  MealItem({
    required this.date,
    required this.mealType,
    required this.recipeName,
    this.recipeUri,
    this.recipeImage,
    required this.servings,
    required this.calories,
    required this.ingredients,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      date: json['date']?.toString() ?? '',
      mealType: json['mealType']?.toString() ?? 'LUNCH',
      recipeName: json['recipeName']?.toString() ?? 'Recette',
      recipeUri: json['recipeUri']?.toString(),
      recipeImage: json['recipeImage']?.toString(),
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      ingredients: (json['ingredients'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

class DailyMeal {
  final String date;
  final MealItem? breakfast;
  final MealItem? lunch;
  final MealItem? dinner;
  final MealItem? snack;

  DailyMeal({
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snack,
  });

  List<MealItem> getAllMeals() {
    return [
      if (breakfast != null) breakfast!,
      if (lunch != null) lunch!,
      if (dinner != null) dinner!,
      if (snack != null) snack!,
    ];
  }
}


class Recipe {
  final String name;
  final String? image;
  final int calories;
  final int? prepTime;
  final String? url;
  final List<String>? ingredients;

  Recipe({
    required this.name,
    this.image,
    required this.calories,
    this.prepTime,
    this.url,
    this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] as String,
      image: json['image'] as String?,
      calories: json['calories'] as int,
      prepTime: json['prepTime'] as int?,
      url: json['url'] as String?,
      ingredients: (json['ingredients'] as List?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}

class GenerateMealPlanRequest {
  final String startDate;
  final String endDate;
  final String dietType;
  final List<String> healthLabels;
  final List<String> allergies;
  final int caloriesPerDay;
  final int mealsPerDay;

  GenerateMealPlanRequest({
    required this.startDate,
    required this.endDate,
    required this.dietType,
    this.healthLabels = const [],
    this.allergies = const [],
    required this.caloriesPerDay,
    this.mealsPerDay = 3,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
      'dietType': dietType,
      'healthLabels': healthLabels,
      'allergies': allergies,
      'caloriesPerDay': caloriesPerDay,
      'mealsPerDay': mealsPerDay,
    };
  }
}

