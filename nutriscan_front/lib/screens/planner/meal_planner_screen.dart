import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/planner_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../models/meal_plan.dart';
import '../../config/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/date_formatter.dart';
import '../../utils/constants.dart';
import 'grocery_list_screen.dart';
import 'generate_plan_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlannerProvider>().loadCurrentWeekPlan();
    });
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
          child: Consumer<PlannerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return LoadingIndicator(message: context.tr('loading'));
              }

              return Column(
                children: [
                  _buildHeader(context, isDark),
                  Expanded(
                    child: provider.currentPlan == null
                        ? _buildEmptyState(context, isDark)
                        : _buildPlanContent(provider, isDark),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      // FAB n'apparaît que s'il y a déjà un plan
      floatingActionButton: Consumer<PlannerProvider>(
        builder: (context, provider, _) {
          if (provider.currentPlan == null) return const SizedBox.shrink();
          return _buildFab(context, isDark);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('meal_planner_title'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                Text(
                  context.tr('meal_planner_subtitle'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const GroceryListScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGlowGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.accentBlue.withOpacity(0.15)
                    : AppTheme.accentBlueSoft,
                shape: BoxShape.circle,
              ),
              child: const Text('📅', style: TextStyle(fontSize: 70)),
            ),
            const SizedBox(height: 32),
            Text(
              context.tr('no_meal_plan'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('create_first_plan'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GeneratePlanScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('create_plan'),
                      style: const TextStyle(
                        fontSize: 17,
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
      ),
    );
  }

  Widget _buildPlanContent(PlannerProvider provider, bool isDark) {
    final plan = provider.currentPlan!;

    return RefreshIndicator(
      onRefresh: () => provider.loadCurrentWeekPlan(),
      color: AppTheme.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card d'info du plan
            _buildPlanInfoCard(plan, isDark),

            // Bouton générer liste de courses
            _buildGenerateGroceryButton(provider, isDark),

            // Liste des jours
            ...plan.dailyMeals.map((day) => _buildDayCard(day, isDark)),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfoCard(MealPlan plan, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.blueGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('📋', style: TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (plan.planType?.toUpperCase() == 'WEEKLY') ? context.tr('weekly').toUpperCase() : (plan.planType ?? context.tr('weekly').toUpperCase()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.dietType != null
                          ? (Constants.dietTypes[plan.dietType] ?? plan.dietType ?? context.tr('balanced_plan'))
                          : context.tr('balanced_plan'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton de suppression du plan
              GestureDetector(
                onTap: () => _showDeletePlanDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${DateFormatter.formatShort(DateTime.parse(plan.startDate))} - ${DateFormatter.formatShort(DateTime.parse(plan.endDate))}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.totalCalories.toInt()} cal',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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

  void _showDeletePlanDialog(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              context.tr('delete_plan'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr('delete_plan_confirm'),
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              context.tr('cancel'),
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Sauvegarder les traductions AVANT le pop et l'await (utiliser trStatic pour éviter l'erreur Provider)
              final successMsg = context.trStatic('meal_deleted');
              final errorMsg = context.trStatic('error');
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final provider = context.read<PlannerProvider>();

              Navigator.pop(dialogContext);
              final success = await provider.deleteMealPlan();

              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.error_outline,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(success ? successMsg : errorMsg),
                      ],
                    ),
                    backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(IconData icon, String value) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateGroceryButton(PlannerProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () async {
          final success = await provider.generateGroceryListFromPlan();
          if (success && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GroceryListScreen()),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGlowGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                context.tr('generate_grocery_list'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (provider.isLoading) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(DailyMeal dailyMeal, bool isDark) {
    final date = DateTime.parse(dailyMeal.date);
    final meals = dailyMeal.getAllMeals();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.tealGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateFormatter.getDayAbbr(date),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatWithDay(date),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${meals.length} repas',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Divider(
              color: isDark ? AppTheme.darkDivider : AppTheme.surfaceGrey,
              height: 1,
            ),
            ...meals.map((mealItem) => _buildMealItemTile(mealItem, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItemTile(MealItem mealItem, bool isDark) {
    final mealTypeColor = _getMealTypeColor(mealItem.mealType);
    final hasImage = mealItem.recipeImage != null && mealItem.recipeImage!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Image de recette ou icône par défaut
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: hasImage ? null : mealTypeColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(14),
              boxShadow: hasImage ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    mealItem.recipeImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        _getMealTypeIcon(mealItem.mealType),
                        color: mealTypeColor,
                        size: 28,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(mealTypeColor),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      _getMealTypeIcon(mealItem.mealType),
                      color: mealTypeColor,
                      size: 28,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Info du repas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealItem.recipeName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: mealTypeColor.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMealTypeName(mealItem.mealType),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: mealTypeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${mealItem.calories.toInt()} cal',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Boutons d'action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton ajouter aux repas consommés
              GestureDetector(
                onTap: () => _showAddToConsumedDialog(context, mealItem, isDark),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryGreen,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Menu contextuel (supprimer, etc.)
              GestureDetector(
                onTap: () => _showMealOptionsMenu(context, mealItem, isDark),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMealOptionsMenu(BuildContext context, MealItem mealItem, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              mealItem.recipeName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Option: Marquer comme consommé
            _buildMenuOption(
              icon: Icons.check_circle,
              color: AppTheme.successGreen,
              title: 'Marquer comme consommé',
              onTap: () {
                Navigator.pop(context);
                _showAddToConsumedDialog(context, mealItem, isDark);
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Option: Supprimer du plan
            if (mealItem.id != null)
              _buildMenuOption(
                icon: Icons.delete_outline,
                color: AppTheme.errorRed,
                title: 'Supprimer du plan',
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteMealFromPlan(mealItem);
                },
                isDark: isDark,
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMealFromPlan(MealItem mealItem) async {
    if (mealItem.id == null) return;

    final provider = context.read<PlannerProvider>();
    final success = await provider.removeMealFromPlan(mealItem.id!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  success
                      ? '${mealItem.recipeName} supprimé du plan'
                      : 'Erreur lors de la suppression',
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showAddToConsumedDialog(BuildContext context, MealItem mealItem, bool isDark) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    // Définir une heure par défaut selon le type de repas
    switch (mealItem.mealType.toUpperCase()) {
      case 'BREAKFAST':
        selectedTime = const TimeOfDay(hour: 8, minute: 0);
        break;
      case 'LUNCH':
        selectedTime = const TimeOfDay(hour: 12, minute: 30);
        break;
      case 'DINNER':
        selectedTime = const TimeOfDay(hour: 19, minute: 30);
        break;
      case 'SNACK':
        selectedTime = const TimeOfDay(hour: 16, minute: 0);
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateur de glissement
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkBorder : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Titre
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGlowGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ajouter aux repas consommés',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Suivre ce repas dans votre journal',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info du repas
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceLight : AppTheme.surfaceGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getMealTypeColor(mealItem.mealType).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getMealTypeIcon(mealItem.mealType),
                            color: _getMealTypeColor(mealItem.mealType),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealItem.recipeName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department, size: 14, color: AppTheme.secondaryOrange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${mealItem.calories.toInt()} cal',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${mealItem.servings} portion(s)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sélecteur de date
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 7)),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceLight : AppTheme.surfaceGrey,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            DateFormatter.formatForDisplay(selectedDate),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sélecteur d'heure
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceLight : AppTheme.surfaceGrey,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppTheme.primaryGreen,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            selectedTime.format(context),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton d'ajout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addMealToConsumed(
                        context,
                        mealItem,
                        selectedDate,
                        selectedTime,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Ajouter au journal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addMealToConsumed(
    BuildContext context,
    MealItem mealItem,
    DateTime date,
    TimeOfDay time,
  ) async {
    // Sauvegarder les références avant de pop le contexte
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final mealProvider = context.read<MealProvider>();

    Navigator.pop(context); // Fermer le bottom sheet

    // Debug log
    debugPrint('🍽️ Adding meal to consumed: ${mealItem.recipeName}');
    debugPrint('📅 Date: ${DateFormatter.formatForApi(date)}, Type: ${mealItem.mealType}');

    // Utiliser les macros du repas planifié si disponibles, sinon estimer
    final totalCalories = mealItem.calories;
    final protein = mealItem.protein ?? (totalCalories * 0.20) / 4;
    final carbs = mealItem.carbs ?? (totalCalories * 0.50) / 4;
    final fat = mealItem.fat ?? (totalCalories * 0.30) / 9;

    // Construire les données du repas (sans 'time' pour éviter les erreurs de parsing)
    final mealData = {
      'date': DateFormatter.formatForApi(date),
      'mealType': mealItem.mealType,
      'source': 'MEAL_PLAN',
      'items': [
        {
          'foodName': mealItem.recipeName,
          'apiSource': 'EDAMAM',
          'quantity': mealItem.servings * 100.0,
          'servingUnit': 'g',
          'calories': totalCalories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
        }
      ],
    };

    debugPrint('📤 Meal data: $mealData');

    final success = await mealProvider.createMeal(mealData);
    final errorMsg = mealProvider.error;

    if (success) {
      debugPrint('✅ Meal added to consumed successfully');
    } else {
      debugPrint('❌ Failed to add meal to consumed: $errorMsg');
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Repas ajouté à votre journal du ${DateFormatter.formatForDisplay(date)}'
                    : 'Erreur: ${errorMsg ?? "Échec de l\'ajout"}',
              ),
            ),
          ],
        ),
        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildFab(BuildContext context, bool isDark) {
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
        heroTag: 'planner_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const GeneratePlanScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          context.tr('new_plan'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST': return AppTheme.secondaryOrange;
      case 'LUNCH': return AppTheme.primaryGreen;
      case 'DINNER': return AppTheme.accentPurple;
      case 'SNACK': return AppTheme.accentTeal;
      default: return AppTheme.textMedium;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST': return Icons.free_breakfast_rounded;
      case 'LUNCH': return Icons.lunch_dining_rounded;
      case 'DINNER': return Icons.dinner_dining_rounded;
      case 'SNACK': return Icons.icecream_rounded;
      default: return Icons.restaurant_rounded;
    }
  }

  String _getMealTypeName(String mealType) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST': return 'PETIT-DÉJ';
      case 'LUNCH': return 'DÉJEUNER';
      case 'DINNER': return 'DÎNER';
      case 'SNACK': return 'COLLATION';
      default: return mealType;
    }
  }
}

