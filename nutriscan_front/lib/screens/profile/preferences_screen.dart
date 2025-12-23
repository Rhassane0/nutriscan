import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/user_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../providers/theme_provider.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  late TabController _tabController;

  // Recherche
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Préférences sélectionnées
  final Set<String> _selectedDiets = {};
  final Set<String> _selectedAllergies = {};

  // Toutes les options disponibles
  final Map<String, Map<String, String>> _allDietsAndPreferences = {
    // Régimes alimentaires
    'vegetarian': {'emoji': '🥬', 'label': 'Végétarien', 'category': 'diet'},
    'vegan': {'emoji': '🌱', 'label': 'Végan', 'category': 'diet'},
    'pescatarian': {'emoji': '🐟', 'label': 'Pescétarien', 'category': 'diet'},
    'halal': {'emoji': '☪️', 'label': 'Halal', 'category': 'diet'},
    'kosher': {'emoji': '✡️', 'label': 'Casher', 'category': 'diet'},
    'keto': {'emoji': '🥑', 'label': 'Keto', 'category': 'diet'},
    'paleo': {'emoji': '🦴', 'label': 'Paléo', 'category': 'diet'},
    'mediterranean': {'emoji': '🫒', 'label': 'Méditerranéen', 'category': 'diet'},
    'whole30': {'emoji': '🥦', 'label': 'Whole30', 'category': 'diet'},
    'raw': {'emoji': '🥕', 'label': 'Crudivore', 'category': 'diet'},
    // Préférences nutritionnelles
    'gluten-free': {'emoji': '🌾', 'label': 'Sans gluten', 'category': 'pref'},
    'dairy-free': {'emoji': '🥛', 'label': 'Sans lactose', 'category': 'pref'},
    'low-carb': {'emoji': '🥩', 'label': 'Faible en glucides', 'category': 'pref'},
    'high-protein': {'emoji': '💪', 'label': 'Riche en protéines', 'category': 'pref'},
    'low-fat': {'emoji': '🥗', 'label': 'Faible en gras', 'category': 'pref'},
    'low-sodium': {'emoji': '🧂', 'label': 'Faible en sel', 'category': 'pref'},
    'sugar-free': {'emoji': '🍬', 'label': 'Sans sucre', 'category': 'pref'},
    'high-fiber': {'emoji': '🌾', 'label': 'Riche en fibres', 'category': 'pref'},
    'fodmap-free': {'emoji': '🍎', 'label': 'Sans FODMAP', 'category': 'pref'},
    'organic': {'emoji': '🌿', 'label': 'Bio', 'category': 'pref'},
  };

  final Map<String, Map<String, String>> _allAllergies = {
    'peanuts': {'emoji': '🥜', 'label': 'Arachides', 'severity': 'high'},
    'tree-nuts': {'emoji': '🌰', 'label': 'Fruits à coque', 'severity': 'high'},
    'milk': {'emoji': '🥛', 'label': 'Lait', 'severity': 'medium'},
    'eggs': {'emoji': '🥚', 'label': 'Œufs', 'severity': 'medium'},
    'soy': {'emoji': '🫘', 'label': 'Soja', 'severity': 'medium'},
    'wheat': {'emoji': '🌾', 'label': 'Blé/Gluten', 'severity': 'medium'},
    'fish': {'emoji': '🐟', 'label': 'Poisson', 'severity': 'high'},
    'shellfish': {'emoji': '🦐', 'label': 'Crustacés', 'severity': 'high'},
    'sesame': {'emoji': '⚪', 'label': 'Sésame', 'severity': 'medium'},
    'celery': {'emoji': '🥬', 'label': 'Céleri', 'severity': 'low'},
    'mustard': {'emoji': '🟡', 'label': 'Moutarde', 'severity': 'low'},
    'sulfites': {'emoji': '🍷', 'label': 'Sulfites', 'severity': 'low'},
    'lupin': {'emoji': '🌿', 'label': 'Lupin', 'severity': 'medium'},
    'mollusks': {'emoji': '🦪', 'label': 'Mollusques', 'severity': 'high'},
    'corn': {'emoji': '🌽', 'label': 'Maïs', 'severity': 'low'},
    'pork': {'emoji': '🐷', 'label': 'Porc', 'severity': 'medium'},
    'beef': {'emoji': '🐄', 'label': 'Bœuf', 'severity': 'low'},
    'chicken': {'emoji': '🐔', 'label': 'Poulet', 'severity': 'low'},
    'alcohol': {'emoji': '🍺', 'label': 'Alcool', 'severity': 'medium'},
    'caffeine': {'emoji': '☕', 'label': 'Caféine', 'severity': 'low'},
    'garlic': {'emoji': '🧄', 'label': 'Ail', 'severity': 'low'},
    'onion': {'emoji': '🧅', 'label': 'Oignon', 'severity': 'low'},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = context.read<UserService>();
      final profile = await userService.getProfile();

      setState(() {
        if (profile['dietPreferences'] != null && profile['dietPreferences'] is String) {
          final prefs = (profile['dietPreferences'] as String)
              .split(',')
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty);
          _selectedDiets.addAll(prefs);
        }

        if (profile['allergies'] != null && profile['allergies'] is String) {
          final algs = (profile['allergies'] as String)
              .split(',')
              .map((e) => e.trim().toLowerCase())
              .where((e) => e.isNotEmpty);
          _selectedAllergies.addAll(algs);
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final userService = context.read<UserService>();
      await userService.updateProfile({
        'dietPreferences': _selectedDiets.join(', '),
        'allergies': _selectedAllergies.join(', '),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Préférences sauvegardées !'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() => _isSaving = false);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  List<MapEntry<String, Map<String, String>>> _getFilteredDiets() {
    if (_searchQuery.isEmpty) {
      return _allDietsAndPreferences.entries.toList();
    }
    return _allDietsAndPreferences.entries.where((entry) {
      final label = entry.value['label']!.toLowerCase();
      return label.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<MapEntry<String, Map<String, String>>> _getFilteredAllergies() {
    if (_searchQuery.isEmpty) {
      return _allAllergies.entries.toList();
    }
    return _allAllergies.entries.where((entry) {
      final label = entry.value['label']!.toLowerCase();
      return label.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundLight,
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppTheme.darkGradient : null,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    _buildSearchBar(isDark),
                    _buildTabBar(isDark),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDietsTab(isDark),
                          _buildAllergiesTab(isDark),
                        ],
                      ),
                    ),
                    _buildBottomBar(isDark),
                  ],
                ),
              ),
            ),
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
                  'Préférences',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                Text(
                  'Alimentaires',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          _buildSelectedCount(isDark),
        ],
      ),
    );
  }

  Widget _buildSelectedCount(bool isDark) {
    final total = _selectedDiets.length + _selectedAllergies.length;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGlowGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.grey[200]!),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textDark,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher régime, préférence, allergie...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.darkTextTertiary : Colors.grey[400],
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? AppTheme.darkTextSecondary : Colors.grey[500],
            size: 24,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[500]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGlowGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🥗'),
                const SizedBox(width: 8),
                const Text('Régimes'),
                if (_selectedDiets.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${_selectedDiets.length}', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⚠️'),
                const SizedBox(width: 8),
                const Text('Allergies'),
                if (_selectedAllergies.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${_selectedAllergies.length}', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietsTab(bool isDark) {
    final filtered = _getFilteredDiets();

    if (filtered.isEmpty) {
      return _buildEmptySearch(isDark, 'régime ou préférence');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        final isSelected = _selectedDiets.contains(entry.key);

        return _buildItemCard(
          key: entry.key,
          emoji: entry.value['emoji']!,
          label: entry.value['label']!,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDiets.remove(entry.key);
              } else {
                _selectedDiets.add(entry.key);
              }
            });
          },
          color: AppTheme.primaryGreen,
        );
      },
    );
  }

  Widget _buildAllergiesTab(bool isDark) {
    final filtered = _getFilteredAllergies();

    if (filtered.isEmpty) {
      return _buildEmptySearch(isDark, 'allergie');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        final isSelected = _selectedAllergies.contains(entry.key);
        final severity = entry.value['severity'];
        final color = severity == 'high' ? AppTheme.errorRed
            : severity == 'medium' ? Colors.orange
            : Colors.amber;

        return _buildItemCard(
          key: entry.key,
          emoji: entry.value['emoji']!,
          label: entry.value['label']!,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAllergies.remove(entry.key);
              } else {
                _selectedAllergies.add(entry.key);
              }
            });
          },
          color: color,
          subtitle: severity == 'high' ? 'Allergie majeure'
              : severity == 'medium' ? 'Allergie modérée'
              : 'Sensibilité',
        );
      },
    );
  }

  Widget _buildItemCard({
    required String key,
    required String emoji,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(isDark ? 0.2 : 0.1)
                  : (isDark ? AppTheme.darkSurface : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : (isDark ? AppTheme.darkBorder : Colors.grey[200]!),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? color : (isDark ? Colors.white : AppTheme.textDark),
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextTertiary : Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch(bool isDark, String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: isDark ? AppTheme.darkTextTertiary : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun $type trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez une autre recherche',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.darkTextTertiary : Colors.grey[400],
            ),
          ),
        ],
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
        child: Row(
          children: [
            if (_selectedDiets.isNotEmpty || _selectedAllergies.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDiets.clear();
                    _selectedAllergies.clear();
                  });
                },
                child: Text(
                  'Effacer tout',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Enregistrer',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
}

