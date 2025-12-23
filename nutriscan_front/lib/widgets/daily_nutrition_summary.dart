import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Widget futuriste d'affichage du résumé nutritionnel quotidien
class DailyNutritionSummary extends StatefulWidget {
  final DailySummaryData summary;
  final bool isDark;
  final VoidCallback? onTap;

  const DailyNutritionSummary({
    super.key,
    required this.summary,
    this.isDark = true,
    this.onTap,
  });

  @override
  State<DailyNutritionSummary> createState() => _DailyNutritionSummaryState();
}

class _DailyNutritionSummaryState extends State<DailyNutritionSummary>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDark
                ? [const Color(0xFF1A2F2A), const Color(0xFF0D1F1B)]
                : [Colors.white, const Color(0xFFF8FBF8)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCaloriesRing(),
            const SizedBox(height: 24),
            _buildMacrosRow(),
            const SizedBox(height: 20),
            _buildMicronutrientsGrid(),
            const SizedBox(height: 16),
            _buildInsightCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.today, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Résumé du jour',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: widget.isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.summary.mealsCount} repas enregistrés',
              style: TextStyle(
                fontSize: 13,
                color: widget.isDark ? Colors.white54 : AppTheme.textMedium,
              ),
            ),
          ],
        ),
        _buildScoreBadge(),
      ],
    );
  }

  Widget _buildScoreBadge() {
    final score = widget.summary.nutritionScore;
    final color = score >= 80 ? AppTheme.successGreen
        : score >= 60 ? AppTheme.accentTeal
        : score >= 40 ? AppTheme.warningYellow : AppTheme.errorRed;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3 + 0.2 * _glowController.value),
                blurRadius: 15 + 5 * _glowController.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Score',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaloriesRing() {
    final consumed = widget.summary.totalCalories;
    final goal = widget.summary.caloriesGoal;
    final percentage = (consumed / goal * 100).clamp(0.0, 150.0);
    final remaining = goal - consumed;

    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: widget.isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
            ),
          ),
          // Animated progress ring
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0) * _progressController.value,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 100 ? AppTheme.errorRed : AppTheme.primaryGreen,
                  ),
                ),
              );
            },
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                consumed.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: widget.isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white54 : AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (remaining >= 0 ? AppTheme.primaryGreen : AppTheme.errorRed)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  remaining >= 0
                      ? '${remaining.toStringAsFixed(0)} restantes'
                      : '${(-remaining).toStringAsFixed(0)} en excès',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: remaining >= 0 ? AppTheme.primaryGreen : AppTheme.errorRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMacroCard(
            'Protéines',
            widget.summary.totalProtein,
            widget.summary.proteinGoal,
            'g',
            AppTheme.proteinColor,
            Icons.fitness_center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMacroCard(
            'Glucides',
            widget.summary.totalCarbs,
            widget.summary.carbsGoal,
            'g',
            AppTheme.carbsColor,
            Icons.grain,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMacroCard(
            'Lipides',
            widget.summary.totalFat,
            widget.summary.fatGoal,
            'g',
            AppTheme.fatColor,
            Icons.water_drop,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, double value, double goal, String unit, Color color, IconData icon) {
    final percentage = (value / goal * 100).clamp(0.0, 100.0);

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white70 : AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                '$unit / ${goal.toStringAsFixed(0)}$unit',
                style: TextStyle(
                  fontSize: 10,
                  color: widget.isDark ? Colors.white.withOpacity(0.5) : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentage / 100) * _progressController.value,
                  backgroundColor: widget.isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMicronutrientsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: AppTheme.accentTeal, size: 18),
              const SizedBox(width: 8),
              Text(
                'Micronutriments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMicroChip('Fibres', widget.summary.totalFiber, 25, 'g', const Color(0xFF8BC34A))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Sodium', widget.summary.totalSodium, 2400, 'mg', const Color(0xFF607D8B))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Sucres', widget.summary.totalSugars, 50, 'g', const Color(0xFFE91E63))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMicroChip('Calcium', widget.summary.totalCalcium, 800, 'mg', const Color(0xFFECEFF1))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Fer', widget.summary.totalIron, 14, 'mg', const Color(0xFF8D6E63))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Vit. C', widget.summary.totalVitaminC, 80, 'mg', const Color(0xFFFFEB3B))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMicroChip('Vit. A', widget.summary.totalVitaminA, 900, 'µg', const Color(0xFFFF9800))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Vit. D', widget.summary.totalVitaminD, 20, 'µg', const Color(0xFF03A9F4))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Vit. B12', widget.summary.totalVitaminB12, 2.4, 'µg', const Color(0xFF9C27B0))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMicroChip('Potassium', widget.summary.totalPotassium, 3500, 'mg', const Color(0xFF4CAF50))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Magnésium', widget.summary.totalMagnesium, 400, 'mg', const Color(0xFF00BCD4))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Zinc', widget.summary.totalZinc, 11, 'mg', const Color(0xFF795548))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMicroChip('Cholest.', widget.summary.totalCholesterol, 300, 'mg', const Color(0xFFFF5722))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Sat. Fat', widget.summary.totalSaturatedFat, 20, 'g', const Color(0xFFF44336))),
              const SizedBox(width: 8),
              Expanded(child: _buildMicroChip('Omega-3', widget.summary.totalOmega3, 1.6, 'g', const Color(0xFF2196F3))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMicroChip(String label, double? value, double daily, String unit, Color color) {
    final percent = value != null ? (value / daily * 100).clamp(0.0, 100.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: widget.isDark ? Colors.white60 : AppTheme.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toStringAsFixed(0) ?? '-',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 9,
              color: widget.isDark ? Colors.white.withOpacity(0.4) : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    final insight = widget.summary.recommendation ?? _generateInsight();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.15),
            AppTheme.primaryGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lightbulb, color: AppTheme.accentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil du jour',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark ? Colors.white70 : AppTheme.textMedium,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _generateInsight() {
    final s = widget.summary;

    if (s.totalProtein < s.proteinGoal * 0.7) {
      return 'Augmentez votre apport en protéines avec du poulet, du poisson ou des légumineuses.';
    }
    if (s.totalFiber != null && s.totalFiber! < 15) {
      return 'Ajoutez plus de fibres avec des légumes verts et des céréales complètes.';
    }
    if (s.totalCalories > s.caloriesGoal * 1.2) {
      return 'Vous avez dépassé votre objectif calorique. Privilégiez les aliments légers ce soir.';
    }
    if (s.totalSugars != null && s.totalSugars! > 40) {
      return 'Attention à votre consommation de sucres. Préférez les fruits frais aux produits sucrés.';
    }
    return 'Continuez comme ça ! Votre alimentation est bien équilibrée aujourd\'hui.';
  }
}

/// Modèle de données pour le résumé quotidien
class DailySummaryData {
  final DateTime date;
  final double totalCalories;
  final double caloriesGoal;
  final double totalProtein;
  final double proteinGoal;
  final double totalCarbs;
  final double carbsGoal;
  final double totalFat;
  final double fatGoal;
  final double? totalFiber;
  final double? totalSugars;
  final double? totalSodium;
  final double? totalCalcium;
  final double? totalIron;
  final double? totalVitaminC;
  final double? totalVitaminA;
  final double? totalVitaminD;
  final double? totalVitaminE;
  final double? totalVitaminB12;
  final double? totalPotassium;
  final double? totalMagnesium;
  final double? totalZinc;
  final double? totalCholesterol;
  final double? totalSaturatedFat;
  final double? totalOmega3;
  final int nutritionScore;
  final int mealsCount;
  final String? recommendation;

  const DailySummaryData({
    required this.date,
    required this.totalCalories,
    required this.caloriesGoal,
    required this.totalProtein,
    required this.proteinGoal,
    required this.totalCarbs,
    required this.carbsGoal,
    required this.totalFat,
    required this.fatGoal,
    this.totalFiber,
    this.totalSugars,
    this.totalSodium,
    this.totalCalcium,
    this.totalIron,
    this.totalVitaminC,
    this.totalVitaminA,
    this.totalVitaminD,
    this.totalVitaminE,
    this.totalVitaminB12,
    this.totalPotassium,
    this.totalMagnesium,
    this.totalZinc,
    this.totalCholesterol,
    this.totalSaturatedFat,
    this.totalOmega3,
    required this.nutritionScore,
    required this.mealsCount,
    this.recommendation,
  });

  factory DailySummaryData.fromJson(Map<String, dynamic> json) {
    return DailySummaryData(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      caloriesGoal: (json['caloriesGoal'] as num?)?.toDouble() ?? 2000,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0,
      proteinGoal: (json['proteinGoal'] as num?)?.toDouble() ?? 50,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0,
      carbsGoal: (json['carbsGoal'] as num?)?.toDouble() ?? 260,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0,
      fatGoal: (json['fatGoal'] as num?)?.toDouble() ?? 70,
      totalFiber: (json['totalFiber'] as num?)?.toDouble(),
      totalSugars: (json['totalSugars'] as num?)?.toDouble(),
      totalSodium: (json['totalSodium'] as num?)?.toDouble(),
      totalCalcium: (json['totalCalcium'] as num?)?.toDouble(),
      totalIron: (json['totalIron'] as num?)?.toDouble(),
      totalVitaminC: (json['totalVitaminC'] as num?)?.toDouble(),
      totalVitaminA: (json['totalVitaminA'] as num?)?.toDouble(),
      totalVitaminD: (json['totalVitaminD'] as num?)?.toDouble(),
      totalVitaminE: (json['totalVitaminE'] as num?)?.toDouble(),
      totalVitaminB12: (json['totalVitaminB12'] as num?)?.toDouble(),
      totalPotassium: (json['totalPotassium'] as num?)?.toDouble(),
      totalMagnesium: (json['totalMagnesium'] as num?)?.toDouble(),
      totalZinc: (json['totalZinc'] as num?)?.toDouble(),
      totalCholesterol: (json['totalCholesterol'] as num?)?.toDouble(),
      totalSaturatedFat: (json['totalSaturatedFat'] as num?)?.toDouble(),
      totalOmega3: (json['totalOmega3'] as num?)?.toDouble(),
      nutritionScore: (json['nutritionScore'] as num?)?.toInt() ?? 50,
      mealsCount: (json['mealsCount'] as num?)?.toInt() ?? 0,
      recommendation: json['recommendation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'caloriesGoal': caloriesGoal,
      'totalProtein': totalProtein,
      'proteinGoal': proteinGoal,
      'totalCarbs': totalCarbs,
      'carbsGoal': carbsGoal,
      'totalFat': totalFat,
      'fatGoal': fatGoal,
      'totalFiber': totalFiber,
      'totalSugars': totalSugars,
      'totalSodium': totalSodium,
      'totalCalcium': totalCalcium,
      'totalIron': totalIron,
      'totalVitaminC': totalVitaminC,
      'totalVitaminA': totalVitaminA,
      'totalVitaminD': totalVitaminD,
      'totalVitaminE': totalVitaminE,
      'totalVitaminB12': totalVitaminB12,
      'totalPotassium': totalPotassium,
      'totalMagnesium': totalMagnesium,
      'totalZinc': totalZinc,
      'totalCholesterol': totalCholesterol,
      'totalSaturatedFat': totalSaturatedFat,
      'totalOmega3': totalOmega3,
      'nutritionScore': nutritionScore,
      'mealsCount': mealsCount,
      'recommendation': recommendation,
    };
  }
}

