import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/meal.dart';
import '../../providers/meal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/food_service.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddMealScreen({super.key, this.initialDate});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _searchController = TextEditingController();

  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedMealType = 'BREAKFAST';

  final List<MealItem> _items = [];
  bool _isSearching = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _searchResults = [];
  String? _error;

  // Pour l'ajout manuel d'aliment
  final _manualNameController = TextEditingController();
  final _manualQuantityController = TextEditingController(text: '100');
  final _manualCaloriesController = TextEditingController();
  final _manualProteinController = TextEditingController();
  final _manualCarbsController = TextEditingController();
  final _manualFatController = TextEditingController();

  final Map<String, String> _mealTypes = {
    'BREAKFAST': '🌅 Petit-déjeuner',
    'LUNCH': '☀️ Déjeuner',
    'DINNER': '🌙 Dîner',
    'SNACK': '🍎 Collation',
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualNameController.dispose();
    _manualQuantityController.dispose();
    _manualCaloriesController.dispose();
    _manualProteinController.dispose();
    _manualCarbsController.dispose();
    _manualFatController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
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
        _error = 'Erreur lors de la recherche: $e';
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quantité pour "$foodName"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité (g)',
                suffixText: 'g',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Valeurs pour 100g:\n'
              '${baseCalories.toStringAsFixed(0)} kcal • '
              '${baseProtein.toStringAsFixed(1)}g prot • '
              '${baseCarbs.toStringAsFixed(1)}g glucides • '
              '${baseFat.toStringAsFixed(1)}g lipides',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
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
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showManualAddDialog() {
    _manualNameController.clear();
    _manualQuantityController.text = '100';
    _manualCaloriesController.clear();
    _manualProteinController.clear();
    _manualCarbsController.clear();
    _manualFatController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter manuellement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _manualNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'aliment *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _manualQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité (g) *',
                  suffixText: 'g',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _manualCaloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  suffixText: 'kcal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _manualProteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Protéines',
                  suffixText: 'g',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center, color: Colors.red),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _manualCarbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Glucides',
                  suffixText: 'g',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grain, color: Colors.brown),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _manualFatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lipides',
                  suffixText: 'g',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.opacity, color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_manualNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un nom')),
                );
                return;
              }

              setState(() {
                _items.add(MealItem(
                  foodName: _manualNameController.text,
                  quantity: double.tryParse(_manualQuantityController.text) ?? 100,
                  servingUnit: 'g',
                  calories: double.tryParse(_manualCaloriesController.text) ?? 0,
                  protein: double.tryParse(_manualProteinController.text) ?? 0,
                  carbs: double.tryParse(_manualCarbsController.text) ?? 0,
                  fat: double.tryParse(_manualFatController.text) ?? 0,
                ));
              });

              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Map<String, double> _getTotals() {
    double calories = 0, protein = 0, carbs = 0, fat = 0;
    for (var item in _items) {
      calories += item.calories;
      protein += item.protein;
      carbs += item.carbs;
      fat += item.fat;
    }
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  Future<void> _saveMeal() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez au moins un aliment'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final mealProvider = context.read<MealProvider>();

      final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final mealData = {
        'date': _selectedDate.toIso8601String().split('T')[0],
        'time': timeString,
        'mealType': _selectedMealType,
        'source': 'MANUAL',
        'items': _items.map((item) => item.toJson()).toList(),
      };

      final success = await mealProvider.createMeal(mealData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repas ajouté avec succès!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        setState(() {
          _error = mealProvider.error ?? 'Erreur lors de la sauvegarde';
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _getTotals();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Repas'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (_items.isNotEmpty)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveMeal,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              label: Text(
                _isSaving ? 'Sauvegarde...' : 'Sauvegarder',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: Column(
          children: [
            // En-tête avec date, heure et type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Type de repas
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _mealTypes.entries.map((entry) {
                        final isSelected = _selectedMealType == entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedMealType = entry.key;
                                });
                              }
                            },
                            selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                            backgroundColor: isDark ? AppTheme.darkSurfaceLight : null,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date et heure
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppTheme.darkSurfaceLight : null,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppTheme.darkSurfaceLight : null,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 20, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un aliment...',
                        hintStyle: TextStyle(color: isDark ? AppTheme.darkTextTertiary : Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                        ),
                        filled: true,
                        fillColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[100],
                      ),
                      onChanged: (value) => _searchFood(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showManualAddDialog,
                    icon: const Icon(Icons.add_circle),
                    color: AppTheme.primaryGreen,
                    iconSize: 36,
                    tooltip: 'Ajouter manuellement',
                  ),
                ],
              ),
            ),

            // Résultats de recherche
            if (_searchResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
                  boxShadow: isDark ? null : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? AppTheme.darkDivider : Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final food = _searchResults[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        food['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      subtitle: Text(
                        '${(food['calories'] as num).toStringAsFixed(0)} kcal/100g',
                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600]),
                      ),
                      trailing: const Icon(Icons.add, color: AppTheme.primaryGreen),
                      onTap: () => _addFoodFromSearch(food),
                    );
                  },
                ),
              ),

            // Erreur
            if (_error != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.errorRed),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _error = null),
                      color: AppTheme.errorRed,
                    ),
                  ],
                ),
              ),

            // Liste des aliments ajoutés
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: isDark ? AppTheme.darkTextTertiary : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun aliment ajouté',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recherchez ou ajoutez manuellement',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppTheme.darkTextTertiary : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isDark ? AppTheme.darkSurface : Colors.white,
                          child: ListTile(
                            title: Text(
                              item.foodName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity.toStringAsFixed(0)} ${item.unit}',
                                  style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _buildNutrientChip('${item.calories.toStringAsFixed(0)} kcal', Colors.orange, isDark),
                                    const SizedBox(width: 4),
                                    _buildNutrientChip('${item.protein.toStringAsFixed(1)}g P', Colors.red, isDark),
                                    const SizedBox(width: 4),
                                    _buildNutrientChip('${item.carbs.toStringAsFixed(1)}g C', Colors.brown, isDark),
                                    const SizedBox(width: 4),
                                    _buildNutrientChip('${item.fat.toStringAsFixed(1)}g F', Colors.amber, isDark),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                              onPressed: () => _removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Totaux nutritionnels
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryGreen.withOpacity(0.15)
                      : AppTheme.primaryGreen.withOpacity(0.1),
                  border: Border(
                    top: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total du repas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTotalItem('🔥', '${totals['calories']!.toStringAsFixed(0)}', 'kcal', isDark),
                        _buildTotalItem('🥩', '${totals['protein']!.toStringAsFixed(1)}', 'g prot', isDark),
                        _buildTotalItem('🍞', '${totals['carbs']!.toStringAsFixed(1)}', 'g gluc', isDark),
                        _buildTotalItem('🥑', '${totals['fat']!.toStringAsFixed(1)}', 'g lip', isDark),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _items.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: 'add_meal_fab',
              onPressed: _isSaving ? null : _saveMeal,
              backgroundColor: AppTheme.primaryGreen,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder'),
            )
          : null,
    );
  }

  Widget _buildNutrientChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTotalItem(String emoji, String value, String unit, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        Text(
          unit,
          style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600]),
        ),
      ],
    );
  }
}

