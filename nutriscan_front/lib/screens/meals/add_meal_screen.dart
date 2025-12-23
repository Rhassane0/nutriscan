import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../models/meal.dart';
import '../../providers/meal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/food_service.dart';
import '../../utils/date_formatter.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddMealScreen({super.key, this.initialDate});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> with TickerProviderStateMixin {
  late AnimationController _rotateController;

  final _naturalInputController = TextEditingController();
  final _searchController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedMealType = 'BREAKFAST';

  final List<MealItem> _items = [];
  bool _isSearching = false;
  bool _isSaving = false;
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _searchResults = [];

  final Map<String, Map<String, dynamic>> _mealTypes = {
    'BREAKFAST': {'emoji': '🌅', 'label': 'Petit-déjeuner', 'color': AppTheme.secondaryOrange},
    'LUNCH': {'emoji': '☀️', 'label': 'Déjeuner', 'color': AppTheme.primaryGreen},
    'DINNER': {'emoji': '🌙', 'label': 'Dîner', 'color': AppTheme.accentPurple},
    'SNACK': {'emoji': '🍎', 'label': 'Collation', 'color': AppTheme.accentTeal},
  };

  // Base de données nutritionnelle simplifiée (valeurs pour 100g ou unité)
  final Map<String, Map<String, double>> _nutritionDb = {
    'oeuf': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11, 'unit': 50}, // 1 oeuf = 50g
    'oeufs': {'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11, 'unit': 50},
    'pain': {'calories': 265, 'protein': 9, 'carbs': 49, 'fat': 3.2, 'unit': 100},
    'lait': {'calories': 42, 'protein': 3.4, 'carbs': 5, 'fat': 1, 'unit': 250}, // 1 verre = 250ml
    'café': {'calories': 2, 'protein': 0.3, 'carbs': 0, 'fat': 0, 'unit': 200},
    'thé': {'calories': 1, 'protein': 0, 'carbs': 0.3, 'fat': 0, 'unit': 200},
    'yaourt': {'calories': 59, 'protein': 10, 'carbs': 3.6, 'fat': 0.7, 'unit': 125},
    'fromage': {'calories': 402, 'protein': 25, 'carbs': 1.3, 'fat': 33, 'unit': 30},
    'jambon': {'calories': 145, 'protein': 21, 'carbs': 1.5, 'fat': 6, 'unit': 30},
    'poulet': {'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6, 'unit': 100},
    'riz': {'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3, 'unit': 100},
    'pâtes': {'calories': 131, 'protein': 5, 'carbs': 25, 'fat': 1.1, 'unit': 100},
    'salade': {'calories': 15, 'protein': 1.3, 'carbs': 2.9, 'fat': 0.2, 'unit': 100},
    'tomate': {'calories': 18, 'protein': 0.9, 'carbs': 3.9, 'fat': 0.2, 'unit': 100},
    'pomme': {'calories': 52, 'protein': 0.3, 'carbs': 14, 'fat': 0.2, 'unit': 150},
    'banane': {'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3, 'unit': 120},
    'orange': {'calories': 47, 'protein': 0.9, 'carbs': 12, 'fat': 0.1, 'unit': 150},
    'beurre': {'calories': 717, 'protein': 0.9, 'carbs': 0.1, 'fat': 81, 'unit': 10},
    'huile': {'calories': 884, 'protein': 0, 'carbs': 0, 'fat': 100, 'unit': 10},
    'sucre': {'calories': 387, 'protein': 0, 'carbs': 100, 'fat': 0, 'unit': 5},
    'miel': {'calories': 304, 'protein': 0.3, 'carbs': 82, 'fat': 0, 'unit': 20},
    'chocolat': {'calories': 546, 'protein': 5, 'carbs': 60, 'fat': 31, 'unit': 20},
    'croissant': {'calories': 406, 'protein': 8, 'carbs': 45, 'fat': 21, 'unit': 60},
    'baguette': {'calories': 270, 'protein': 9, 'carbs': 56, 'fat': 1.5, 'unit': 250},
    'steak': {'calories': 271, 'protein': 26, 'carbs': 0, 'fat': 18, 'unit': 150},
    'saumon': {'calories': 208, 'protein': 20, 'carbs': 0, 'fat': 13, 'unit': 150},
    'thon': {'calories': 132, 'protein': 29, 'carbs': 0, 'fat': 1, 'unit': 100},
    'avocat': {'calories': 160, 'protein': 2, 'carbs': 9, 'fat': 15, 'unit': 150},
    'haricots': {'calories': 31, 'protein': 1.8, 'carbs': 7, 'fat': 0.1, 'unit': 100},
    'carotte': {'calories': 41, 'protein': 0.9, 'carbs': 10, 'fat': 0.2, 'unit': 100},
    'pomme de terre': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'unit': 150},
    'patate': {'calories': 77, 'protein': 2, 'carbs': 17, 'fat': 0.1, 'unit': 150},
    'frites': {'calories': 312, 'protein': 3.4, 'carbs': 41, 'fat': 15, 'unit': 150},
    'pizza': {'calories': 266, 'protein': 11, 'carbs': 33, 'fat': 10, 'unit': 150},
    'burger': {'calories': 295, 'protein': 17, 'carbs': 24, 'fat': 14, 'unit': 200},
    'sandwich': {'calories': 250, 'protein': 12, 'carbs': 30, 'fat': 9, 'unit': 150},
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _naturalInputController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Parse une entrée naturelle comme "3 oeufs, 250g pain, 1 verre de lait"
  void _parseNaturalInput(String input) {
    setState(() => _isAnalyzing = true);

    final parts = input.toLowerCase().split(RegExp(r'[,;]+'));

    for (var part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;

      // Extraire quantité et aliment
      final match = RegExp(r"^(\d+(?:[.,]\d+)?)\s*(g|kg|ml|l|verre|verres|tasse|tasses|portion|portions|tranche|tranches|pièce|pièces)?\s*(?:de|d'|du|des)?\s*(.+)$", caseSensitive: false).firstMatch(part);

      double quantity = 1;
      String unit = '';
      String foodName = part;

      if (match != null) {
        quantity = double.tryParse(match.group(1)!.replaceAll(',', '.')) ?? 1;
        unit = match.group(2) ?? '';
        foodName = match.group(3)?.trim() ?? part;
      } else {
        // Essayer de trouver un nombre au début
        final numMatch = RegExp(r'^(\d+)\s*(.+)$').firstMatch(part);
        if (numMatch != null) {
          quantity = double.tryParse(numMatch.group(1)!) ?? 1;
          foodName = numMatch.group(2)?.trim() ?? part;
        }
      }

      // Chercher dans la base de données
      Map<String, double>? nutrition;
      String matchedFood = foodName;

      for (var key in _nutritionDb.keys) {
        if (foodName.contains(key)) {
          nutrition = _nutritionDb[key];
          matchedFood = key;
          break;
        }
      }

      if (nutrition != null) {
        double baseUnit = nutrition['unit'] ?? 100;
        double factor;

        // Calculer le facteur selon l'unité
        if (unit.contains('g')) {
          // Grammes
          double grams = unit.contains('kg') ? quantity * 1000 : quantity;
          factor = grams / 100;
        } else if (unit.contains('ml') || unit.contains('l')) {
          // Millilitres
          double ml = unit == 'l' ? quantity * 1000 : quantity;
          factor = ml / 100;
        } else if (unit.contains('verre')) {
          factor = quantity * (baseUnit / 100);
        } else if (unit.contains('tranche') || unit.contains('portion') || unit.contains('pièce')) {
          factor = quantity * (baseUnit / 100);
        } else {
          // Nombre d'unités
          factor = quantity * (baseUnit / 100);
        }

        _items.add(MealItem(
          foodName: '${quantity.toStringAsFixed(quantity == quantity.toInt() ? 0 : 1)} ${unit.isNotEmpty ? "$unit " : ""}$foodName',
          quantity: factor * 100,
          servingUnit: 'g',
          calories: (nutrition['calories']! * factor),
          protein: (nutrition['protein']! * factor),
          carbs: (nutrition['carbs']! * factor),
          fat: (nutrition['fat']! * factor),
        ));
      } else {
        // Aliment non trouvé, ajouter avec des valeurs estimées
        _items.add(MealItem(
          foodName: '${quantity.toStringAsFixed(quantity == quantity.toInt() ? 0 : 1)} $foodName',
          quantity: 100,
          servingUnit: 'g',
          calories: 100 * quantity, // Estimation
          protein: 5 * quantity,
          carbs: 15 * quantity,
          fat: 3 * quantity,
        ));
      }
    }

    _naturalInputController.clear();
    setState(() => _isAnalyzing = false);
  }

  Future<void> _searchFood(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final foodService = context.read<FoodService>();
      final results = await foodService.searchByName(query);

      setState(() {
        _searchResults = results.map((food) => {
          'foodId': food.foodId,
          'name': food.label,
          'calories': food.nutrients.calories ?? 0,
          'protein': food.nutrients.proteins ?? 0,
          'carbs': food.nutrients.carbs ?? 0,
          'fat': food.nutrients.fats ?? 0,
          'image': food.image,
        }).toList();
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _addFoodFromSearch(Map<String, dynamic> food) {
    _showQuantityDialog(
      foodName: food['name'],
      baseCalories: (food['calories'] as num).toDouble(),
      baseProtein: (food['protein'] as num).toDouble(),
      baseCarbs: (food['carbs'] as num).toDouble(),
      baseFat: (food['fat'] as num).toDouble(),
    );
  }

  void _showQuantityDialog({
    required String foodName,
    required double baseCalories,
    required double baseProtein,
    required double baseCarbs,
    required double baseFat,
  }) {
    final quantityController = TextEditingController(text: '100');
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F38) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                foodName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                  decoration: InputDecoration(
                    suffixText: 'g',
                    suffixStyle: TextStyle(
                      fontSize: 18,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo('🔥', '${baseCalories.toStringAsFixed(0)}', 'kcal', isDark),
                    _buildNutrientInfo('💪', '${baseProtein.toStringAsFixed(1)}', 'prot', isDark),
                    _buildNutrientInfo('🌾', '${baseCarbs.toStringAsFixed(1)}', 'gluc', isDark),
                    _buildNutrientInfo('🫒', '${baseFat.toStringAsFixed(1)}', 'lip', isDark),
                  ],
                ),
              ),
              Text(
                'Valeurs pour 100g',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final quantity = double.tryParse(quantityController.text) ?? 100;
                    final factor = quantity / 100;

                    setState(() {
                      _items.add(MealItem(
                        foodName: foodName,
                        quantity: quantity,
                        servingUnit: 'g',
                        calories: baseCalories * factor,
                        protein: baseProtein * factor,
                        carbs: baseCarbs * factor,
                        fat: baseFat * factor,
                      ));
                      _searchController.clear();
                      _searchResults = [];
                    });

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Ajouter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String emoji, String value, String label, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey[500]),
        ),
      ],
    );
  }

  Future<void> _saveMeal() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un aliment')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final mealData = {
      'date': DateFormatter.formatForApi(_selectedDate),
      'time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
      'mealType': _selectedMealType,
      'source': 'MANUAL',
      'items': _items.map((item) => {
        'foodName': item.foodName,
        'apiSource': 'MANUAL',
        'quantity': item.quantity,
        'servingUnit': item.servingUnit,
        'calories': item.calories,
        'protein': item.protein,
        'carbs': item.carbs,
        'fat': item.fat,
      }).toList(),
    };

    final provider = context.read<MealProvider>();
    final success = await provider.createMeal(mealData);

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Repas enregistré !'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erreur lors de l\'enregistrement'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : AppTheme.backgroundLight,
      body: Stack(
        children: [
          if (isDark) _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildMealTypeSelector(isDark),
                        const SizedBox(height: 20),
                        _buildDateTimeSelector(isDark),
                        const SizedBox(height: 20),
                        _buildNaturalInputSection(isDark),
                        const SizedBox(height: 20),
                        _buildSearchSection(isDark),
                        const SizedBox(height: 20),
                        _buildItemsList(isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_items.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : AppTheme.textDark),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                  ).createShader(bounds),
                  child: const Text(
                    'Repas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector(bool isDark) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _mealTypes.entries.map((entry) {
          final isSelected = _selectedMealType == entry.key;
          final color = entry.value['color'] as Color;

          return GestureDetector(
            onTap: () => setState(() => _selectedMealType = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(isDark ? 0.2 : 0.1) : (isDark ? const Color(0xFF1A1F38) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 12),
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(entry.value['emoji']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    entry.value['label']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? color : (isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateTimeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F38) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_today, color: AppTheme.accentBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _selectedTime);
              if (picked != null) setState(() => _selectedTime = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F38) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.access_time, color: AppTheme.accentPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNaturalInputSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(isDark ? 0.15 : 0.1),
            AppTheme.accentTeal.withOpacity(isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGlowGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saisie rapide',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Ex: 3 oeufs, 250g pain, 1 verre de lait',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _naturalInputController,
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
              decoration: InputDecoration(
                hintText: 'Entrez vos aliments...',
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: _isAnalyzing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.send, color: AppTheme.primaryGreen),
                  onPressed: () => _parseNaturalInput(_naturalInputController.text),
                ),
              ),
              onSubmitted: _parseNaturalInput,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F38) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _searchFood,
            style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
            decoration: InputDecoration(
              hintText: 'Rechercher dans la base de données...',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey[500]),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F38) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final food = _searchResults[index];
                return ListTile(
                  title: Text(
                    food['name'],
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                  ),
                  subtitle: Text(
                    '${(food['calories'] as num).toStringAsFixed(0)} kcal / 100g',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500], fontSize: 12),
                  ),
                  trailing: Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                  onTap: () => _addFoodFromSearch(food),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemsList(bool isDark) {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: isDark ? Colors.white24 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucun aliment ajouté',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Utilisez la saisie rapide ou la recherche',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Aliments ajoutés',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_items.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F38) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant, color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        '${item.calories.toStringAsFixed(0)} kcal • ${item.protein.toStringAsFixed(1)}g prot',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                  onPressed: () => setState(() => _items.removeAt(index)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final totalCalories = _items.fold(0.0, (sum, item) => sum + item.calories);
    final totalProtein = _items.fold(0.0, (sum, item) => sum + item.protein);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1025) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${totalCalories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                Text(
                  ' • ${totalProtein.toStringAsFixed(1)}g protéines',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text('Enregistrer le repas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

