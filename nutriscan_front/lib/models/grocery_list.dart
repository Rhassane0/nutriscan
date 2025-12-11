class GroceryList {
  final int id;
  final String? startDate;
  final String? endDate;
  final String? generatedDate;
  final List<GroceryItem> items;
  final int? totalItemsCount;

  GroceryList({
    required this.id,
    this.startDate,
    this.endDate,
    this.generatedDate,
    required this.items,
    this.totalItemsCount,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as int,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      generatedDate: json['generatedDate'] as String?,
      items: (json['items'] as List?)
          ?.map((item) => GroceryItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalItemsCount: json['totalItems'] as int?,
    );
  }

  // Grouper les items par catégorie
  List<GroceryCategory> get categories {
    final Map<String, List<GroceryItem>> grouped = {};
    for (var item in items) {
      final category = item.category ?? 'Autres';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }

    return grouped.entries.map((entry) {
      return GroceryCategory(
        category: entry.key,
        items: entry.value,
      );
    }).toList()..sort((a, b) => a.category.compareTo(b.category));
  }

  int get totalItems {
    return totalItemsCount ?? items.length;
  }

  int get purchasedItems {
    return items.where((item) => item.purchased).length;
  }

  double get progress {
    if (totalItems == 0) return 0;
    return purchasedItems / totalItems;
  }
}

class GroceryCategory {
  final String category;
  final List<GroceryItem> items;

  GroceryCategory({
    required this.category,
    required this.items,
  });

  int get purchasedCount {
    return items.where((item) => item.purchased).length;
  }
}

class GroceryItem {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final bool purchased;

  GroceryItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    required this.purchased,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Article',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String?,
      purchased: json['purchased'] as bool? ?? false,
    );
  }

  GroceryItem copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    bool? purchased,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      purchased: purchased ?? this.purchased,
    );
  }
}

class GenerateGroceryListRequest {
  final int? mealPlanId;
  final String? startDate;
  final String? endDate;

  GenerateGroceryListRequest({
    this.mealPlanId,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    if (mealPlanId != null) {
      return {'mealPlanId': mealPlanId};
    }
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

