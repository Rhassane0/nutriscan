import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/ai_service.dart';
import '../../providers/meal_provider.dart';
import '../../utils/date_formatter.dart';

/// Écran de résultat d'analyse de repas par IA
class MealAnalysisResultScreen extends StatefulWidget {
  final MealPhotoAnalysisResponse analysisResult;
  final Uint8List imageBytes; // Changé de File à Uint8List pour compatibilité web
  final String? mealType;

  const MealAnalysisResultScreen({
    super.key,
    required this.analysisResult,
    required this.imageBytes,
    this.mealType,
  });

  @override
  State<MealAnalysisResultScreen> createState() => _MealAnalysisResultScreenState();
}

class _MealAnalysisResultScreenState extends State<MealAnalysisResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.analysisResult;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bannière d'avertissement si données de démo
                              if (_isDemoData(result)) _buildDemoWarningBanner(),
                              _buildImageWithConfidence(result),
                              const SizedBox(height: 24),
                              _buildAnalysisText(result),
                              const SizedBox(height: 24),
                              _buildDetectedFoodsSection(result),
                              const SizedBox(height: 24),
                              _buildNutritionEstimate(result),
                              const SizedBox(height: 24),
                              _buildActionButtons(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
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

  bool _isDemoData(MealPhotoAnalysisResponse result) {
    return result.detectedFoods.any((food) =>
      food.matchStatus == 'DEMO' ||
      food.matchStatus == 'DEMO_DATA' ||
      result.confidenceScore == 0
    );
  }

  Widget _buildDemoWarningBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withOpacity(0.2),
            const Color(0xFFFF5722).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFFB74D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Données de démonstration',
                  style: TextStyle(
                    color: Color(0xFFFFB74D),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'L\'IA Gemini n\'est pas configurée. Ces données sont des exemples.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFB388FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'Résultat d\'analyse',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.mealType != null)
                  Text(
                    _getMealTypeLabel(widget.mealType!),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  String _getMealTypeLabel(String type) {
    switch (type) {
      case 'BREAKFAST': return '🌅 Petit-déjeuner';
      case 'LUNCH': return '☀️ Déjeuner';
      case 'DINNER': return '🌙 Dîner';
      case 'SNACK': return '🍎 Collation';
      default: return type;
    }
  }

  Widget _buildImageWithConfidence(MealPhotoAnalysisResponse result) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(widget.imageBytes, fit: BoxFit.cover),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Badge de confiance
            Positioned(
              top: 16,
              right: 16,
              child: _buildConfidenceBadge(result.confidenceScore),
            ),

            // Nombre d'aliments détectés
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${result.detectedFoods.length} aliment${result.detectedFoods.length > 1 ? 's' : ''} détecté${result.detectedFoods.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  Widget _buildConfidenceBadge(double confidence) {
    final color = confidence >= 80
        ? const Color(0xFF00C853)
        : confidence >= 60
            ? const Color(0xFFFFB74D)
            : const Color(0xFFEF5350);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            confidence >= 80 ? Icons.verified : Icons.info_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            '${confidence.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisText(MealPhotoAnalysisResponse result) {
    if (result.analysisText.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C4DFF).withOpacity(0.2),
            const Color(0xFF7C4DFF).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFB388FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analyse IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.analysisText,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedFoodsSection(MealPhotoAnalysisResponse result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: AppTheme.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Aliments détectés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...result.detectedFoods.asMap().entries.map((entry) {
          final index = entry.key;
          final food = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: _buildDetectedFoodCard(food),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDetectedFoodCard(DetectedFood food) {
    Color statusColor;
    switch (food.matchStatus) {
      case 'AUTO_MATCHED':
        statusColor = const Color(0xFF00C853); // Vert
        break;
      case 'AI_DETECTED':
        statusColor = const Color(0xFF2196F3); // Bleu
        break;
      case 'DEMO':
      case 'DEMO_DATA':
        statusColor = const Color(0xFFFF9800); // Orange - données de démo
        break;
      case 'CANDIDATES':
        statusColor = const Color(0xFFFFB74D); // Jaune
        break;
      default:
        statusColor = const Color(0xFF9E9E9E); // Gris
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Indicateur de confiance circulaire
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: food.confidence / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                    Center(
                      child: Text(
                        '${food.confidence.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Infos de l'aliment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(food.matchStatus, statusColor),
                        if (food.estimatedQuantityGrams != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '~${food.estimatedQuantityGrams!.toStringAsFixed(0)}g',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Afficher les valeurs nutritionnelles si disponibles
          if (food.estimatedCalories != null && food.estimatedCalories! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniNutrient('Kcal', food.estimatedCalories ?? 0, AppTheme.caloriesColor),
                  _buildMiniNutrient('Prot', food.estimatedProteins ?? 0, AppTheme.proteinColor),
                  _buildMiniNutrient('Gluc', food.estimatedCarbs ?? 0, AppTheme.carbsColor),
                  _buildMiniNutrient('Lip', food.estimatedFats ?? 0, AppTheme.fatColor),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniNutrient(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    String label;
    IconData icon;

    switch (status) {
      case 'AUTO_MATCHED':
        label = 'Identifié';
        icon = Icons.check_circle;
        break;
      case 'AI_DETECTED':
        label = 'IA';
        icon = Icons.auto_awesome;
        break;
      case 'DEMO':
      case 'DEMO_DATA':
        label = 'Exemple';
        icon = Icons.info_outline;
        break;
      case 'CANDIDATES':
        label = 'Suggestions';
        icon = Icons.help_outline;
        break;
      default:
        label = 'Non trouvé';
        icon = Icons.search_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionEstimate(MealPhotoAnalysisResponse result) {
    // Estimation simplifiée basée sur les aliments détectés
    final totalEstimate = _calculateTotalEstimate(result);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.caloriesColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.caloriesColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Estimation nutritionnelle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Basée sur les portions détectées',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildNutrientCircle(
                  'Calories',
                  totalEstimate['calories']!,
                  'kcal',
                  AppTheme.caloriesColor,
                ),
              ),
              Expanded(
                child: _buildNutrientCircle(
                  'Protéines',
                  totalEstimate['proteins']!,
                  'g',
                  AppTheme.proteinColor,
                ),
              ),
              Expanded(
                child: _buildNutrientCircle(
                  'Glucides',
                  totalEstimate['carbs']!,
                  'g',
                  AppTheme.carbsColor,
                ),
              ),
              Expanded(
                child: _buildNutrientCircle(
                  'Lipides',
                  totalEstimate['fats']!,
                  'g',
                  AppTheme.fatColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateTotalEstimate(MealPhotoAnalysisResponse result) {
    // Utiliser les données nutritionnelles réelles du backend
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var food in result.detectedFoods) {
      // Utiliser les valeurs estimées par l'IA
      totalCalories += food.estimatedCalories ?? 0;
      totalProteins += food.estimatedProteins ?? 0;
      totalCarbs += food.estimatedCarbs ?? 0;
      totalFats += food.estimatedFats ?? 0;
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  Widget _buildNutrientCircle(String label, double value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton principal - Ajouter au journal
        GestureDetector(
          onTap: () => _showAddToMealDialog(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C853), Color(0xFF00E676)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C853).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Ajouter au journal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bouton secondaire - Nouvelle analyse
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
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  'Nouvelle analyse',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddToMealDialog() {
    String selectedMealType = widget.mealType ?? 'LUNCH';

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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
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
                  const Expanded(
                    child: Text(
                      'Ajouter au journal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
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

              // Résumé des aliments
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.analysisResult.detectedFoods.length} aliment(s) détecté(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.analysisResult.detectedFoods.take(3).map((food) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              food.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${food.estimatedCalories?.toStringAsFixed(0) ?? '?'} kcal',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (widget.analysisResult.detectedFoods.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${widget.analysisResult.detectedFoods.length - 3} autre(s)',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de confirmation
              GestureDetector(
                onTap: () => _addMealToJournal(selectedMealType),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF00E676)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C853).withOpacity(0.3),
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

  Future<void> _addMealToJournal(String mealType) async {
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

      // Créer les items du repas à partir des aliments détectés
      final items = widget.analysisResult.detectedFoods.map((food) => {
        'foodName': food.name,
        'quantity': food.estimatedQuantityGrams ?? 100.0,
        'servingUnit': 'g',
        'calories': food.estimatedCalories ?? 0.0,
        'protein': food.estimatedProteins ?? 0.0,
        'carbs': food.estimatedCarbs ?? 0.0,
        'fat': food.estimatedFats ?? 0.0,
        if (food.suggestedFoodId != null) 'foodId': food.suggestedFoodId,
      }).toList();

      final mealData = {
        'date': today,
        'mealType': mealType,
        'source': 'AI_SCAN',
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
                Text('Repas ajouté avec ${items.length} aliment(s)'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        // Retourner true à l'écran appelant (scanner) pour signaler le succès
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

