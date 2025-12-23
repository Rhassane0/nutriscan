import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Widget futuriste d'affichage des informations nutritionnelles détaillées
class DetailedNutritionPanel extends StatefulWidget {
  final NutritionData nutrition;
  final bool isDark;
  final bool isExpanded;
  final String? title;

  const DetailedNutritionPanel({
    super.key,
    required this.nutrition,
    this.isDark = true,
    this.isExpanded = false,
    this.title,
  });

  @override
  State<DetailedNutritionPanel> createState() => _DetailedNutritionPanelState();
}

class _DetailedNutritionPanelState extends State<DetailedNutritionPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isExpanded = false;
  int _selectedCategory = 0;

  final List<String> _categories = ['Macros', 'Vitamines', 'Minéraux', 'Autres'];

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [const Color(0xFF1A2F2A), const Color(0xFF0D1F1B)]
              : [Colors.white, const Color(0xFFF5F9F8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildEnergyOrb(),
          _buildCategorySelector(),
          _buildNutrientGrid(),
          if (_isExpanded) _buildDetailedAnalysis(),
          _buildExpandButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? 'Analyse Nutritionnelle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: widget.isDark ? Colors.white : AppTheme.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Informations détaillées pour 100g',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark ? Colors.white60 : AppTheme.textMedium,
                  ),
                ),
              ],
            ),
          ),
          _buildQualityIndicator(),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator() {
    final score = _calculateNutritionScore();
    final color = score >= 70 ? AppTheme.successGreen
        : score >= 40 ? AppTheme.warningYellow : AppTheme.errorRed;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnergyOrb() {
    final calories = widget.nutrition.calories ?? 0;
    final dailyPercent = (calories / 2000 * 100).clamp(0.0, 100.0);

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circles
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 150 + (index * 30) * _pulseAnimation.value,
                  height: 150 + (index * 30) * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.1 - index * 0.03),
                      width: 2,
                    ),
                  ),
                );
              },
            );
          }),
          // Central orb
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.caloriesColor.withOpacity(0.8),
                  AppTheme.caloriesColor.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDark ? const Color(0xFF0D1F1B) : Colors.white,
                border: Border.all(
                  color: AppTheme.caloriesColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.caloriesColor.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    calories.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.caloriesColor,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white60 : AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Macro orbs
          ..._buildMacroOrbs(),
        ],
      ),
    );
  }

  List<Widget> _buildMacroOrbs() {
    final macros = [
      {'label': 'Protéines', 'value': widget.nutrition.proteins, 'color': AppTheme.proteinColor, 'angle': -60.0},
      {'label': 'Glucides', 'value': widget.nutrition.carbs, 'color': AppTheme.carbsColor, 'angle': 60.0},
      {'label': 'Lipides', 'value': widget.nutrition.fats, 'color': AppTheme.fatColor, 'angle': 180.0},
    ];

    return macros.map((macro) {
      final angle = (macro['angle'] as double) * math.pi / 180;
      final radius = 85.0;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      return Positioned(
        left: 100 + x - 30,
        top: 100 + y - 30,
        child: _buildMiniMacroOrb(
          macro['label'] as String,
          macro['value'] as double?,
          macro['color'] as Color,
        ),
      );
    }).toList();
  }

  Widget _buildMiniMacroOrb(String label, double? value, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isDark ? const Color(0xFF1A2F2A) : Colors.white,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value?.toStringAsFixed(0) ?? '-',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            'g',
            style: TextStyle(
              fontSize: 9,
              color: widget.isDark ? Colors.white60 : AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategory == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.accentTeal])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _categories[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (widget.isDark ? Colors.white60 : AppTheme.textMedium),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNutrientGrid() {
    final nutrients = _getNutrientsForCategory();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: nutrients.length,
        itemBuilder: (context, index) {
          return _buildNutrientCard(nutrients[index]);
        },
      ),
    );
  }

  Widget _buildNutrientCard(Map<String, dynamic> nutrient) {
    final value = nutrient['value'] as double?;
    final dailyValue = nutrient['dailyValue'] as double;
    final percentage = value != null ? (value / dailyValue * 100).clamp(0.0, 100.0) : 0.0;
    final color = nutrient['color'] as Color;

    Color progressColor;
    if (percentage < 30) {
      progressColor = AppTheme.warningYellow;
    } else if (percentage > 100) {
      progressColor = AppTheme.errorRed;
    } else {
      progressColor = AppTheme.successGreen;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      nutrient['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark ? Colors.white70 : AppTheme.textMedium,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value?.toStringAsFixed(1) ?? '-',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                nutrient['unit'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: widget.isDark ? Colors.white.withOpacity(0.5) : AppTheme.textLight,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: widget.isDark ? Colors.white10 : Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getNutrientsForCategory() {
    final n = widget.nutrition;

    switch (_selectedCategory) {
      case 0: // Macros
        return [
          {'label': 'Protéines', 'value': n.proteins, 'unit': 'g', 'dailyValue': 50.0, 'color': AppTheme.proteinColor},
          {'label': 'Glucides', 'value': n.carbs, 'unit': 'g', 'dailyValue': 260.0, 'color': AppTheme.carbsColor},
          {'label': 'Lipides', 'value': n.fats, 'unit': 'g', 'dailyValue': 70.0, 'color': AppTheme.fatColor},
          {'label': 'Fibres', 'value': n.fiber, 'unit': 'g', 'dailyValue': 25.0, 'color': AppTheme.accentTeal},
          {'label': 'Sucres', 'value': n.sugars, 'unit': 'g', 'dailyValue': 50.0, 'color': const Color(0xFFE91E63)},
          {'label': 'Graisses sat.', 'value': n.saturatedFat, 'unit': 'g', 'dailyValue': 20.0, 'color': const Color(0xFFFF5722)},
          {'label': 'Sel', 'value': n.salt, 'unit': 'g', 'dailyValue': 6.0, 'color': const Color(0xFF9E9E9E)},
          {'label': 'Cholestérol', 'value': n.cholesterol, 'unit': 'mg', 'dailyValue': 300.0, 'color': const Color(0xFF795548)},
        ];
      case 1: // Vitamines
        return [
          {'label': 'Vitamine A', 'value': n.vitaminA, 'unit': 'µg', 'dailyValue': 800.0, 'color': const Color(0xFFFF9800)},
          {'label': 'Vitamine C', 'value': n.vitaminC, 'unit': 'mg', 'dailyValue': 80.0, 'color': const Color(0xFFFFEB3B)},
          {'label': 'Vitamine D', 'value': n.vitaminD, 'unit': 'µg', 'dailyValue': 5.0, 'color': const Color(0xFFFFC107)},
          {'label': 'Vitamine E', 'value': n.vitaminE, 'unit': 'mg', 'dailyValue': 12.0, 'color': const Color(0xFF8BC34A)},
          {'label': 'Vitamine K', 'value': n.vitaminK, 'unit': 'µg', 'dailyValue': 75.0, 'color': const Color(0xFF4CAF50)},
          {'label': 'Vitamine B1', 'value': n.vitaminB1, 'unit': 'mg', 'dailyValue': 1.1, 'color': const Color(0xFF00BCD4)},
          {'label': 'Vitamine B6', 'value': n.vitaminB6, 'unit': 'mg', 'dailyValue': 1.4, 'color': const Color(0xFF03A9F4)},
          {'label': 'Vitamine B12', 'value': n.vitaminB12, 'unit': 'µg', 'dailyValue': 2.5, 'color': const Color(0xFFE91E63)},
        ];
      case 2: // Minéraux
        return [
          {'label': 'Calcium', 'value': n.calcium, 'unit': 'mg', 'dailyValue': 800.0, 'color': const Color(0xFFECEFF1)},
          {'label': 'Fer', 'value': n.iron, 'unit': 'mg', 'dailyValue': 14.0, 'color': const Color(0xFF8D6E63)},
          {'label': 'Magnésium', 'value': n.magnesium, 'unit': 'mg', 'dailyValue': 375.0, 'color': const Color(0xFF9C27B0)},
          {'label': 'Potassium', 'value': n.potassium, 'unit': 'mg', 'dailyValue': 2000.0, 'color': const Color(0xFFFF5722)},
          {'label': 'Sodium', 'value': n.sodium, 'unit': 'mg', 'dailyValue': 2400.0, 'color': const Color(0xFF607D8B)},
          {'label': 'Zinc', 'value': n.zinc, 'unit': 'mg', 'dailyValue': 10.0, 'color': const Color(0xFF78909C)},
          {'label': 'Phosphore', 'value': n.phosphorus, 'unit': 'mg', 'dailyValue': 700.0, 'color': const Color(0xFF3F51B5)},
          {'label': 'Sélénium', 'value': n.selenium, 'unit': 'µg', 'dailyValue': 55.0, 'color': const Color(0xFF673AB7)},
        ];
      case 3: // Autres
        return [
          {'label': 'Oméga-3', 'value': n.omega3, 'unit': 'g', 'dailyValue': 2.0, 'color': const Color(0xFF2196F3)},
          {'label': 'Oméga-6', 'value': n.omega6, 'unit': 'g', 'dailyValue': 10.0, 'color': const Color(0xFF00BCD4)},
          {'label': 'Gr. mono-insat.', 'value': n.monounsaturatedFat, 'unit': 'g', 'dailyValue': 20.0, 'color': const Color(0xFF4CAF50)},
          {'label': 'Gr. poly-insat.', 'value': n.polyunsaturatedFat, 'unit': 'g', 'dailyValue': 11.0, 'color': const Color(0xFF8BC34A)},
          {'label': 'Amidon', 'value': n.starch, 'unit': 'g', 'dailyValue': 150.0, 'color': const Color(0xFFFFC107)},
          {'label': 'Alcool', 'value': n.alcohol, 'unit': 'g', 'dailyValue': 20.0, 'color': const Color(0xFFFF5722)},
          {'label': 'Caféine', 'value': n.caffeine, 'unit': 'mg', 'dailyValue': 400.0, 'color': const Color(0xFF795548)},
          {'label': 'Eau', 'value': n.water, 'unit': 'g', 'dailyValue': 2500.0, 'color': const Color(0xFF03A9F4)},
        ];
      default:
        return [];
    }
  }

  Widget _buildDetailedAnalysis() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.1),
            AppTheme.primaryGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Analyse IA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._buildInsights(),
        ],
      ),
    );
  }

  List<Widget> _buildInsights() {
    final insights = <Widget>[];
    final n = widget.nutrition;

    // Protéines
    if (n.proteins != null) {
      if (n.proteins! > 20) {
        insights.add(_buildInsightRow('✅', 'Excellente source de protéines'));
      } else if (n.proteins! < 5) {
        insights.add(_buildInsightRow('⚠️', 'Faible en protéines'));
      }
    }

    // Fibres
    if (n.fiber != null) {
      if (n.fiber! > 6) {
        insights.add(_buildInsightRow('✅', 'Riche en fibres - bon pour la digestion'));
      } else if (n.fiber! < 2) {
        insights.add(_buildInsightRow('💡', 'Ajoutez des légumes pour plus de fibres'));
      }
    }

    // Sucres
    if (n.sugars != null && n.sugars! > 15) {
      insights.add(_buildInsightRow('⚠️', 'Attention: teneur élevée en sucres'));
    }

    // Graisses saturées
    if (n.saturatedFat != null && n.saturatedFat! > 5) {
      insights.add(_buildInsightRow('⚠️', 'Riche en graisses saturées'));
    }

    // Sodium
    if (n.sodium != null && n.sodium! > 600) {
      insights.add(_buildInsightRow('⚠️', 'Teneur élevée en sodium'));
    }

    // Vitamines
    if (n.vitaminC != null && n.vitaminC! > 40) {
      insights.add(_buildInsightRow('✅', 'Bonne source de vitamine C'));
    }

    if (insights.isEmpty) {
      insights.add(_buildInsightRow('ℹ️', 'Profil nutritionnel équilibré'));
    }

    return insights;
  }

  Widget _buildInsightRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: widget.isDark ? Colors.white70 : AppTheme.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isExpanded ? 'Réduire' : 'Voir plus',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateNutritionScore() {
    int score = 50;
    final n = widget.nutrition;

    // Positive factors
    if (n.proteins != null && n.proteins! > 10) score += 10;
    if (n.fiber != null && n.fiber! > 3) score += 10;
    if (n.vitaminC != null && n.vitaminC! > 20) score += 5;
    if (n.calcium != null && n.calcium! > 100) score += 5;
    if (n.iron != null && n.iron! > 2) score += 5;

    // Negative factors
    if (n.sugars != null && n.sugars! > 15) score -= 15;
    if (n.saturatedFat != null && n.saturatedFat! > 5) score -= 10;
    if (n.sodium != null && n.sodium! > 600) score -= 10;
    if (n.cholesterol != null && n.cholesterol! > 100) score -= 5;

    return score.clamp(0, 100);
  }
}

/// Modèle de données nutritionnelles complet
class NutritionData {
  // Macronutriments
  final double? calories;
  final double? proteins;
  final double? carbs;
  final double? fats;
  final double? fiber;
  final double? sugars;
  final double? saturatedFat;
  final double? monounsaturatedFat;
  final double? polyunsaturatedFat;
  final double? transFat;
  final double? cholesterol;
  final double? salt;
  final double? sodium;

  // Vitamines
  final double? vitaminA;
  final double? vitaminC;
  final double? vitaminD;
  final double? vitaminE;
  final double? vitaminK;
  final double? vitaminB1;
  final double? vitaminB2;
  final double? vitaminB3;
  final double? vitaminB5;
  final double? vitaminB6;
  final double? vitaminB9;
  final double? vitaminB12;

  // Minéraux
  final double? calcium;
  final double? iron;
  final double? magnesium;
  final double? potassium;
  final double? zinc;
  final double? phosphorus;
  final double? selenium;
  final double? copper;
  final double? manganese;
  final double? iodine;

  // Autres
  final double? omega3;
  final double? omega6;
  final double? starch;
  final double? alcohol;
  final double? caffeine;
  final double? water;

  const NutritionData({
    this.calories,
    this.proteins,
    this.carbs,
    this.fats,
    this.fiber,
    this.sugars,
    this.saturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.transFat,
    this.cholesterol,
    this.salt,
    this.sodium,
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.vitaminB1,
    this.vitaminB2,
    this.vitaminB3,
    this.vitaminB5,
    this.vitaminB6,
    this.vitaminB9,
    this.vitaminB12,
    this.calcium,
    this.iron,
    this.magnesium,
    this.potassium,
    this.zinc,
    this.phosphorus,
    this.selenium,
    this.copper,
    this.manganese,
    this.iodine,
    this.omega3,
    this.omega6,
    this.starch,
    this.alcohol,
    this.caffeine,
    this.water,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: _parseDouble(json['calories'] ?? json['energy'] ?? json['ENERC_KCAL']),
      proteins: _parseDouble(json['proteins'] ?? json['protein'] ?? json['PROCNT']),
      carbs: _parseDouble(json['carbs'] ?? json['carbohydrates'] ?? json['CHOCDF']),
      fats: _parseDouble(json['fats'] ?? json['fat'] ?? json['FAT']),
      fiber: _parseDouble(json['fiber'] ?? json['FIBTG']),
      sugars: _parseDouble(json['sugars'] ?? json['sugar'] ?? json['SUGAR']),
      saturatedFat: _parseDouble(json['saturatedFat'] ?? json['saturated_fat'] ?? json['FASAT']),
      monounsaturatedFat: _parseDouble(json['monounsaturatedFat'] ?? json['FAMS']),
      polyunsaturatedFat: _parseDouble(json['polyunsaturatedFat'] ?? json['FAPU']),
      transFat: _parseDouble(json['transFat'] ?? json['FATRN']),
      cholesterol: _parseDouble(json['cholesterol'] ?? json['CHOLE']),
      salt: _parseDouble(json['salt']),
      sodium: _parseDouble(json['sodium'] ?? json['NA']),
      vitaminA: _parseDouble(json['vitaminA'] ?? json['VITA_RAE']),
      vitaminC: _parseDouble(json['vitaminC'] ?? json['VITC']),
      vitaminD: _parseDouble(json['vitaminD'] ?? json['VITD']),
      vitaminE: _parseDouble(json['vitaminE'] ?? json['TOCPHA']),
      vitaminK: _parseDouble(json['vitaminK'] ?? json['VITK1']),
      vitaminB1: _parseDouble(json['vitaminB1'] ?? json['THIA']),
      vitaminB2: _parseDouble(json['vitaminB2'] ?? json['RIBF']),
      vitaminB3: _parseDouble(json['vitaminB3'] ?? json['NIA']),
      vitaminB5: _parseDouble(json['vitaminB5'] ?? json['PANTAC']),
      vitaminB6: _parseDouble(json['vitaminB6'] ?? json['VITB6A']),
      vitaminB9: _parseDouble(json['vitaminB9'] ?? json['FOLDFE']),
      vitaminB12: _parseDouble(json['vitaminB12'] ?? json['VITB12']),
      calcium: _parseDouble(json['calcium'] ?? json['CA']),
      iron: _parseDouble(json['iron'] ?? json['FE']),
      magnesium: _parseDouble(json['magnesium'] ?? json['MG']),
      potassium: _parseDouble(json['potassium'] ?? json['K']),
      zinc: _parseDouble(json['zinc'] ?? json['ZN']),
      phosphorus: _parseDouble(json['phosphorus'] ?? json['P']),
      selenium: _parseDouble(json['selenium'] ?? json['SE']),
      copper: _parseDouble(json['copper'] ?? json['CU']),
      manganese: _parseDouble(json['manganese'] ?? json['MN']),
      iodine: _parseDouble(json['iodine']),
      omega3: _parseDouble(json['omega3']),
      omega6: _parseDouble(json['omega6']),
      starch: _parseDouble(json['starch'] ?? json['STARCH']),
      alcohol: _parseDouble(json['alcohol'] ?? json['ALC']),
      caffeine: _parseDouble(json['caffeine'] ?? json['CAFFN']),
      water: _parseDouble(json['water'] ?? json['WATER']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is Map) return _parseDouble(value['quantity']);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'sugars': sugars,
      'saturatedFat': saturatedFat,
      'monounsaturatedFat': monounsaturatedFat,
      'polyunsaturatedFat': polyunsaturatedFat,
      'transFat': transFat,
      'cholesterol': cholesterol,
      'salt': salt,
      'sodium': sodium,
      'vitaminA': vitaminA,
      'vitaminC': vitaminC,
      'vitaminD': vitaminD,
      'vitaminE': vitaminE,
      'vitaminK': vitaminK,
      'vitaminB1': vitaminB1,
      'vitaminB2': vitaminB2,
      'vitaminB3': vitaminB3,
      'vitaminB5': vitaminB5,
      'vitaminB6': vitaminB6,
      'vitaminB9': vitaminB9,
      'vitaminB12': vitaminB12,
      'calcium': calcium,
      'iron': iron,
      'magnesium': magnesium,
      'potassium': potassium,
      'zinc': zinc,
      'phosphorus': phosphorus,
      'selenium': selenium,
      'copper': copper,
      'manganese': manganese,
      'iodine': iodine,
      'omega3': omega3,
      'omega6': omega6,
      'starch': starch,
      'alcohol': alcohol,
      'caffeine': caffeine,
      'water': water,
    };
  }
}

