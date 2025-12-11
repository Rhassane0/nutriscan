import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/meal_nutrition_analysis.dart';
import '../../utils/date_formatter.dart';
import '../../models/meal.dart';
import 'add_meal_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealProvider>();
      provider.loadMealsForDate(provider.selectedDate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final provider = context.read<MealProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppTheme.primaryGreen,
                    surface: AppTheme.darkSurface,
                  )
                : const ColorScheme.light(
                    primary: AppTheme.primaryGreen,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: SafeArea(
          child: Consumer<MealProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const LoadingIndicator(message: 'Chargement des repas...');
              }

              return Column(
                children: [
                  // En-tête avec date
                  _buildDateHeader(provider, isDark),

                  // Résumé nutritionnel
                  _buildNutritionSummary(provider, isDark),

                  // Liste des repas
                  Expanded(
                    child: provider.meals.isEmpty
                        ? _buildEmptyState(isDark)
                        : RefreshIndicator(
                            onRefresh: () => provider.loadMealsForDate(provider.selectedDate),
                            color: AppTheme.primaryGreen,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: provider.meals.length,
                              itemBuilder: (context, index) {
                                final meal = provider.meals[index];
                                return _buildMealCard(meal, provider, isDark);
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFab(isDark),
    );
  }

  Widget _buildDateHeader(MealProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildNavButton(
            Icons.chevron_left,
            isDark,
            () => provider.setSelectedDate(
              provider.selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Column(
                children: [
                  Text(
                    DateFormatter.formatLong(provider.selectedDate),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                  if (DateFormatter.isToday(provider.selectedDate))
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(isDark ? 0.3 : 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Aujourd\'hui',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildNavButton(
            Icons.chevron_right,
            isDark,
            () => provider.setSelectedDate(
              provider.selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
        ),
        child: Icon(
          icon,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(MealProvider provider, bool isDark) {
    final totals = provider.getDailyTotals();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [AppTheme.darkSurfaceLight, AppTheme.darkSurface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFFAFAFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.mediumShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutrientItem('🔥', totals['calories'] ?? 0, 'kcal', 'Calories', AppTheme.caloriesColor, isDark),
          _buildNutrientDivider(isDark),
          _buildNutrientItem('🥩', totals['proteins'] ?? 0, 'g', 'Protéines', AppTheme.proteinColor, isDark),
          _buildNutrientDivider(isDark),
          _buildNutrientItem('🍞', totals['carbs'] ?? 0, 'g', 'Glucides', AppTheme.carbsColor, isDark),
          _buildNutrientDivider(isDark),
          _buildNutrientItem('🥑', totals['fats'] ?? 0, 'g', 'Lipides', AppTheme.fatColor, isDark),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(String emoji, double value, String unit, String label, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(height: 10),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientDivider(bool isDark) {
    return Container(
      width: 1,
      height: 60,
      color: isDark ? AppTheme.darkDivider : AppTheme.surfaceGrey,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryGreen.withOpacity(0.15)
                  : AppTheme.primaryGreenSoft,
              shape: BoxShape.circle,
            ),
            child: const Text('🍽️', style: TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun repas pour cette date',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier repas',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Meal meal, MealProvider provider, bool isDark) {
    final mealEmoji = _getMealEmoji(meal.mealType);
    final mealColor = _getMealColor(meal.mealType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: mealColor.withOpacity(isDark ? 0.3 : 0.15),
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        children: [
          // Header du repas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mealColor, mealColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: mealColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(mealEmoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMealTypeName(meal.mealType),
                        style: TextStyle(
                          fontSize: 13,
                          color: mealColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppTheme.errorRed.withOpacity(0.7),
                  ),
                  onPressed: () => _confirmDelete(meal, provider, isDark),
                ),
              ],
            ),
          ),

          // Nutrition du repas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkSurfaceLight.withOpacity(0.5)
                  : AppTheme.surfaceGrey.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMealNutrient('🔥', meal.totalCalories, 'cal', AppTheme.caloriesColor, isDark),
                _buildMealNutrient('🥩', meal.totalProteins, 'g', AppTheme.proteinColor, isDark),
                _buildMealNutrient('🍞', meal.totalCarbs, 'g', AppTheme.carbsColor, isDark),
                _buildMealNutrient('🥑', meal.totalFats, 'g', AppTheme.fatColor, isDark),
              ],
            ),
          ),

          // Nombre d'aliments et score nutritionnel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 16,
                  color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
                ),
                const SizedBox(width: 6),
                Text(
                  '${meal.foods.length} aliment${meal.foods.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
                  ),
                ),
                const Spacer(),
                // Badge d'analyse nutritionnelle
                MealNutritionBadge(meal: meal, isDark: isDark),
              ],
            ),
          ),

          // Bouton pour voir l'analyse détaillée
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: GestureDetector(
              onTap: () => _showNutritionAnalysis(meal, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withAlpha(isDark ? 26 : 13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentBlue.withAlpha(51),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 16,
                      color: AppTheme.accentBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Voir l\'analyse',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNutritionAnalysis(Meal meal, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${_getMealEmoji(meal.mealType)} ${_getMealTypeName(meal.mealType)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MealNutritionAnalysis(
              meal: meal,
              isDark: isDark,
              showDetails: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMealNutrient(String emoji, double value, String unit, Color color, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(Meal meal, MealProvider provider, bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        content: Text(
          'Voulez-vous supprimer "${meal.name}" ?',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && meal.id != null) {
      await provider.deleteMeal(meal.id!);
    }
  }

  Widget _buildFab(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGlowGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'meals_fab',
        onPressed: () async {
          final provider = context.read<MealProvider>();
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealScreen(
                initialDate: provider.selectedDate,
              ),
            ),
          );

          if (result == true) {
            provider.loadMealsForDate(provider.selectedDate);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getMealEmoji(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST': return '🌅';
      case 'LUNCH': return '☀️';
      case 'DINNER': return '🌙';
      case 'SNACK': return '🍎';
      default: return '🍽️';
    }
  }

  Color _getMealColor(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST': return AppTheme.secondaryOrange;
      case 'LUNCH': return AppTheme.primaryGreen;
      case 'DINNER': return AppTheme.accentPurple;
      case 'SNACK': return AppTheme.accentTeal;
      default: return AppTheme.textMedium;
    }
  }

  String _getMealTypeName(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST': return 'Petit-déjeuner';
      case 'LUNCH': return 'Déjeuner';
      case 'DINNER': return 'Dîner';
      case 'SNACK': return 'Collation';
      default: return mealType ?? 'Repas';
    }
  }
}

