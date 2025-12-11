import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/planner_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/date_formatter.dart';

class GeneratePlanScreen extends StatefulWidget {
  const GeneratePlanScreen({super.key});

  @override
  State<GeneratePlanScreen> createState() => _GeneratePlanScreenState();
}

class _GeneratePlanScreenState extends State<GeneratePlanScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 6));
  String _selectedDietType = 'balanced';
  final Set<String> _selectedHealthLabels = {};
  final Set<String> _selectedAllergies = {};
  int _caloriesPerDay = 2000;
  int _mealsPerDay = 3;

  final Map<String, Map<String, String>> _dietTypes = {
    'balanced': {'emoji': '⚖️', 'label': 'Équilibré', 'desc': 'Répartition équilibrée des nutriments'},
    'low-carb': {'emoji': '🥩', 'label': 'Faible en glucides', 'desc': 'Moins de glucides, plus de protéines'},
    'high-protein': {'emoji': '💪', 'label': 'Riche en protéines', 'desc': 'Pour développer les muscles'},
    'low-fat': {'emoji': '🥗', 'label': 'Faible en gras', 'desc': 'Réduire les matières grasses'},
    'high-fiber': {'emoji': '🌾', 'label': 'Riche en fibres', 'desc': 'Pour une meilleure digestion'},
  };

  final Map<String, Map<String, String>> _healthLabels = {
    'vegetarian': {'emoji': '🥬', 'label': 'Végétarien'},
    'vegan': {'emoji': '🌱', 'label': 'Végan'},
    'gluten-free': {'emoji': '🌾', 'label': 'Sans gluten'},
    'dairy-free': {'emoji': '🥛', 'label': 'Sans lactose'},
    'keto-friendly': {'emoji': '🥑', 'label': 'Keto'},
    'paleo': {'emoji': '🦴', 'label': 'Paléo'},
  };

  final Map<String, Map<String, String>> _allergies = {
    'peanuts': {'emoji': '🥜', 'label': 'Arachides'},
    'tree-nuts': {'emoji': '🌰', 'label': 'Fruits à coque'},
    'milk': {'emoji': '🥛', 'label': 'Lait'},
    'eggs': {'emoji': '🥚', 'label': 'Œufs'},
    'soy': {'emoji': '🫘', 'label': 'Soja'},
    'wheat': {'emoji': '🌾', 'label': 'Blé'},
    'fish': {'emoji': '🐟', 'label': 'Poisson'},
    'shellfish': {'emoji': '🦐', 'label': 'Crustacés'},
  };

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 6));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _generatePlan() async {
    final requestData = {
      'startDate': DateFormatter.formatForApi(_startDate),
      'endDate': DateFormatter.formatForApi(_endDate),
      'dietType': _selectedDietType,
      'healthLabels': _selectedHealthLabels.toList(),
      'allergies': _selectedAllergies.toList(),
      'caloriesPerDay': _caloriesPerDay,
      'mealsPerDay': _mealsPerDay,
    };

    final provider = context.read<PlannerProvider>();
    final success = await provider.generateMealPlan(requestData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Plan généré avec succès !'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(provider.error ?? 'Erreur lors de la génération')),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _endDate.difference(_startDate).inDays + 1;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Générer un Plan'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Résumé en haut
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.primaryGreenDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Votre plan repas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$days jours • $_mealsPerDay repas/jour • $_caloriesPerDay kcal/jour',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Période
              _buildSectionHeader('📆 Période', 'Définissez la durée de votre plan', isDark),
              Card(
                elevation: isDark ? 0 : 2,
                color: isDark ? AppTheme.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withAlpha(isDark ? 50 : 30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.play_arrow, color: AppTheme.primaryGreen),
                      ),
                      title: Text(
                        'Date de début',
                        style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                      ),
                      subtitle: Text(
                        DateFormatter.formatForDisplay(_startDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                      onTap: _selectStartDate,
                    ),
                    Divider(height: 1, color: isDark ? AppTheme.darkDivider : Colors.grey[200]),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryOrange.withAlpha(isDark ? 50 : 30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.stop, color: AppTheme.secondaryOrange),
                      ),
                      title: Text(
                        'Date de fin',
                        style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                      ),
                      subtitle: Text(
                        DateFormatter.formatForDisplay(_endDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                      onTap: _selectEndDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Type de régime
              _buildSectionHeader('🍽️ Type de régime', 'Choisissez votre style d\'alimentation', isDark),
              Card(
                elevation: isDark ? 0 : 2,
                color: isDark ? AppTheme.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: _dietTypes.entries.map((entry) {
                      final isSelected = _selectedDietType == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedDietType = entry.key),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGreen.withAlpha(isDark ? 50 : 30)
                                  : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[50]),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(entry.value['emoji']!, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.value['label']!,
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkTextPrimary : Colors.grey[800]),
                                        ),
                                      ),
                                      Text(
                                        entry.value['desc']!,
                                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Préférences alimentaires
              _buildSectionHeader('🥗 Préférences alimentaires', 'Sélectionnez vos restrictions', isDark),
              Card(
                elevation: isDark ? 0 : 2,
                color: isDark ? AppTheme.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _healthLabels.entries.map((entry) {
                      final isSelected = _selectedHealthLabels.contains(entry.key);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedHealthLabels.remove(entry.key);
                            } else {
                              _selectedHealthLabels.add(entry.key);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.accentBlue.withAlpha(isDark ? 50 : 30)
                                : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentBlue : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(entry.value['emoji']!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                entry.value['label']!,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.accentBlue : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check, color: AppTheme.accentBlue, size: 16),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Allergies
              _buildSectionHeader('⚠️ Allergies', 'Exclure ces ingrédients', isDark),
              Card(
                elevation: isDark ? 0 : 2,
                color: isDark ? AppTheme.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allergies.entries.map((entry) {
                      final isSelected = _selectedAllergies.contains(entry.key);
                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedAllergies.remove(entry.key);
                            } else {
                              _selectedAllergies.add(entry.key);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.errorRed.withAlpha(isDark ? 50 : 30)
                                : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppTheme.errorRed : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(entry.value['emoji']!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                entry.value['label']!,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.errorRed : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.close, color: AppTheme.errorRed, size: 16),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Calories par jour
              _buildSectionHeader('🔥 Calories par jour', 'Ajustez votre apport calorique', isDark),
              Card(
                elevation: isDark ? 0 : 2,
                color: isDark ? AppTheme.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_caloriesPerDay',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                          Text(' kcal', style: TextStyle(fontSize: 18, color: isDark ? AppTheme.darkTextSecondary : Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primaryGreen,
                          inactiveTrackColor: isDark ? AppTheme.darkBorder : AppTheme.primaryGreen.withAlpha(50),
                          thumbColor: AppTheme.primaryGreen,
                          overlayColor: AppTheme.primaryGreen.withAlpha(30),
                        ),
                        child: Slider(
                          value: _caloriesPerDay.toDouble(),
                          min: 1200,
                          max: 3500,
                          divisions: 23,
                          onChanged: (value) {
                            setState(() {
                              _caloriesPerDay = value.toInt();
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1200 kcal', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600])),
                          Text('3500 kcal', style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Repas par jour
              _buildSectionHeader('🍴 Repas par jour', 'Nombre de repas quotidiens', isDark),
              Card(
                elevation: isDark ? 0 : 2,
                color: isDark ? AppTheme.darkSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3, 4, 5].map((n) {
                      final isSelected = _mealsPerDay == n;
                      return InkWell(
                        onTap: () => setState(() => _mealsPerDay = n),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton générer
              Consumer<PlannerProvider>(
                builder: (context, provider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isLoading ? null : _generatePlan,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(provider.isLoading ? 'Génération en cours...' : 'Générer mon plan repas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkTextTertiary : Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
