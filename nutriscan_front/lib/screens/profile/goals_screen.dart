import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../services/goals_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../providers/theme_provider.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic>? _goals;

  late AnimationController _pulseController;
  late AnimationController _rotateController;

  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _loadGoals();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final goalsService = context.read<GoalsService>();
      final goals = await goalsService.getGoals();

      setState(() {
        _goals = goals;
        _caloriesController.text = (goals['targetCalories'] as num?)?.toStringAsFixed(0) ?? '2000';
        _proteinController.text = (goals['proteinGr'] as num?)?.toStringAsFixed(0) ?? '150';
        _carbsController.text = (goals['carbsGr'] as num?)?.toStringAsFixed(0) ?? '200';
        _fatController.text = (goals['fatGr'] as num?)?.toStringAsFixed(0) ?? '65';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGoals() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final goalsService = context.read<GoalsService>();
      await goalsService.updateGoals({
        'targetCalories': double.tryParse(_caloriesController.text) ?? 2000,
        'proteinGr': double.tryParse(_proteinController.text) ?? 150,
        'carbsGr': double.tryParse(_carbsController.text) ?? 200,
        'fatGr': double.tryParse(_fatController.text) ?? 65,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Objectifs mis à jour !'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        await _loadGoals();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  Future<void> _recalculateGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final goalsService = context.read<GoalsService>();
      await goalsService.recalculateGoals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.auto_fix_high, color: Colors.white),
                SizedBox(width: 8),
                Text('Objectifs recalculés !'),
              ],
            ),
            backgroundColor: AppTheme.accentBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        await _loadGoals();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : AppTheme.backgroundLight,
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : Stack(
              children: [
                // Background animated elements
                if (isDark) _buildAnimatedBackground(),

                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(isDark),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              if (_goals != null) _buildMainStats(isDark),
                              const SizedBox(height: 24),
                              _buildMacrosSection(isDark),
                              const SizedBox(height: 24),
                              _buildEditSection(isDark),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom action bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomBar(isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * math.pi,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 200,
              left: -50,
              child: Transform.rotate(
                angle: -_rotateController.value * 2 * math.pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentBlue.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objectifs',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                  ).createShader(bounds),
                  child: const Text(
                    'Nutritionnels',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _recalculateGoals,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentBlue.withOpacity(0.8),
                    AppTheme.accentPurple.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentBlue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_fix_high, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats(bool isDark) {
    final calories = (_goals!['targetCalories'] as num?)?.toDouble() ?? 2000;
    final maintenance = (_goals!['maintenanceCalories'] as num?)?.toDouble() ?? 2500;
    final goalType = _goals!['goalType']?.toString() ?? 'MAINTAIN';

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.02);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A1F38),
                        const Color(0xFF0D1025),
                      ]
                    : [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? AppTheme.primaryGreen.withOpacity(0.3)
                    : Colors.grey[200]!,
                width: isDark ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppTheme.primaryGreen.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Calories centrales
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cercle extérieur animé
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: calories / maintenance,
                        strokeWidth: 8,
                        backgroundColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getGoalColor(goalType),
                        ),
                      ),
                    ),
                    // Contenu central
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 32,
                          color: _getGoalColor(goalType),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          calories.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppTheme.textDark,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'KCAL/JOUR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.grey[500],
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoBadge(
                      _getGoalIcon(goalType),
                      _getGoalLabel(goalType),
                      _getGoalColor(goalType),
                      isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoBadge(
                      Icons.speed,
                      'Maintien: ${maintenance.toStringAsFixed(0)}',
                      AppTheme.accentBlue,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
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

  Widget _buildMacrosSection(bool isDark) {
    final protein = (_goals?['proteinGr'] as num?)?.toDouble() ?? 150;
    final carbs = (_goals?['carbsGr'] as num?)?.toDouble() ?? 200;
    final fat = (_goals?['fatGr'] as num?)?.toDouble() ?? 65;
    final totalCal = (protein * 4) + (carbs * 4) + (fat * 9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGlowGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Répartition des Macros',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),

        Row(
          children: [
            Expanded(
              child: _buildMacroCard(
                'Protéines',
                protein,
                'g',
                (protein * 4 / totalCal * 100),
                AppTheme.accentBlue,
                Icons.fitness_center,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMacroCard(
                'Glucides',
                carbs,
                'g',
                (carbs * 4 / totalCal * 100),
                AppTheme.secondaryOrange,
                Icons.grain,
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMacroCard(
                'Lipides',
                fat,
                'g',
                (fat * 9 / totalCal * 100),
                AppTheme.accentPurple,
                Icons.water_drop,
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String label,
    double value,
    String unit,
    double percentage,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? color.withOpacity(0.3) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: AppTheme.accentPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Modifier manuellement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEditField(_caloriesController, 'Calories', 'kcal', Icons.local_fire_department, AppTheme.primaryGreen, isDark),
          const SizedBox(height: 14),
          _buildEditField(_proteinController, 'Protéines', 'g', Icons.fitness_center, AppTheme.accentBlue, isDark),
          const SizedBox(height: 14),
          _buildEditField(_carbsController, 'Glucides', 'g', Icons.grain, AppTheme.secondaryOrange, isDark),
          const SizedBox(height: 14),
          _buildEditField(_fatController, 'Lipides', 'g', Icons.water_drop, AppTheme.accentPurple, isDark),
        ],
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String label,
    String suffix,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[500],
            fontSize: 14,
          ),
          suffixText: suffix,
          suffixStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1025) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveGoals,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Enregistrer les Objectifs',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color _getGoalColor(String goalType) {
    switch (goalType) {
      case 'LOSE_WEIGHT':
        return AppTheme.errorRed;
      case 'GAIN_WEIGHT':
        return AppTheme.successGreen;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData _getGoalIcon(String goalType) {
    switch (goalType) {
      case 'LOSE_WEIGHT':
        return Icons.trending_down;
      case 'GAIN_WEIGHT':
        return Icons.trending_up;
      default:
        return Icons.balance;
    }
  }

  String _getGoalLabel(String goalType) {
    switch (goalType) {
      case 'LOSE_WEIGHT':
        return 'Perte';
      case 'GAIN_WEIGHT':
        return 'Prise';
      default:
        return 'Maintien';
    }
  }
}

