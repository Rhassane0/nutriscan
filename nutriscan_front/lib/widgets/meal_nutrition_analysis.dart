import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/meal.dart';

/// Widget d'analyse nutritionnelle pour un repas
class MealNutritionAnalysis extends StatelessWidget {
  final Meal meal;
  final bool showDetails;
  final bool isDark;

  const MealNutritionAnalysis({
    super.key,
    required this.meal,
    this.showDetails = true,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final analysis = _analyzeMeal();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.darkSurfaceLight, AppTheme.darkSurface]
              : [Colors.white, const Color(0xFFFAFAFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor(analysis.score).withAlpha(isDark ? 77 : 51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec score
          Row(
            children: [
              _buildScoreBadge(analysis.score),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyse nutritionnelle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      analysis.summary,
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

          if (showDetails) ...[
            const SizedBox(height: 16),

            // Barres de répartition des macros
            _buildMacroDistribution(analysis),

            const SizedBox(height: 16),

            // Points forts et points faibles
            if (analysis.strengths.isNotEmpty || analysis.weaknesses.isNotEmpty) ...[
              _buildInsights(analysis),
            ],

            // Recommandations
            if (analysis.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRecommendations(analysis),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    final color = _getScoreColor(score);
    final emoji = _getScoreEmoji(score);

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(102),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDistribution(MealAnalysis analysis) {
    final total = analysis.proteinPercent + analysis.carbsPercent + analysis.fatPercent;
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartition des macros',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Expanded(
                  flex: analysis.proteinPercent.round(),
                  child: Container(color: AppTheme.proteinColor),
                ),
                Expanded(
                  flex: analysis.carbsPercent.round(),
                  child: Container(color: AppTheme.carbsColor),
                ),
                Expanded(
                  flex: analysis.fatPercent.round(),
                  child: Container(color: AppTheme.fatColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMacroLabel('Protéines', analysis.proteinPercent, AppTheme.proteinColor),
            _buildMacroLabel('Glucides', analysis.carbsPercent, AppTheme.carbsColor),
            _buildMacroLabel('Lipides', analysis.fatPercent, AppTheme.fatColor),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroLabel(String name, double percent, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(MealAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (analysis.strengths.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.strengths.map((s) => _buildInsightChip(s, true)).toList(),
          ),
        ],
        if (analysis.weaknesses.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.weaknesses.map((w) => _buildInsightChip(w, false)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightChip(String text, bool isStrength) {
    final color = isStrength ? AppTheme.primaryGreen : AppTheme.warningYellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 51 : 26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStrength ? Icons.check_circle : Icons.info,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(MealAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withAlpha(isDark ? 26 : 13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 16, color: AppTheme.accentBlue),
              const SizedBox(width: 6),
              Text(
                'Recommandation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            analysis.recommendations.first,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  MealAnalysis _analyzeMeal() {
    final calories = meal.totalCalories;
    final protein = meal.totalProtein;
    final carbs = meal.totalCarbs;
    final fat = meal.totalFat;

    // Calcul des pourcentages de macros
    final totalMacros = protein + carbs + fat;
    final proteinPercent = totalMacros > 0 ? (protein / totalMacros) * 100 : 0.0;
    final carbsPercent = totalMacros > 0 ? (carbs / totalMacros) * 100 : 0.0;
    final fatPercent = totalMacros > 0 ? (fat / totalMacros) * 100 : 0.0;

    // Évaluation du score (0-100)
    int score = 50;
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];

    // Analyse des protéines (idéal: 20-35%)
    if (proteinPercent >= 20 && proteinPercent <= 35) {
      score += 15;
      strengths.add('Bon apport en protéines');
    } else if (proteinPercent < 15) {
      score -= 10;
      weaknesses.add('Protéines insuffisantes');
      recommendations.add('Ajoutez une source de protéines comme du poulet, du poisson ou des légumineuses.');
    } else if (proteinPercent > 40) {
      score -= 5;
      weaknesses.add('Excès de protéines');
    }

    // Analyse des glucides (idéal: 40-55%)
    if (carbsPercent >= 40 && carbsPercent <= 55) {
      score += 10;
      strengths.add('Glucides équilibrés');
    } else if (carbsPercent > 65) {
      score -= 10;
      weaknesses.add('Trop de glucides');
      recommendations.add('Réduisez les glucides simples et privilégiez les légumes.');
    } else if (carbsPercent < 30) {
      score -= 5;
      weaknesses.add('Glucides faibles');
    }

    // Analyse des lipides (idéal: 20-35%)
    if (fatPercent >= 20 && fatPercent <= 35) {
      score += 10;
      strengths.add('Lipides bien dosés');
    } else if (fatPercent > 40) {
      score -= 10;
      weaknesses.add('Trop de graisses');
      recommendations.add('Réduisez les graisses saturées et privilégiez les graisses insaturées.');
    } else if (fatPercent < 15) {
      score -= 5;
      weaknesses.add('Lipides insuffisants');
    }

    // Analyse des calories selon le type de repas
    final mealType = meal.mealType.toUpperCase();
    final idealCalories = _getIdealCaloriesForMeal(mealType);

    if (calories >= idealCalories * 0.8 && calories <= idealCalories * 1.2) {
      score += 15;
      strengths.add('Calories adaptées');
    } else if (calories > idealCalories * 1.5) {
      score -= 10;
      weaknesses.add('Repas trop calorique');
      recommendations.add('Ce repas est très calorique. Réduisez les portions.');
    } else if (calories < idealCalories * 0.5) {
      score -= 5;
      weaknesses.add('Repas léger');
    }

    // Limite le score entre 0 et 100
    score = score.clamp(0, 100);

    // Génère le résumé
    String summary;
    if (score >= 80) {
      summary = 'Excellent équilibre nutritionnel';
    } else if (score >= 60) {
      summary = 'Bon repas avec quelques ajustements possibles';
    } else if (score >= 40) {
      summary = 'Repas déséquilibré, améliorations suggérées';
    } else {
      summary = 'Ce repas nécessite des améliorations';
    }

    return MealAnalysis(
      score: score,
      summary: summary,
      proteinPercent: proteinPercent,
      carbsPercent: carbsPercent,
      fatPercent: fatPercent,
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations,
    );
  }

  double _getIdealCaloriesForMeal(String mealType) {
    switch (mealType) {
      case 'BREAKFAST':
        return 400;
      case 'LUNCH':
        return 600;
      case 'DINNER':
        return 500;
      case 'SNACK':
        return 200;
      default:
        return 400;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.primaryGreen;
    if (score >= 60) return AppTheme.accentTeal;
    if (score >= 40) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }

  String _getScoreEmoji(int score) {
    if (score >= 80) return '🌟';
    if (score >= 60) return '👍';
    if (score >= 40) return '⚠️';
    return '⚡';
  }
}

class MealAnalysis {
  final int score;
  final String summary;
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;

  MealAnalysis({
    required this.score,
    required this.summary,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
  });
}

/// Widget compact pour afficher l'analyse dans une liste
class MealNutritionBadge extends StatelessWidget {
  final Meal meal;
  final bool isDark;

  const MealNutritionBadge({
    super.key,
    required this.meal,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(200)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getScoreEmoji(score), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateScore() {
    final protein = meal.totalProtein;
    final carbs = meal.totalCarbs;
    final fat = meal.totalFat;
    final totalMacros = protein + carbs + fat;

    if (totalMacros == 0) return 50;

    final proteinPercent = (protein / totalMacros) * 100;
    final carbsPercent = (carbs / totalMacros) * 100;
    final fatPercent = (fat / totalMacros) * 100;

    int score = 50;

    if (proteinPercent >= 20 && proteinPercent <= 35) score += 15;
    if (carbsPercent >= 40 && carbsPercent <= 55) score += 10;
    if (fatPercent >= 20 && fatPercent <= 35) score += 10;

    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.primaryGreen;
    if (score >= 60) return AppTheme.accentTeal;
    if (score >= 40) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }

  String _getScoreEmoji(int score) {
    if (score >= 80) return '🌟';
    if (score >= 60) return '👍';
    if (score >= 40) return '⚠️';
    return '⚡';
  }
}

