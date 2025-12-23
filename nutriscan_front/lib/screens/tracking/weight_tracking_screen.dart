import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../models/weight_entry.dart';
import '../../providers/weight_tracking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/user_service.dart';
import '../../services/goals_service.dart';
import '../../widgets/loading_indicator.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  double? _initialWeight;
  double? _targetWeight;
  String? _goalType;
  bool _isLoadingProfile = true;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<WeightTrackingProvider>();
    await provider.loadEntries();

    // Charger les infos du profil
    try {
      final userService = context.read<UserService>();
      final profile = await userService.getProfile();

      final goalsService = context.read<GoalsService>();
      Map<String, dynamic>? goals;
      try {
        goals = await goalsService.getGoals();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _initialWeight = (profile['initialWeightKg'] as num?)?.toDouble();
          _goalType = goals?['goalType'] as String? ?? profile['goalType'] as String?;

          // Calculer un poids cible basé sur l'objectif
          if (_initialWeight != null && _goalType != null) {
            switch (_goalType) {
              case 'LOSE_WEIGHT':
                _targetWeight = _initialWeight! - 5; // Objectif: perdre 5kg
                break;
              case 'GAIN_WEIGHT':
                _targetWeight = _initialWeight! + 5; // Objectif: prendre 5kg
                break;
              default:
                _targetWeight = _initialWeight; // Maintenir
            }
          }
          _isLoadingProfile = false;
        });

        // Ajouter automatiquement le poids initial si pas d'entrées
        if (provider.entries.isEmpty && _initialWeight != null) {
          await provider.addEntry(_initialWeight!, DateTime.now(), notes: 'Poids initial');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : AppTheme.backgroundLight,
      body: Stack(
        children: [
          if (isDark) _buildAnimatedBackground(),
          SafeArea(
            child: Consumer<WeightTrackingProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading || _isLoadingProfile) {
                  return const LoadingIndicator(message: 'Chargement...');
                }

                return Column(
                  children: [
                    _buildHeader(isDark),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.loadEntries(),
                        color: AppTheme.primaryGreen,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              _buildMainStatsCard(provider, isDark),
                              const SizedBox(height: 20),
                              if (provider.entries.length >= 2)
                                _buildProgressAnalysis(provider, isDark),
                              const SizedBox(height: 20),
                              if (provider.entries.length >= 2)
                                _buildChart(provider.entries, isDark),
                              const SizedBox(height: 20),
                              _buildHistorySection(provider, isDark),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildAddButton(isDark),
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
                        AppTheme.primaryGreen.withOpacity(0.12),
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
                  'Suivi du',
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
                    'Poids',
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
        ],
      ),
    );
  }

  Widget _buildMainStatsCard(WeightTrackingProvider provider, bool isDark) {
    final currentWeight = provider.entries.isNotEmpty ? provider.entries.first.weight : _initialWeight ?? 0;
    final startWeight = provider.entries.isNotEmpty
        ? provider.entries.last.weight
        : _initialWeight ?? currentWeight;
    final difference = currentWeight - startWeight;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.015);

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A1F38), const Color(0xFF0D1025)]
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
                // Poids actuel avec cercle de progression
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_targetWeight != null && _initialWeight != null)
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: _calculateProgress(currentWeight),
                          strokeWidth: 8,
                          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                        ),
                      ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monitor_weight,
                          size: 32,
                          color: _getProgressColor(),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentWeight.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppTheme.textDark,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'KG',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.grey[500],
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Statistiques
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Départ',
                        '${startWeight.toStringAsFixed(1)} kg',
                        Icons.flag_outlined,
                        AppTheme.accentBlue,
                        isDark,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Évolution',
                        '${difference >= 0 ? "+" : ""}${difference.toStringAsFixed(1)} kg',
                        difference >= 0 ? Icons.trending_up : Icons.trending_down,
                        difference == 0
                            ? AppTheme.accentBlue
                            : (_goalType == 'LOSE_WEIGHT'
                                ? (difference < 0 ? AppTheme.successGreen : AppTheme.errorRed)
                                : (difference > 0 ? AppTheme.successGreen : AppTheme.errorRed)),
                        isDark,
                      ),
                    ),
                    if (_targetWeight != null) ...[
                      Container(
                        width: 1,
                        height: 50,
                        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Objectif',
                          '${_targetWeight!.toStringAsFixed(1)} kg',
                          Icons.track_changes,
                          AppTheme.accentPurple,
                          isDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressAnalysis(WeightTrackingProvider provider, bool isDark) {
    final currentWeight = provider.entries.first.weight;
    final startWeight = provider.entries.last.weight;
    final difference = currentWeight - startWeight;

    String title;
    String message;
    Color color;
    IconData icon;

    if (_goalType == 'LOSE_WEIGHT') {
      if (difference < 0) {
        title = '🎉 Excellent progrès !';
        message = 'Vous avez perdu ${(-difference).toStringAsFixed(1)} kg. Continuez comme ça !';
        color = AppTheme.successGreen;
        icon = Icons.emoji_events;
      } else if (difference == 0) {
        title = '⚖️ Stabilité';
        message = 'Votre poids est stable. Augmentez légèrement votre déficit calorique.';
        color = AppTheme.accentBlue;
        icon = Icons.balance;
      } else {
        title = '💪 Restez motivé !';
        message = 'Vous avez pris ${difference.toStringAsFixed(1)} kg. Revoyez votre alimentation.';
        color = AppTheme.secondaryOrange;
        icon = Icons.fitness_center;
      }
    } else if (_goalType == 'GAIN_WEIGHT') {
      if (difference > 0) {
        title = '🎉 Excellent progrès !';
        message = 'Vous avez pris ${difference.toStringAsFixed(1)} kg. Continuez !';
        color = AppTheme.successGreen;
        icon = Icons.emoji_events;
      } else if (difference == 0) {
        title = '⚖️ Stabilité';
        message = 'Votre poids est stable. Augmentez votre apport calorique.';
        color = AppTheme.accentBlue;
        icon = Icons.balance;
      } else {
        title = '💪 Restez motivé !';
        message = 'Vous avez perdu ${(-difference).toStringAsFixed(1)} kg. Mangez plus !';
        color = AppTheme.secondaryOrange;
        icon = Icons.fitness_center;
      }
    } else {
      title = '⚖️ Maintien du poids';
      message = difference.abs() < 1
          ? 'Parfait ! Votre poids est stable.'
          : 'Variation de ${difference.abs().toStringAsFixed(1)} kg. Surveillez votre alimentation.';
      color = difference.abs() < 1 ? AppTheme.successGreen : AppTheme.secondaryOrange;
      icon = Icons.balance;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey[600],
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

  Widget _buildChart(List<WeightEntry> entries, bool isDark) {
    final sortedEntries = List<WeightEntry>.from(entries);
    sortedEntries.sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minWeight = sortedEntries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedEntries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  color: AppTheme.accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.show_chart, color: AppTheme.accentBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Évolution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= sortedEntries.length) return const Text('');
                        final date = sortedEntries[value.toInt()].date;
                        return Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: range > 0 ? (minWeight - range * 0.1).clamp(0, double.infinity) : minWeight - 2,
                maxY: range > 0 ? maxWeight + range * 0.1 : maxWeight + 2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.accentTeal],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryGreen.withOpacity(isDark ? 0.3 : 0.2),
                          AppTheme.primaryGreen.withOpacity(0),
                        ],
                      ),
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

  Widget _buildHistorySection(WeightTrackingProvider provider, bool isDark) {
    return Column(
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
              child: const Icon(Icons.history, color: AppTheme.accentPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Historique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (provider.entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F38) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.scale, size: 48, color: isDark ? Colors.white38 : Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune entrée de poids',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          ...provider.entries.take(10).map((entry) => _buildHistoryItem(entry, isDark)),
      ],
    );
  }

  Widget _buildHistoryItem(WeightEntry entry, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F38) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.monitor_weight, color: AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Text(
                    entry.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: () => _showAddDialog(isDark),
      child: Container(
        padding: const EdgeInsets.all(18),
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
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showAddDialog(bool isDark) {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F38) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGlowGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add_chart, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Nouvelle entrée',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Poids
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Poids',
                      labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500]),
                      suffixText: 'kg',
                      suffixStyle: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.monitor_weight, color: AppTheme.primaryGreen, size: 20),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.calendar_today, color: AppTheme.accentBlue, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: isDark ? Colors.white38 : Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: notesController,
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
                    decoration: InputDecoration(
                      labelText: 'Notes (optionnel)',
                      labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey[500]),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.note, color: AppTheme.accentPurple, size: 20),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final weight = double.tryParse(weightController.text);
                      if (weight == null || weight <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez entrer un poids valide')),
                        );
                        return;
                      }

                      final provider = context.read<WeightTrackingProvider>();
                      final success = await provider.addEntry(
                        weight,
                        selectedDate,
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Poids enregistré !' : 'Erreur lors de l\'enregistrement'),
                            backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text(
                          'Enregistrer',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
      ),
    );
  }

  double _calculateProgress(double currentWeight) {
    if (_initialWeight == null || _targetWeight == null) return 0;

    final totalChange = (_targetWeight! - _initialWeight!).abs();
    if (totalChange == 0) return 1.0;

    final currentChange = (currentWeight - _initialWeight!).abs();

    if (_goalType == 'LOSE_WEIGHT') {
      return currentWeight <= _targetWeight!
          ? 1.0
          : ((_initialWeight! - currentWeight) / (_initialWeight! - _targetWeight!)).clamp(0.0, 1.0);
    } else if (_goalType == 'GAIN_WEIGHT') {
      return currentWeight >= _targetWeight!
          ? 1.0
          : ((currentWeight - _initialWeight!) / (_targetWeight! - _initialWeight!)).clamp(0.0, 1.0);
    }

    return 1.0;
  }

  Color _getProgressColor() {
    if (_goalType == 'LOSE_WEIGHT') return AppTheme.errorRed;
    if (_goalType == 'GAIN_WEIGHT') return AppTheme.successGreen;
    return AppTheme.accentBlue;
  }
}

