import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/theme.dart';
import '../../widgets/theme_widgets.dart';
import '../../widgets/meal_nutrition_analysis.dart';
import '../../widgets/daily_nutrition_summary.dart';
import '../../services/tips_service.dart';
import '../scanner/scanner_hub_screen.dart';
import '../meals/meals_screen.dart';
import '../planner/meal_planner_screen.dart';
import '../profile/profile_screen.dart';
import '../planner/grocery_list_screen.dart';
import '../recipes/recipe_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(onNavigateToTab: _navigateToTab),
          const MealsScreen(),
          const MealPlannerScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x4D000000) : const Color(0x0D000000),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, context.tr('home'), isDark),
                  _buildNavItem(1, Icons.restaurant_rounded, context.tr('meals'), isDark),
                  _buildNavItem(2, Icons.calendar_month_rounded, context.tr('planner'), isDark),
                  _buildNavItem(3, Icons.person_rounded, context.tr('profile'), isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0x4D00C853) : const Color(0x2600C853))
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryGreen
                  : (isDark ? AppTheme.darkTextTertiary : AppTheme.textLight),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final void Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadMealsForDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final mealProvider = context.watch<MealProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final username = authProvider.user?.username ?? 'Utilisateur';
    final dailyTotals = mealProvider.getDailyTotals();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryGreenSoft,
                    AppTheme.backgroundLight,
                    AppTheme.backgroundLight,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(username, isDark),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildWelcomeCard(username, isDark),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildQuickActionsSection(context, isDark),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildDailyProgressSection(dailyTotals, isDark),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildTipsCard(isDark),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String username, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 22)),
                ],
              ),
            ],
          ),
          const Spacer(),

          // Bouton de notification
          _buildHeaderButton(
            icon: Icons.notifications_outlined,
            isDark: isDark,
            hasBadge: true,
            onTap: () {},
          ),
          const SizedBox(width: 12),

          // Bouton de thème
          const ThemeToggleButton(size: 44),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required bool isDark,
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? const Color(0x1AFFFFFF)
                : const Color(0x0D000000),
          ),
          boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
        ),
        child: Stack(
          children: [
            Icon(
              icon,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              size: 24,
            ),
            if (hasBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangeGradient,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x80FF6F00),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('good_morning');
    if (hour < 18) return context.tr('good_afternoon');
    return context.tr('good_evening');
  }

  Widget _buildWelcomeCard(String username, bool isDark) {
    final mealProvider = context.watch<MealProvider>();
    final meals = mealProvider.meals;
    final totals = mealProvider.getDailyTotals();

    // Obtenir un conseil dynamique
    final tip = TipsService.getTipOfTheDay(
      todayMeals: meals,
      nutritionTotals: totals,
    );

    // Couleur du conseil
    final tipColor = _getTipColor(tip.color);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGlowGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x6600C853),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('🥗', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, $username',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xCCFFFFFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('eat_healthy'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Conseil dynamique
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0x26FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tip.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tip.message,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xE6FFFFFF),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTipColor(TipColor tipColor) {
    switch (tipColor) {
      case TipColor.green:
        return AppTheme.primaryGreen;
      case TipColor.blue:
        return AppTheme.accentBlue;
      case TipColor.orange:
        return AppTheme.secondaryOrange;
      case TipColor.purple:
        return AppTheme.accentPurple;
    }
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.flash_on_rounded,
          title: context.tr('quick_actions'),
          color: AppTheme.warningYellow,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FeatureIconCard(
                emoji: '📷',
                title: context.tr('scan'),
                subtitle: context.tr('barcode'),
                color: AppTheme.primaryGreen,
                gradient: AppTheme.primaryGlowGradient,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ScannerHubScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureIconCard(
                emoji: '🍽️',
                title: context.tr('my_meals'),
                subtitle: context.tr('today'),
                color: AppTheme.secondaryOrange,
                gradient: AppTheme.orangeGradient,
                onTap: () => widget.onNavigateToTab?.call(1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FeatureIconCard(
                emoji: '📅',
                title: context.tr('plan_week'),
                subtitle: context.tr('week'),
                color: AppTheme.accentBlue,
                gradient: AppTheme.blueGradient,
                onTap: () => widget.onNavigateToTab?.call(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FeatureIconCard(
                emoji: '🛒',
                title: context.tr('shopping'),
                subtitle: context.tr('list'),
                color: AppTheme.accentPurple,
                gradient: AppTheme.purpleGradient,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GroceryListScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FeatureIconCard(
          emoji: '🔍',
          title: context.tr('search_recipes'),
          subtitle: context.tr('find_meal_ideas'),
          color: AppTheme.accentTeal,
          gradient: AppTheme.tealGradient,
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RecipeSearchScreen())),
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyProgressSection(Map<String, double> totals, bool isDark) {
    final mealProvider = context.watch<MealProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionHeader(
              icon: Icons.analytics_rounded,
              title: context.tr('today'),
              color: AppTheme.caloriesColor,
              isDark: isDark,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showDetailedNutritionSummary(context, mealProvider, isDark),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text(
                      'Analyse complète',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showDetailedNutritionSummary(context, mealProvider, isDark),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? AppTheme.caloriesColor.withOpacity(0.2)
                    : Colors.transparent,
              ),
              boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.mediumShadow,
            ),
            child: Column(
              children: [
                // Calories en grand avec animation
                _buildCaloriesDisplay(totals['calories'] ?? 0, isDark),
                const SizedBox(height: 24),
                Divider(
                  color: isDark ? AppTheme.darkDivider : AppTheme.surfaceGrey,
                ),
                const SizedBox(height: 20),
                // Macros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMacroItem('🥩', context.tr('protein'), totals['proteins'] ?? 0, 120, AppTheme.proteinColor, isDark),
                    _buildMacroItem('🍞', context.tr('carbs'), totals['carbs'] ?? 0, 250, AppTheme.carbsColor, isDark),
                    _buildMacroItem('🥑', context.tr('fat'), totals['fats'] ?? 0, 70, AppTheme.fatColor, isDark),
                  ],
                ),
                // Score nutritionnel et indicateur micronutriments
                if (mealProvider.dailySummary != null) ...[
                  const SizedBox(height: 16),
                  Divider(color: isDark ? AppTheme.darkDivider : AppTheme.surfaceGrey),
                  const SizedBox(height: 12),
                  _buildNutritionScoreRow(mealProvider.dailySummary!, isDark),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Affiche le score nutritionnel et des indicateurs de micronutriments
  Widget _buildNutritionScoreRow(DailySummaryData summary, bool isDark) {
    final score = summary.nutritionScore;
    final scoreColor = score >= 80 ? AppTheme.successGreen
        : score >= 60 ? AppTheme.accentTeal
        : score >= 40 ? AppTheme.warningYellow : AppTheme.errorRed;

    return Row(
      children: [
        // Score nutritionnel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: scoreColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'Score: $score',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Indicateurs micronutriments
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMicroBadge('🧬', 'Fibres', summary.totalFiber ?? 0, 25, isDark),
                const SizedBox(width: 6),
                _buildMicroBadge('🧂', 'Sodium', summary.totalSodium ?? 0, 2400, isDark, unit: 'mg'),
                const SizedBox(width: 6),
                _buildMicroBadge('🍬', 'Sucres', summary.totalSugars ?? 0, 50, isDark),
              ],
            ),
          ),
        ),
        // Bouton voir plus
        Icon(
          Icons.arrow_forward_ios,
          color: isDark ? Colors.white38 : AppTheme.textLight,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildMicroBadge(String emoji, String label, double value, double goal, bool isDark, {String unit = 'g'}) {
    final percentage = (value / goal * 100).clamp(0.0, 100.0);
    final color = percentage >= 80 ? AppTheme.successGreen
        : percentage >= 50 ? AppTheme.accentTeal
        : AppTheme.textMedium;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            '${value.toStringAsFixed(0)}$unit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Affiche le résumé nutritionnel détaillé dans un bottom sheet
  void _showDetailedNutritionSummary(BuildContext context, MealProvider provider, bool isDark) {
    final summary = provider.dailySummary;
    if (summary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chargement des données nutritionnelles...'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBackground : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Titre
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Analyse Nutritionnelle',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              Text(
                                'Vitamines, minéraux et plus',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: isDark ? Colors.white54 : AppTheme.textMedium),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Contenu scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: DailyNutritionSummary(
                        summary: summary,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCaloriesDisplay(double calories, bool isDark) {
    final progress = (calories / 2000).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppTheme.caloriesColor, AppTheme.secondaryOrangeLight],
              ).createShader(bounds),
              child: Text(
                calories.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                ' / 2000 kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 12,
          width: 220,
          decoration: BoxDecoration(
            color: AppTheme.caloriesColor.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                width: 220 * progress,
                decoration: BoxDecoration(
                  gradient: AppTheme.orangeGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.caloriesColor.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroItem(String emoji, String label, double value, double goal, Color color, bool isDark) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: color.withOpacity(isDark ? 0.2 : 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${value.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(bool isDark) {
    final tips = [
      {'emoji': '💧', 'tip': 'Buvez au moins 8 verres d\'eau par jour', 'color': AppTheme.accentBlue},
      {'emoji': '🥬', 'tip': 'Mangez 5 fruits et légumes par jour', 'color': AppTheme.primaryGreen},
      {'emoji': '🏃', 'tip': 'Faites 30 minutes d\'activité physique', 'color': AppTheme.secondaryOrange},
    ];

    final randomTip = tips[DateTime.now().day % tips.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkSurfaceLight, AppTheme.darkSurface]
              : [Colors.white, AppTheme.surfaceGreyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (randomTip['color'] as Color).withOpacity(isDark ? 0.3 : 0.2),
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (randomTip['color'] as Color),
                  (randomTip['color'] as Color).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (randomTip['color'] as Color).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                randomTip['emoji'] as String,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('tip_of_day'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: randomTip['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  randomTip['tip'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
