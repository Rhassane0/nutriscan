import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/weight_entry.dart';

/// Widget d'analyse de progression du poids
class WeightProgressAnalysis extends StatelessWidget {
  final List<WeightEntry> entries;
  final bool isDark;

  const WeightProgressAnalysis({
    super.key,
    required this.entries,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return _buildNotEnoughData();
    }

    final analysis = _analyzeProgress();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          color: _getProgressColor(analysis.progressType).withAlpha(isDark ? 77 : 51),
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getProgressColor(analysis.progressType),
                      _getProgressColor(analysis.progressType).withAlpha(200),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _getProgressEmoji(analysis.progressType),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyse de progression',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      analysis.summary,
                      style: TextStyle(
                        fontSize: 13,
                        color: _getProgressColor(analysis.progressType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats de progression
          _buildProgressStats(analysis),

          const SizedBox(height: 16),

          // Insights
          if (analysis.insights.isNotEmpty) _buildInsights(analysis),

          const SizedBox(height: 16),

          // Conseil personnalisé
          _buildAdvice(analysis),
        ],
      ),
    );
  }

  Widget _buildNotEnoughData() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('📊', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pas assez de données',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                Text(
                  'Ajoutez au moins 2 entrées pour voir votre analyse',
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
    );
  }

  Widget _buildProgressStats(WeightAnalysis analysis) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            label: 'Changement',
            value: '${analysis.totalChange >= 0 ? '+' : ''}${analysis.totalChange.toStringAsFixed(1)} kg',
            color: analysis.totalChange <= 0 ? AppTheme.primaryGreen : AppTheme.warningYellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            label: 'Par semaine',
            value: '${analysis.weeklyRate >= 0 ? '+' : ''}${analysis.weeklyRate.toStringAsFixed(2)} kg',
            color: analysis.weeklyRate <= 0 ? AppTheme.primaryGreen : AppTheme.warningYellow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            label: 'Régularité',
            value: '${analysis.consistency.toStringAsFixed(0)}%',
            color: analysis.consistency >= 70 ? AppTheme.primaryGreen : AppTheme.accentBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 26 : 13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(WeightAnalysis analysis) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: analysis.insights.map((insight) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (insight.isPositive ? AppTheme.primaryGreen : AppTheme.warningYellow)
                .withAlpha(isDark ? 26 : 13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (insight.isPositive ? AppTheme.primaryGreen : AppTheme.warningYellow)
                  .withAlpha(51),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                insight.isPositive ? Icons.check_circle : Icons.info,
                size: 16,
                color: insight.isPositive ? AppTheme.primaryGreen : AppTheme.warningYellow,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  insight.text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdvice(WeightAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withAlpha(isDark ? 26 : 13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentBlue.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: AppTheme.accentBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analysis.advice,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
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

  WeightAnalysis _analyzeProgress() {
    // Trier par date
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstEntry = sorted.first;
    final lastEntry = sorted.last;

    // Calculs de base
    final totalChange = lastEntry.weight - firstEntry.weight;
    final daysDiff = lastEntry.date.difference(firstEntry.date).inDays;
    final weeksDiff = daysDiff / 7.0;
    final weeklyRate = weeksDiff > 0 ? totalChange / weeksDiff : 0.0;

    // Calcul de la régularité (basé sur la variance des intervalles)
    double consistency = 100;
    if (sorted.length >= 3) {
      final intervals = <int>[];
      for (int i = 1; i < sorted.length; i++) {
        intervals.add(sorted[i].date.difference(sorted[i-1].date).inDays);
      }
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      final variance = intervals.map((i) => (i - avgInterval).abs()).reduce((a, b) => a + b) / intervals.length;
      consistency = (100 - (variance * 10)).clamp(0, 100);
    }

    // Déterminer le type de progression
    ProgressType progressType;
    if (totalChange <= -2) {
      progressType = ProgressType.excellent;
    } else if (totalChange <= -0.5) {
      progressType = ProgressType.good;
    } else if (totalChange <= 0.5) {
      progressType = ProgressType.stable;
    } else if (totalChange <= 2) {
      progressType = ProgressType.warning;
    } else {
      progressType = ProgressType.needsAttention;
    }

    // Générer les insights
    final insights = <WeightInsight>[];

    if (weeklyRate <= -0.5 && weeklyRate >= -1) {
      insights.add(const WeightInsight('Perte de poids saine', true));
    } else if (weeklyRate < -1) {
      insights.add(const WeightInsight('Perte rapide, attention à votre santé', false));
    }

    if (consistency >= 80) {
      insights.add(const WeightInsight('Excellente régularité de suivi', true));
    } else if (consistency < 50) {
      insights.add(const WeightInsight('Pesez-vous plus régulièrement', false));
    }

    if (sorted.length >= 7) {
      final lastWeek = sorted.where((e) =>
        e.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).toList();
      if (lastWeek.length >= 3) {
        insights.add(const WeightInsight('Bon suivi cette semaine', true));
      }
    }

    // Générer le résumé
    String summary;
    switch (progressType) {
      case ProgressType.excellent:
        summary = 'Excellente progression ! 🎉';
        break;
      case ProgressType.good:
        summary = 'Bonne progression';
        break;
      case ProgressType.stable:
        summary = 'Poids stable';
        break;
      case ProgressType.warning:
        summary = 'Légère prise de poids';
        break;
      case ProgressType.needsAttention:
        summary = 'Attention à votre progression';
        break;
    }

    // Générer le conseil
    String advice;
    if (progressType == ProgressType.excellent || progressType == ProgressType.good) {
      advice = 'Continuez ainsi ! Maintenez vos bonnes habitudes alimentaires et votre activité physique régulière.';
    } else if (progressType == ProgressType.stable) {
      advice = 'Votre poids est stable. Si vous souhaitez perdre du poids, réduisez légèrement les calories ou augmentez l\'activité physique.';
    } else {
      advice = 'Revoyez votre alimentation et augmentez votre activité physique. Consultez un professionnel si la tendance continue.';
    }

    return WeightAnalysis(
      progressType: progressType,
      summary: summary,
      totalChange: totalChange,
      weeklyRate: weeklyRate,
      consistency: consistency,
      insights: insights,
      advice: advice,
    );
  }

  Color _getProgressColor(ProgressType type) {
    switch (type) {
      case ProgressType.excellent:
        return AppTheme.primaryGreen;
      case ProgressType.good:
        return AppTheme.accentTeal;
      case ProgressType.stable:
        return AppTheme.accentBlue;
      case ProgressType.warning:
        return AppTheme.warningYellow;
      case ProgressType.needsAttention:
        return AppTheme.errorRed;
    }
  }

  String _getProgressEmoji(ProgressType type) {
    switch (type) {
      case ProgressType.excellent:
        return '🏆';
      case ProgressType.good:
        return '👍';
      case ProgressType.stable:
        return '⚖️';
      case ProgressType.warning:
        return '⚠️';
      case ProgressType.needsAttention:
        return '🔔';
    }
  }
}

enum ProgressType { excellent, good, stable, warning, needsAttention }

class WeightAnalysis {
  final ProgressType progressType;
  final String summary;
  final double totalChange;
  final double weeklyRate;
  final double consistency;
  final List<WeightInsight> insights;
  final String advice;

  WeightAnalysis({
    required this.progressType,
    required this.summary,
    required this.totalChange,
    required this.weeklyRate,
    required this.consistency,
    required this.insights,
    required this.advice,
  });
}

class WeightInsight {
  final String text;
  final bool isPositive;

  const WeightInsight(this.text, this.isPositive);
}

