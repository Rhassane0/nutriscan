import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
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

class _MealsScreenState extends State<MealsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MealProvider>();
      provider.loadMealsForDate(provider.selectedDate);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    HapticFeedback.lightImpact();
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
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A1F1A),
                    Color(0xFF0D2818),
                    Color(0xFF0F1F1A),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF0FDF4),
                    Color(0xFFF8FAFC),
                    Colors.white,
                  ],
                ),
        ),
        child: SafeArea(
          child: Consumer<MealProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return LoadingIndicator(message: context.tr('loading'));
              }

              return FadeTransition(
                opacity: _fadeAnimation,
                child: provider.meals.isEmpty
                    ? Column(
                        children: [
                          // En-tête premium avec date
                          _buildPremiumDateHeader(context, provider, isDark),
                          // Résumé nutritionnel compact
                          _buildCompactNutritionCard(provider, isDark),
                          // État vide
                          Expanded(child: _buildEmptyState(context, isDark)),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadMealsForDate(provider.selectedDate),
                        color: AppTheme.primaryGreen,
                        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // Date header
                            SliverToBoxAdapter(
                              child: _buildPremiumDateHeader(context, provider, isDark),
                            ),
                            // Compact nutrition card (défile aussi) — on garde un petit padding
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                child: _buildCompactNutritionCard(provider, isDark),
                              ),
                            ),
                            // Liste des repas
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final meal = provider.meals[index];
                                    return TweenAnimationBuilder<double>(
                                      duration: Duration(milliseconds: 400 + (index * 100)),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.translate(
                                          offset: Offset(0, 30 * (1 - value)),
                                          child: Opacity(
                                            opacity: value,
                                            child: _buildPremiumMealCard(context, meal, provider, isDark),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  childCount: provider.meals.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildPremiumFab(context, isDark),
    );
  }

  Widget _buildPremiumDateHeader(BuildContext context, MealProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          _buildDateNavButton(
            Icons.arrow_back_ios_rounded,
            isDark,
            () {
              HapticFeedback.lightImpact();
              provider.setSelectedDate(
                provider.selectedDate.subtract(const Duration(days: 1)),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.04),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.95),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryGreen.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : AppTheme.primaryGreen.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormatter.formatLong(provider.selectedDate),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppTheme.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    if (DateFormatter.isToday(provider.selectedDate)) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withOpacity(0.2),
                              AppTheme.primaryGreen.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('today'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildDateNavButton(
            Icons.arrow_forward_ios_rounded,
            isDark,
            () {
              HapticFeedback.lightImpact();
              provider.setSelectedDate(
                provider.selectedDate.add(const Duration(days: 1)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                )
              : const LinearGradient(
                  colors: [Colors.white, Color(0xFFFAFAFA)],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white.withOpacity(0.8) : AppTheme.textDark,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCompactNutritionCard(MealProvider provider, bool isDark) {
    final totals = provider.getDailyTotals();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.12),
                  AppTheme.primaryGreen.withOpacity(0.06),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppTheme.primaryGreen.withOpacity(0.03),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.primaryGreen.withOpacity(0.15)
              : AppTheme.primaryGreen.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(isDark ? 0.1 : 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppTheme.primaryGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Nutriments en ligne
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactNutrient('🔥', totals['calories'] ?? 0, 'kcal', AppTheme.caloriesColor, isDark),
                _buildCompactNutrient('🥩', totals['proteins'] ?? 0, 'g', AppTheme.proteinColor, isDark),
                _buildCompactNutrient('🍞', totals['carbs'] ?? 0, 'g', AppTheme.carbsColor, isDark),
                _buildCompactNutrient('🥑', totals['fats'] ?? 0, 'g', AppTheme.fatColor, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNutrient(String emoji, double value, String unit, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withOpacity(0.4) : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicNutritionCard(MealProvider provider, bool isDark) {
    final totals = provider.getDailyTotals();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.15),
                        AppTheme.primaryGreen.withOpacity(0.08),
                        Colors.white.withOpacity(0.05),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.95),
                        AppTheme.primaryGreen.withOpacity(0.05),
                      ],
                    ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? AppTheme.primaryGreen.withOpacity(0.2)
                    : AppTheme.primaryGreen.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                // Titre
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.insights_rounded,
                        color: AppTheme.primaryGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.tr('daily_summary'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white.withOpacity(0.9) : AppTheme.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Nutriments
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientCircle('🔥', totals['calories'] ?? 0, 'kcal', context.tr('calories'), AppTheme.caloriesColor, isDark, isMain: true),
                    _buildNutrientCircle('🥩', totals['proteins'] ?? 0, 'g', context.tr('protein'), AppTheme.proteinColor, isDark),
                    _buildNutrientCircle('🍞', totals['carbs'] ?? 0, 'g', context.tr('carbs'), AppTheme.carbsColor, isDark),
                    _buildNutrientCircle('🥑', totals['fats'] ?? 0, 'g', context.tr('fat'), AppTheme.fatColor, isDark),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientCircle(String emoji, double value, String unit, String label, Color color, bool isDark, {bool isMain = false}) {
    return Column(
      children: [
        Container(
          width: isMain ? 72 : 60,
          height: isMain ? 72 : 60,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color.withOpacity(isDark ? 0.3 : 0.2),
                color.withOpacity(isDark ? 0.1 : 0.05),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: isMain ? 28 : 24)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: isMain ? 24 : 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white.withOpacity(0.4) : AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation d'illustration
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryGreen.withOpacity(isDark ? 0.15 : 0.1),
                          AppTheme.primaryGreen.withOpacity(isDark ? 0.05 : 0.02),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.15),
                              AppTheme.primaryGreen.withOpacity(isDark ? 0.1 : 0.08),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('🍽️', style: const TextStyle(fontSize: 48)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32),
          Text(
            context.tr('no_meals_recorded'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.textDark,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              context.tr('add_first_meal'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.white.withOpacity(0.5) : AppTheme.textMedium,
              ),
            ),
          ),
          SizedBox(height: 32),
          // Bouton d'action premium
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    context.tr('add_first_meal'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMealCard(BuildContext context, Meal meal, MealProvider provider, bool isDark) {
    final mealEmoji = _getMealEmoji(meal.mealType);
    final mealColor = _getMealColor(meal.mealType);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                        mealColor.withOpacity(0.05),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                        mealColor.withOpacity(0.05),
                      ],
                    ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? mealColor.withOpacity(0.2)
                    : mealColor.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: mealColor.withOpacity(isDark ? 0.15 : 0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header du repas
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        mealColor.withOpacity(isDark ? 0.1 : 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icône avec effet glow
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [mealColor, mealColor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: mealColor.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(mealEmoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getMealTypeName(context, meal.mealType),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppTheme.textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: mealColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.restaurant_menu_rounded, size: 12, color: mealColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${meal.foods.length} aliment${meal.foods.length > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: mealColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Bouton supprimer
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _confirmDelete(context, meal, provider, isDark);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.errorRed.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppTheme.errorRed.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Nutrition du repas
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.06),
                              Colors.white.withOpacity(0.03),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.surfaceGrey.withOpacity(0.5),
                              AppTheme.surfaceGrey.withOpacity(0.3),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMealNutrient('🔥', meal.totalCalories, 'cal', AppTheme.caloriesColor, isDark),
                      _buildVerticalDivider(isDark),
                      _buildMealNutrient('🥩', meal.totalProteins, 'g', AppTheme.proteinColor, isDark),
                      _buildVerticalDivider(isDark),
                      _buildMealNutrient('🍞', meal.totalCarbs, 'g', AppTheme.carbsColor, isDark),
                      _buildVerticalDivider(isDark),
                      _buildMealNutrient('🥑', meal.totalFats, 'g', AppTheme.fatColor, isDark),
                    ],
                  ),
                ),

                // Liste des aliments
                if (meal.foods.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                size: 14,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.tr('consumed_foods'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...meal.foods.take(3).map((item) => _buildFoodItemRow(context, item, isDark)),
                        if (meal.foods.length > 3)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.more_horiz_rounded,
                                  size: 16,
                                  color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '+ ${meal.foods.length - 3} autre(s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                // Footer avec analyse
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      MealNutritionBadge(meal: meal, isDark: isDark),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showNutritionAnalysis(context, meal, isDark);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentBlue.withOpacity(0.15),
                                AppTheme.accentBlue.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.accentBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insights_rounded,
                                size: 16,
                                color: AppTheme.accentBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr('view_analysis'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark ? Colors.white.withOpacity(0.15) : Colors.grey.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  void _showNutritionAnalysis(BuildContext context, Meal meal, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2E28) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getMealColor(meal.mealType).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(_getMealEmoji(meal.mealType), style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _getMealTypeName(context, meal.mealType),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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

  Widget _buildFoodItemRow(BuildContext context, MealItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFFDFDFD)],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.2),
                  AppTheme.primaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('🥗', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.foodName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniTag('${item.quantity.toStringAsFixed(0)}${item.unit}', AppTheme.primaryGreen, isDark),
                    const SizedBox(width: 6),
                    _buildMiniTag('${item.calories.toStringAsFixed(0)} kcal', AppTheme.caloriesColor, isDark),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : AppTheme.surfaceGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMicroNutrient('P', item.protein, AppTheme.proteinColor),
                const SizedBox(width: 6),
                _buildMicroNutrient('G', item.carbs, AppTheme.carbsColor),
                const SizedBox(width: 6),
                _buildMicroNutrient('L', item.fat, AppTheme.fatColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMicroNutrient(String letter, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          letter,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${value.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMealNutrient(String emoji, double value, String unit, Color color, bool isDark) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withOpacity(0.4) : AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Meal meal, MealProvider provider, bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A2E28) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Confirmer la suppression',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous supprimer "${meal.name}" ?',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white.withOpacity(0.7) : AppTheme.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.6) : AppTheme.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Supprimer',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && meal.id != null) {
      await provider.deleteMeal(meal.id!);
    }
  }

  Widget _buildPremiumFab(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr('add'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
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

  String _getMealTypeName(BuildContext context, String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST': return context.tr('breakfast');
      case 'LUNCH': return context.tr('lunch');
      case 'DINNER': return context.tr('dinner');
      case 'SNACK': return context.tr('snack');
      default: return mealType ?? context.tr('meals');
    }
  }
}

// Delegate pour le header compact qui se réduit au scroll
class _CompactSummaryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Map<String, double> totals;
  final bool isDark;
  final Widget dateHeader;
  final WidgetBuilder compactCardBuilder;

  _CompactSummaryHeaderDelegate({required this.totals, required this.isDark, required this.dateHeader, required this.compactCardBuilder});

  @override
  double get minExtent => 84;

  @override
  double get maxExtent => 160;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (1 - (shrinkOffset / (maxExtent - minExtent))).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.95,
        child: Column(
          children: [
            // Date header (garde sa taille fixe)
            dateHeader,
            // Compact card - on scale un peu selon t pour la rendre moins imposante
            Transform.scale(
              scale: 0.9 + (0.1 * t),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: compactCardBuilder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CompactSummaryHeaderDelegate oldDelegate) {
    return oldDelegate.totals != totals || oldDelegate.isDark != isDark;
  }
}