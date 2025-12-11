import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../models/weight_entry.dart';
import '../../providers/weight_tracking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/weight_progress_analysis.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightTrackingProvider>().loadEntries();
    });
  }

  Future<void> _addEntry() async {
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final themeProvider = context.read<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          title: Text(
            'Ajouter une entrée',
            style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                  decoration: InputDecoration(
                    labelText: 'Poids (kg)',
                    labelStyle: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                    ),
                    prefixIcon: Icon(Icons.monitor_weight, color: isDark ? AppTheme.primaryGreenLight : AppTheme.primaryGreen),
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Date', style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium),
                  ),
                  trailing: Icon(Icons.calendar_today, color: isDark ? AppTheme.primaryGreenLight : AppTheme.primaryGreen),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: isDark
                                ? const ColorScheme.dark(
                                    primary: AppTheme.primaryGreen,
                                    surface: AppTheme.darkSurface,
                                  )
                                : const ColorScheme.light(
                                    primary: AppTheme.primaryGreen,
                                  ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                  decoration: InputDecoration(
                    labelText: 'Notes (optionnel)',
                    labelStyle: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
                    ),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez entrer un poids')),
                  );
                  return;
                }

                try {
                  final weight = double.parse(weightController.text);
                  Navigator.pop(context);

                  final provider = context.read<WeightTrackingProvider>();
                  final success = await provider.addEntry(
                    weight,
                    selectedDate,
                    notes: notesController.text,
                  );

                  if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${provider.error}')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi du Poids'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: Consumer<WeightTrackingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingIndicator(message: 'Chargement...');
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: TextStyle(fontSize: 16, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadEntries(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (provider.entries.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadEntries(),
              color: AppTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Analyse de progression
                    const SizedBox(height: 16),
                    WeightProgressAnalysis(
                      entries: provider.entries,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    if (provider.entries.length >= 2) _buildChart(provider.entries, isDark),
                    const SizedBox(height: 16),
                    _buildStats(provider.entries, isDark),
                    const SizedBox(height: 16),
                    _buildEntriesList(provider.entries, isDark),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'weight_fab',
        onPressed: _addEntry,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 100,
            color: isDark ? AppTheme.darkTextTertiary : Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune donnée de poids',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à suivre votre poids',
            style: TextStyle(fontSize: 16, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[500]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addEntry,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une entrée'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution du poids',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
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
                      color: isDark ? AppTheme.darkBorder : Colors.grey[300]!,
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
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
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
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: (minWeight - range * 0.1).clamp(0, double.infinity),
                maxY: maxWeight + range * 0.1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.1),
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

  Widget _buildStats(List<WeightEntry> entries, bool isDark) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final currentWeight = entries.first.weight;
    final startWeight = entries.last.weight;
    final difference = currentWeight - startWeight;
    final minWeight = entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final avgWeight = entries.map((e) => e.weight).reduce((a, b) => a + b) / entries.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Actuel',
                  '${currentWeight.toStringAsFixed(1)} kg',
                  Icons.monitor_weight,
                  AppTheme.primaryGreen,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Évolution',
                  '${difference >= 0 ? "+" : ""}${difference.toStringAsFixed(1)} kg',
                  difference >= 0 ? Icons.trending_up : Icons.trending_down,
                  difference >= 0 ? AppTheme.errorRed : AppTheme.successGreen,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Minimum',
                  '${minWeight.toStringAsFixed(1)} kg',
                  Icons.arrow_downward,
                  AppTheme.accentBlue,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Maximum',
                  '${maxWeight.toStringAsFixed(1)} kg',
                  Icons.arrow_upward,
                  AppTheme.warningYellow,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Moyenne',
            '${avgWeight.toStringAsFixed(1)} kg',
            Icons.insights,
            AppTheme.accentPurple,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<WeightEntry> entries, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark ? Border.all(color: AppTheme.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Historique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? AppTheme.darkDivider : Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monitor_weight, color: AppTheme.primaryGreen),
                ),
                title: Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                      style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium),
                    ),
                    if (entry.notes != null && entry.notes!.isNotEmpty)
                      Text(
                        entry.notes!,
                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600]),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
