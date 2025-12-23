import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/planner_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/user_service.dart';
import '../../services/goals_service.dart';
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
  final Set<String> _selectedPreferences = {};
  final Set<String> _selectedAllergies = {};
  int _caloriesPerDay = 2000;
  bool _isLoadingPreferences = true;

  // Recherche
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Toutes les options
  final Map<String, Map<String, String>> _allPreferences = {
    'vegetarian': {'emoji': '🥬', 'label': 'Végétarien'},
    'vegan': {'emoji': '🌱', 'label': 'Végan'},
    'gluten-free': {'emoji': '🌾', 'label': 'Sans gluten'},
    'dairy-free': {'emoji': '🥛', 'label': 'Sans lactose'},
    'keto': {'emoji': '🥑', 'label': 'Keto'},
    'paleo': {'emoji': '🦴', 'label': 'Paléo'},
    'halal': {'emoji': '☪️', 'label': 'Halal'},
    'kosher': {'emoji': '✡️', 'label': 'Casher'},
    'low-carb': {'emoji': '🥩', 'label': 'Faible en glucides'},
    'high-protein': {'emoji': '💪', 'label': 'Riche en protéines'},
    'low-fat': {'emoji': '🥗', 'label': 'Faible en gras'},
    'mediterranean': {'emoji': '🫒', 'label': 'Méditerranéen'},
  };

  final Map<String, Map<String, String>> _allAllergies = {
    'peanuts': {'emoji': '🥜', 'label': 'Arachides'},
    'tree-nuts': {'emoji': '🌰', 'label': 'Fruits à coque'},
    'milk': {'emoji': '🥛', 'label': 'Lait'},
    'eggs': {'emoji': '🥚', 'label': 'Œufs'},
    'soy': {'emoji': '🫘', 'label': 'Soja'},
    'wheat': {'emoji': '🌾', 'label': 'Blé'},
    'fish': {'emoji': '🐟', 'label': 'Poisson'},
    'shellfish': {'emoji': '🦐', 'label': 'Crustacés'},
    'sesame': {'emoji': '⚪', 'label': 'Sésame'},
    'pork': {'emoji': '🐷', 'label': 'Porc'},
    'beef': {'emoji': '🐄', 'label': 'Bœuf'},
  };

  final Map<String, Map<String, String>> _dietTypes = {
    'balanced': {'emoji': '⚖️', 'label': 'Équilibré'},
    'low-carb': {'emoji': '🥩', 'label': 'Low Carb'},
    'high-protein': {'emoji': '💪', 'label': 'Protéiné'},
    'low-fat': {'emoji': '🥗', 'label': 'Low Fat'},
  };

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final userService = context.read<UserService>();
      final goalsService = context.read<GoalsService>();

      final profile = await userService.getProfile();

      Map<String, dynamic>? goals;
      try {
        goals = await goalsService.getGoals();
      } catch (e) {
        // Ignorer
      }

      if (mounted) {
        setState(() {
          if (profile['dietPreferences'] != null && profile['dietPreferences'] is String) {
            final prefs = (profile['dietPreferences'] as String)
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty);
            _selectedPreferences.addAll(prefs);
          }

          if (profile['allergies'] != null && profile['allergies'] is String) {
            final algs = (profile['allergies'] as String)
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((e) => e.isNotEmpty);
            _selectedAllergies.addAll(algs);
          }

          if (goals != null && goals['targetCalories'] != null) {
            _caloriesPerDay = (goals['targetCalories'] as num).toInt();
          }

          _isLoadingPreferences = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPreferences = false);
      }
    }
  }

  Future<void> _generatePlan() async {
    final isFrench = context.read<LocaleProvider>().isFrench;

    final List<String> healthPreferences = [
      _selectedDietType,
      ..._selectedPreferences,
    ];

    final requestData = {
      'startDate': DateFormatter.formatForApi(_startDate),
      'endDate': DateFormatter.formatForApi(_endDate),
      'planType': 'WEEKLY',
      'targetCalories': _caloriesPerDay,
      'healthPreferences': healthPreferences,
      'excludedIngredients': _selectedAllergies.toList(),
    };

    final provider = context.read<PlannerProvider>();
    final success = await provider.generateMealPlan(requestData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(isFrench ? 'Plan généré avec succès !' : 'Plan generated successfully!'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Expanded(child: Text(provider.error ?? (isFrench ? 'Erreur lors de la génération' : 'Error during generation'))),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final days = _endDate.difference(_startDate).inDays + 1;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      body: _isLoadingPreferences
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppTheme.darkGradient : null,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSummaryCard(days, isDark),
                            const SizedBox(height: 20),
                            _buildDateSection(isDark),
                            const SizedBox(height: 20),
                            _buildDietTypeSection(isDark),
                            const SizedBox(height: 20),
                            _buildCaloriesSection(isDark),
                            const SizedBox(height: 20),
                            _buildSearchablePreferencesSection(isDark),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomBar(isDark),
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
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? Colors.white : AppTheme.textDark),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Générer un',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                Text(
                  'Plan Repas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int days, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGlowGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text('🍽️', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre plan personnalisé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$days jours • $_caloriesPerDay kcal/jour',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                const Text('IA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Période',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDateButton('Début', _startDate, _selectStartDate, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateButton('Fin', _endDate, _selectEndDate, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime date, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.darkTextSecondary : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatForDisplay(date),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietTypeSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🍽️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Type de régime',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _dietTypes.entries.map((entry) {
              final isSelected = _selectedDietType == entry.key;
              return GestureDetector(
                onTap: () => setState(() => _selectedDietType = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen.withOpacity(isDark ? 0.3 : 0.15)
                        : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(entry.value['emoji']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        entry.value['label']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryGreen : (isDark ? Colors.white : AppTheme.textDark),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Calories par jour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '$_caloriesPerDay kcal',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryGreen,
              inactiveTrackColor: isDark ? AppTheme.darkBorder : Colors.grey[200],
              thumbColor: AppTheme.primaryGreen,
              overlayColor: AppTheme.primaryGreen.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _caloriesPerDay.toDouble(),
              min: 1200,
              max: 3500,
              divisions: 23,
              onChanged: (value) => setState(() => _caloriesPerDay = value.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchablePreferencesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🥗', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Préférences & Allergies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark),
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                hintStyle: TextStyle(color: isDark ? AppTheme.darkTextTertiary : Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[500]),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Sélections actuelles
          if (_selectedPreferences.isNotEmpty || _selectedAllergies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._selectedPreferences.map((key) {
                  final item = _allPreferences[key];
                  return _buildSelectedChip(key, item?['emoji'] ?? '🥗', item?['label'] ?? key, AppTheme.primaryGreen, isDark, isAllergy: false);
                }),
                ..._selectedAllergies.map((key) {
                  final item = _allAllergies[key];
                  return _buildSelectedChip(key, item?['emoji'] ?? '⚠️', item?['label'] ?? key, AppTheme.errorRed, isDark, isAllergy: true);
                }),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Préférences filtrées
          Text(
            'Préférences',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getFilteredItems(_allPreferences, _selectedPreferences).map((entry) {
              return _buildSelectableChip(
                entry.key,
                entry.value['emoji']!,
                entry.value['label']!,
                _selectedPreferences.contains(entry.key),
                AppTheme.primaryGreen,
                isDark,
                () => setState(() {
                  if (_selectedPreferences.contains(entry.key)) {
                    _selectedPreferences.remove(entry.key);
                  } else {
                    _selectedPreferences.add(entry.key);
                  }
                }),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Allergies filtrées
          Text(
            'Allergies à exclure',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getFilteredItems(_allAllergies, _selectedAllergies).map((entry) {
              return _buildSelectableChip(
                entry.key,
                entry.value['emoji']!,
                entry.value['label']!,
                _selectedAllergies.contains(entry.key),
                AppTheme.errorRed,
                isDark,
                () => setState(() {
                  if (_selectedAllergies.contains(entry.key)) {
                    _selectedAllergies.remove(entry.key);
                  } else {
                    _selectedAllergies.add(entry.key);
                  }
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, Map<String, String>>> _getFilteredItems(
    Map<String, Map<String, String>> items,
    Set<String> selected,
  ) {
    if (_searchQuery.isEmpty) return items.entries.toList();
    return items.entries.where((entry) {
      return entry.value['label']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Widget _buildSelectedChip(String key, String emoji, String label, Color color, bool isDark, {required bool isAllergy}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                if (isAllergy) {
                  _selectedAllergies.remove(key);
                } else {
                  _selectedPreferences.remove(key);
                }
              });
            },
            child: Icon(Icons.close, size: 16, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableChip(
    String key,
    String emoji,
    String label,
    bool isSelected,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(isDark ? 0.2 : 0.1)
              : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Consumer<PlannerProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'L\'IA génère vos recettes personnalisées...',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _generatePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Génération en cours...',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Générer mon plan',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

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
      setState(() => _endDate = picked);
    }
  }
}

