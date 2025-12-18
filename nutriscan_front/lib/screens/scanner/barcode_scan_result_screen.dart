import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/scan_result.dart';
import '../../providers/meal_provider.dart';
import '../../utils/date_formatter.dart';

/// Écran de résultat du scan de code-barres avec design détaillé
class BarcodeScanResultScreen extends StatefulWidget {
  final ScanBarcodeResponse scanResult;

  const BarcodeScanResultScreen({super.key, required this.scanResult});

  @override
  State<BarcodeScanResultScreen> createState() => _BarcodeScanResultScreenState();
}

class _BarcodeScanResultScreenState extends State<BarcodeScanResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  int _selectedTab = 0; // 0: Overview, 1: Nutrition, 2: Details

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)),
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scoreAnimationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.scanResult;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1F1B), Color(0xFF1A3A32), Color(0xFF0F2922)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(result),
              _buildTabSelector(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: _buildTabContent(result),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.productName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (result.brand != null) ...[
                      Text(result.brand!, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
                      const SizedBox(width: 8),
                    ],
                    Text(result.barcode, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), fontFamily: 'monospace')),
                  ],
                ),
              ],
            ),
          ),
          if (result.isOrganic)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.eco, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('BIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab('Vue d\'ensemble', 0, Icons.dashboard_rounded),
          _buildTab('Nutrition', 1, Icons.restaurant_menu),
          _buildTab('Détails', 2, Icons.info_outline),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ScanBarcodeResponse result) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedTab == 0) ..._buildOverviewTab(result),
          if (_selectedTab == 1) ..._buildNutritionTab(result),
          if (_selectedTab == 2) ..._buildDetailsTab(result),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _buildOverviewTab(ScanBarcodeResponse result) {
    return [
      // Scores Section
      _buildScoresSection(result),
      const SizedBox(height: 20),

      // Health Score Card
      _buildHealthScoreCard(result),
      const SizedBox(height: 20),

      // Quick Nutrition Summary
      _buildQuickNutritionSummary(result),
      const SizedBox(height: 20),

      // AI Analysis (if available)
      if (result.aiAnalysis != null && result.aiAnalysis!.isNotEmpty) ...[
        _buildAiAnalysisSection(result),
        const SizedBox(height: 20),
      ],

      // Allergens Warning
      if (result.allergens.isNotEmpty) ...[
        _buildAllergensSection(result),
        const SizedBox(height: 20),
      ],

      // Product Info Summary
      _buildProductInfoSummary(result),
    ];
  }

  List<Widget> _buildNutritionTab(ScanBarcodeResponse result) {
    return [
      // Main Macros
      _buildMainMacrosSection(result),
      const SizedBox(height: 20),

      // Daily Value Progress
      _buildDailyValueSection(result),
      const SizedBox(height: 20),

      // Detailed Fats
      if (result.nutritionInfo.hasFatDetails) ...[
        _buildFatDetailsSection(result),
        const SizedBox(height: 20),
      ],

      // Carbs Details
      _buildCarbsDetailsSection(result),
      const SizedBox(height: 20),

      // Vitamins & Minerals
      if (result.nutritionInfo.hasVitaminsOrMinerals) ...[
        _buildVitaminsMineralsSection(result),
        const SizedBox(height: 20),
      ],

      // Other Nutrients
      _buildOtherNutrientsSection(result),
    ];
  }

  List<Widget> _buildDetailsTab(ScanBarcodeResponse result) {
    return [
      // Ingredients
      if (result.ingredients != null && result.ingredients!.isNotEmpty) ...[
        _buildIngredientsSection(result),
        const SizedBox(height: 20),
      ],

      // Additives
      if (result.additives.isNotEmpty) ...[
        _buildAdditivesSection(result),
        const SizedBox(height: 20),
      ],

      // Labels & Certifications
      if (result.labels.isNotEmpty) ...[
        _buildLabelsSection(result),
        const SizedBox(height: 20),
      ],

      // Product Details
      _buildProductDetailsSection(result),
      const SizedBox(height: 20),

      // NOVA Score Explanation
      if (result.novaScore != null) ...[
        _buildNovaExplanation(result),
      ],
    ];
  }

  Widget _buildScoresSection(ScanBarcodeResponse result) {
    return Row(
      children: [
        if (result.nutriScore != null)
          Expanded(child: _buildScoreCard('Nutri-Score', result.nutriScore!,
            AppTheme.getNutriScoreColor(result.nutriScore), Icons.health_and_safety)),
        if (result.nutriScore != null && result.ecoScore != null)
          const SizedBox(width: 12),
        if (result.ecoScore != null)
          Expanded(child: _buildScoreCard('Eco-Score', result.ecoScore!,
            AppTheme.getEcoScoreColor(result.ecoScore), Icons.eco)),
        if ((result.nutriScore != null || result.ecoScore != null) && result.novaScore != null)
          const SizedBox(width: 12),
        if (result.novaScore != null)
          Expanded(child: _buildScoreCard('NOVA', result.novaScore.toString(),
            _getNovaColor(result.novaScore!), Icons.science)),
      ],
    );
  }

  Color _getNovaColor(int score) {
    switch (score) {
      case 1: return const Color(0xFF00C853);
      case 2: return const Color(0xFFFFEB3B);
      case 3: return const Color(0xFFFF9800);
      case 4: return const Color(0xFFE53935);
      default: return Colors.grey;
    }
  }

  Widget _buildScoreCard(String label, String score, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_scoreAnimation.value * 0.2),
          child: Opacity(
            opacity: _scoreAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Center(
                      child: Text(score.toUpperCase(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthScoreCard(ScanBarcodeResponse result) {
    // Calculate a health score based on available data
    int healthScore = _calculateHealthScore(result);
    Color scoreColor = healthScore >= 70 ? AppTheme.successGreen
        : healthScore >= 40 ? AppTheme.warningYellow : AppTheme.errorRed;

    String healthLabel = healthScore >= 70 ? 'Bon choix'
        : healthScore >= 40 ? 'À consommer modérément' : 'À éviter';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.2), scoreColor.withOpacity(0.1)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [scoreColor, scoreColor.withOpacity(0.7)]),
                  boxShadow: [BoxShadow(color: scoreColor.withOpacity(0.4), blurRadius: 15)],
                ),
                child: Center(
                  child: Text('$healthScore', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score Santé', style: TextStyle(fontSize: 14, color: scoreColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(healthLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: healthScore / 100,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHealthInsights(result, scoreColor),
        ],
      ),
    );
  }

  Widget _buildHealthInsights(ScanBarcodeResponse result, Color color) {
    List<Map<String, dynamic>> insights = [];
    final nutrition = result.nutritionInfo;

    // Analyze sugar content
    if (nutrition.sugars != null) {
      if (nutrition.sugars! > 22.5) {
        insights.add({'icon': Icons.warning, 'text': 'Très riche en sucres', 'positive': false});
      } else if (nutrition.sugars! < 5) {
        insights.add({'icon': Icons.check_circle, 'text': 'Faible en sucres', 'positive': true});
      }
    }

    // Analyze salt/sodium
    if (nutrition.salt != null) {
      if (nutrition.salt! > 1.5) {
        insights.add({'icon': Icons.warning, 'text': 'Riche en sel', 'positive': false});
      } else if (nutrition.salt! < 0.3) {
        insights.add({'icon': Icons.check_circle, 'text': 'Faible en sel', 'positive': true});
      }
    }

    // Analyze fiber
    if (nutrition.fiber != null && nutrition.fiber! > 6) {
      insights.add({'icon': Icons.check_circle, 'text': 'Riche en fibres', 'positive': true});
    }

    // Analyze proteins
    if (nutrition.proteins != null && nutrition.proteins! > 20) {
      insights.add({'icon': Icons.check_circle, 'text': 'Riche en protéines', 'positive': true});
    }

    // Analyze saturated fats
    if (nutrition.saturatedFats != null && nutrition.saturatedFats! > 5) {
      insights.add({'icon': Icons.warning, 'text': 'Riche en graisses saturées', 'positive': false});
    }

    if (insights.isEmpty) {
      insights.add({'icon': Icons.info, 'text': 'Profil nutritionnel standard', 'positive': true});
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: insights.take(4).map((insight) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: insight['positive'] ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(insight['icon'], size: 14,
                color: insight['positive'] ? Colors.green : Colors.red),
              const SizedBox(width: 6),
              Text(insight['text'], style: TextStyle(fontSize: 12,
                color: insight['positive'] ? Colors.green : Colors.red, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _calculateHealthScore(ScanBarcodeResponse result) {
    int score = 50;
    final nutrition = result.nutritionInfo;

    // Nutri-Score impact
    if (result.nutriScore != null) {
      switch (result.nutriScore!.toUpperCase()) {
        case 'A': score += 30; break;
        case 'B': score += 20; break;
        case 'C': score += 0; break;
        case 'D': score -= 15; break;
        case 'E': score -= 30; break;
      }
    }

    // NOVA Score impact
    if (result.novaScore != null) {
      switch (result.novaScore) {
        case 1: score += 15; break;
        case 2: score += 5; break;
        case 3: score -= 5; break;
        case 4: score -= 15; break;
      }
    }

    // Nutritional adjustments
    if (nutrition.fiber != null && nutrition.fiber! > 3) score += 5;
    if (nutrition.proteins != null && nutrition.proteins! > 10) score += 5;
    if (nutrition.sugars != null && nutrition.sugars! > 15) score -= 10;
    if (nutrition.saturatedFats != null && nutrition.saturatedFats! > 5) score -= 10;
    if (result.isOrganic) score += 5;

    return score.clamp(0, 100);
  }

  Widget _buildQuickNutritionSummary(ScanBarcodeResponse result) {
    final nutrition = result.nutritionInfo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text('Résumé Nutritionnel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('pour 100g', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMacroMini('Calories', '${nutrition.calories?.toStringAsFixed(0) ?? '-'}', 'kcal', AppTheme.caloriesColor)),
              Expanded(child: _buildMacroMini('Protéines', '${nutrition.proteins?.toStringAsFixed(1) ?? '-'}', 'g', AppTheme.proteinColor)),
              Expanded(child: _buildMacroMini('Glucides', '${nutrition.carbs?.toStringAsFixed(1) ?? '-'}', 'g', AppTheme.carbsColor)),
              Expanded(child: _buildMacroMini('Lipides', '${nutrition.fats?.toStringAsFixed(1) ?? '-'}', 'g', AppTheme.fatColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroMini(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(unit, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildMainMacrosSection(ScanBarcodeResponse result) {
    final nutrition = result.nutritionInfo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: AppTheme.caloriesColor, size: 24),
              const SizedBox(width: 10),
              const Text('Macronutriments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Text('pour 100g', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 20),
          _buildNutrientRow('Énergie', nutrition.calories, 'kcal', AppTheme.caloriesColor, 2000),
          _buildNutrientRow('Protéines', nutrition.proteins, 'g', AppTheme.proteinColor, 50),
          _buildNutrientRow('Glucides', nutrition.carbs, 'g', AppTheme.carbsColor, 260),
          _buildNutrientRow('Lipides', nutrition.fats, 'g', AppTheme.fatColor, 70),
          _buildNutrientRow('Fibres', nutrition.fiber, 'g', AppTheme.accentTeal, 25),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, double? value, String unit, Color color, double dailyValue) {
    final percentage = value != null ? (value / dailyValue * 100).clamp(0.0, 100.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
              Row(
                children: [
                  Text(value?.toStringAsFixed(1) ?? '-', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
                  Text(' $unit', style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
                  if (value != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyValueSection(ScanBarcodeResponse result) {
    if (result.dailyValuePercentages.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.donut_large, color: AppTheme.accentPurple, size: 20),
              const SizedBox(width: 10),
              const Text('Apports Journaliers (100g)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Basé sur un régime de 2000 kcal/jour', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: result.dailyValuePercentages.entries.map((entry) {
              return _buildDailyValueChip(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyValueChip(String nutrient, double percentage) {
    String label;
    Color color;
    switch (nutrient) {
      case 'calories': label = 'Calories'; color = AppTheme.caloriesColor; break;
      case 'proteins': label = 'Protéines'; color = AppTheme.proteinColor; break;
      case 'carbs': label = 'Glucides'; color = AppTheme.carbsColor; break;
      case 'fats': label = 'Lipides'; color = AppTheme.fatColor; break;
      case 'sugars': label = 'Sucres'; color = Colors.pink; break;
      case 'fiber': label = 'Fibres'; color = AppTheme.accentTeal; break;
      case 'saturatedFats': label = 'Sat. Fat'; color = Colors.orange; break;
      case 'salt': label = 'Sel'; color = Colors.blue; break;
      default: label = nutrient; color = Colors.grey;
    }

    final isHigh = percentage > 20;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isHigh ? Colors.red.withOpacity(0.3) : color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${percentage.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isHigh ? Colors.red : color)),
          ),
        ],
      ),
    );
  }

  Widget _buildFatDetailsSection(ScanBarcodeResponse result) {
    final nutrition = result.nutritionInfo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.fatColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.fatColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppTheme.fatColor, size: 20),
              const SizedBox(width: 10),
              const Text('Détail des Lipides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Lipides totaux', nutrition.fats, 'g'),
          if (nutrition.saturatedFats != null) _buildDetailRow('  • Acides gras saturés', nutrition.saturatedFats, 'g'),
          if (nutrition.monounsaturatedFat != null) _buildDetailRow('  • Acides gras monoinsaturés', nutrition.monounsaturatedFat, 'g'),
          if (nutrition.polyunsaturatedFat != null) _buildDetailRow('  • Acides gras polyinsaturés', nutrition.polyunsaturatedFat, 'g'),
          if (nutrition.cholesterol != null) _buildDetailRow('Cholestérol', nutrition.cholesterol, 'mg'),
        ],
      ),
    );
  }

  Widget _buildCarbsDetailsSection(ScanBarcodeResponse result) {
    final nutrition = result.nutritionInfo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.carbsColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.carbsColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grain, color: AppTheme.carbsColor, size: 20),
              const SizedBox(width: 10),
              const Text('Détail des Glucides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Glucides totaux', nutrition.carbs, 'g'),
          if (nutrition.sugars != null) _buildDetailRow('  • dont sucres', nutrition.sugars, 'g'),
          if (nutrition.fiber != null) _buildDetailRow('Fibres alimentaires', nutrition.fiber, 'g'),
        ],
      ),
    );
  }

  Widget _buildVitaminsMineralsSection(ScanBarcodeResponse result) {
    final nutrition = result.nutritionInfo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C4DFF).withOpacity(0.15), const Color(0xFF7C4DFF).withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: const Color(0xFFB388FF), size: 20),
              const SizedBox(width: 10),
              const Text('Vitamines & Minéraux', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (nutrition.calcium != null) _buildVitaminChip('Calcium', '${nutrition.calcium!.toStringAsFixed(0)}mg'),
              if (nutrition.iron != null) _buildVitaminChip('Fer', '${nutrition.iron!.toStringAsFixed(1)}mg'),
              if (nutrition.potassium != null) _buildVitaminChip('Potassium', '${nutrition.potassium!.toStringAsFixed(0)}mg'),
              if (nutrition.vitaminA != null) _buildVitaminChip('Vit. A', '${nutrition.vitaminA!.toStringAsFixed(0)}µg'),
              if (nutrition.vitaminC != null) _buildVitaminChip('Vit. C', '${nutrition.vitaminC!.toStringAsFixed(0)}mg'),
              if (nutrition.vitaminD != null) _buildVitaminChip('Vit. D', '${nutrition.vitaminD!.toStringAsFixed(1)}µg'),
              if (nutrition.vitaminE != null) _buildVitaminChip('Vit. E', '${nutrition.vitaminE!.toStringAsFixed(1)}mg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFB388FF))),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildOtherNutrientsSection(ScanBarcodeResponse result) {
    final nutrition = result.nutritionInfo;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Autres Informations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          if (nutrition.salt != null) _buildDetailRow('Sel', nutrition.salt, 'g'),
          if (nutrition.sodium != null) _buildDetailRow('Sodium', nutrition.sodium, 'mg'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double? value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          Text(value != null ? '${value.toStringAsFixed(1)} $unit' : '-',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisSection(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7C4DFF).withOpacity(0.2), const Color(0xFF7C4DFF).withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF7C4DFF).withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFB388FF), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Analyse IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Text(result.aiAnalysis!, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.85), height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildAllergensSection(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.errorRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('⚠️ Allergènes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.allergens.map((allergen) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.4)),
              ),
              child: Text(allergen.replaceAll('-', ' ').toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.errorRed)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoSummary(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations Produit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          if (result.quantity != null) _buildInfoRow('Quantité', result.quantity!),
          if (result.servingSize != null) _buildInfoRow('Portion', result.servingSize!),
          if (result.origin != null) _buildInfoRow('Origine', result.origin!),
          if (result.packaging != null) _buildInfoRow('Emballage', result.packaging!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentTeal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: AppTheme.accentTeal, size: 20),
              const SizedBox(width: 10),
              const Text('Ingrédients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Text(result.ingredients!, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7), height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildAdditivesSection(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              const Text('Additifs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${result.additives.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.orange)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.additives.map((additive) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(additive, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.orange)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsSection(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 10),
              const Text('Labels & Certifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.labels.where((l) => l.isNotEmpty).take(10).map((label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsSection(ScanBarcodeResponse result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Détails du Produit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          _buildInfoRow('Code-barres', result.barcode),
          if (result.brand != null) _buildInfoRow('Marque', result.brand!),
          if (result.quantity != null) _buildInfoRow('Quantité', result.quantity!),
          if (result.servingSize != null) _buildInfoRow('Portion', result.servingSize!),
          if (result.origin != null) _buildInfoRow('Origine', result.origin!),
          if (result.packaging != null) _buildInfoRow('Emballage', result.packaging!),
        ],
      ),
    );
  }

  Widget _buildNovaExplanation(ScanBarcodeResponse result) {
    final descriptions = {
      1: 'Aliments non transformés ou transformés minimalement',
      2: 'Ingrédients culinaires transformés',
      3: 'Aliments transformés',
      4: 'Produits alimentaires ultra-transformés',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getNovaColor(result.novaScore!).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getNovaColor(result.novaScore!).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _getNovaColor(result.novaScore!),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${result.novaScore}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Classification NOVA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descriptions[result.novaScore] ?? 'Classification inconnue',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 12),
          Text(
            'Le score NOVA classifie les aliments selon leur degré de transformation. Un score plus bas indique un aliment plus naturel.',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showAddToMealDialog();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text('Ajouter à mon journal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Scanner un autre produit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddToMealDialog() {
    String selectedMealType = 'LUNCH';
    double quantity = 100.0;
    final result = widget.scanResult;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1F1B), Color(0xFF1A3A32)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.restaurant_menu, color: AppTheme.primaryGreen, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ajouter au journal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          result.productName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sélection du type de repas
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Type de repas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildMealTypeChip('BREAKFAST', '🌅', 'Petit-déjeuner', selectedMealType, (type) {
                    setModalState(() => selectedMealType = type);
                  }),
                  _buildMealTypeChip('LUNCH', '☀️', 'Déjeuner', selectedMealType, (type) {
                    setModalState(() => selectedMealType = type);
                  }),
                  _buildMealTypeChip('DINNER', '🌙', 'Dîner', selectedMealType, (type) {
                    setModalState(() => selectedMealType = type);
                  }),
                  _buildMealTypeChip('SNACK', '🍎', 'Collation', selectedMealType, (type) {
                    setModalState(() => selectedMealType = type);
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Quantité
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quantité (grammes)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildQuantityButton(Icons.remove, () {
                    if (quantity > 10) {
                      setModalState(() => quantity -= 10);
                    }
                  }),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${quantity.toStringAsFixed(0)} g',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  _buildQuantityButton(Icons.add, () {
                    setModalState(() => quantity += 10);
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Apport nutritionnel estimé
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientPreview('🔥', (result.nutritionInfo.calories ?? 0) * quantity / 100, 'kcal'),
                    _buildNutrientPreview('🥩', (result.nutritionInfo.proteins ?? 0) * quantity / 100, 'g'),
                    _buildNutrientPreview('🍞', (result.nutritionInfo.carbs ?? 0) * quantity / 100, 'g'),
                    _buildNutrientPreview('🥑', (result.nutritionInfo.fats ?? 0) * quantity / 100, 'g'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de confirmation
              GestureDetector(
                onTap: () => _addBarcodeProductToJournal(selectedMealType, quantity),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Confirmer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
      ),
    );
  }

  Widget _buildMealTypeChip(String type, String emoji, String label, String selected, Function(String) onSelect) {
    final isSelected = type == selected;
    return GestureDetector(
      onTap: () => onSelect(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryGreen : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
      ),
    );
  }

  Widget _buildNutrientPreview(String emoji, double value, String unit) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _addBarcodeProductToJournal(String mealType, double quantity) async {
    Navigator.pop(context); // Fermer le dialog

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
    );

    try {
      final mealProvider = context.read<MealProvider>();
      final today = DateFormatter.formatForApi(DateTime.now());
      final result = widget.scanResult;

      // Calculer les nutriments pour la quantité donnée
      final factor = quantity / 100.0;

      final items = [{
        'foodName': result.productName,
        'quantity': quantity,
        'servingUnit': 'g',
        'calories': (result.nutritionInfo.calories ?? 0) * factor,
        'protein': (result.nutritionInfo.proteins ?? 0) * factor,
        'carbs': (result.nutritionInfo.carbs ?? 0) * factor,
        'fat': (result.nutritionInfo.fats ?? 0) * factor,
      }];

      final mealData = {
        'date': today,
        'mealType': mealType,
        'source': 'BARCODE_SCAN',
        'items': items,
      };

      final success = await mealProvider.createMeal(mealData);

      if (!mounted) return;
      Navigator.pop(context); // Fermer le dialog de chargement

      if (success) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${result.productName} ajouté au journal'),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Retourner true à l'écran appelant pour signaler le succès
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Erreur lors de l\'ajout du repas'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Fermer le dialog de chargement

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erreur: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

