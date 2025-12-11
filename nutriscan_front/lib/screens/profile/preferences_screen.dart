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

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic>? _profile;

  // Controllers pour les infos personnelles
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  // Préférences alimentaires
  String _gender = 'MALE';
  String _activityLevel = 'MODERATE';
  String _goalType = 'MAINTAIN';
  final List<String> _dietaryRestrictions = [];
  final List<String> _allergies = [];

  // Options avec emojis et descriptions
  final Map<String, Map<String, String>> _dietaryRestrictionsInfo = {
    'vegetarian': {'emoji': '🥬', 'label': 'Végétarien', 'desc': 'Sans viande ni poisson'},
    'vegan': {'emoji': '🌱', 'label': 'Végan', 'desc': 'Sans produits animaux'},
    'pescatarian': {'emoji': '🐟', 'label': 'Pescétarien', 'desc': 'Poisson mais pas de viande'},
    'gluten-free': {'emoji': '🌾', 'label': 'Sans gluten', 'desc': 'Évite le blé, orge, seigle'},
    'dairy-free': {'emoji': '🥛', 'label': 'Sans lactose', 'desc': 'Évite les produits laitiers'},
    'halal': {'emoji': '☪️', 'label': 'Halal', 'desc': 'Conforme aux règles islamiques'},
    'kosher': {'emoji': '✡️', 'label': 'Casher', 'desc': 'Conforme aux règles juives'},
    'keto': {'emoji': '🥑', 'label': 'Keto', 'desc': 'Faible en glucides'},
    'paleo': {'emoji': '🦴', 'label': 'Paléo', 'desc': 'Alimentation ancestrale'},
  };

  final Map<String, Map<String, String>> _allergiesInfo = {
    'peanuts': {'emoji': '🥜', 'label': 'Arachides', 'severity': 'high'},
    'tree-nuts': {'emoji': '🌰', 'label': 'Fruits à coque', 'severity': 'high'},
    'milk': {'emoji': '🥛', 'label': 'Lait', 'severity': 'medium'},
    'eggs': {'emoji': '🥚', 'label': 'Œufs', 'severity': 'medium'},
    'soy': {'emoji': '🫘', 'label': 'Soja', 'severity': 'medium'},
    'wheat': {'emoji': '🌾', 'label': 'Blé', 'severity': 'medium'},
    'fish': {'emoji': '🐟', 'label': 'Poisson', 'severity': 'high'},
    'shellfish': {'emoji': '🦐', 'label': 'Crustacés', 'severity': 'high'},
    'sesame': {'emoji': '🫘', 'label': 'Sésame', 'severity': 'medium'},
    'celery': {'emoji': '🥬', 'label': 'Céleri', 'severity': 'low'},
    'mustard': {'emoji': '🟡', 'label': 'Moutarde', 'severity': 'low'},
    'sulfites': {'emoji': '🍷', 'label': 'Sulfites', 'severity': 'low'},
  };

  final Map<String, Map<String, String>> _activityLevels = {
    'SEDENTARY': {'emoji': '🪑', 'label': 'Sédentaire', 'desc': 'Peu ou pas d\'exercice'},
    'LIGHT': {'emoji': '🚶', 'label': 'Légère', 'desc': 'Exercice léger 1-3 jours/sem'},
    'MODERATE': {'emoji': '🏃', 'label': 'Modérée', 'desc': 'Exercice modéré 3-5 jours/sem'},
    'ACTIVE': {'emoji': '💪', 'label': 'Active', 'desc': 'Exercice intense 6-7 jours/sem'},
    'VERY_ACTIVE': {'emoji': '🏋️', 'label': 'Très active', 'desc': 'Exercice très intense quotidien'},
  };

  final Map<String, Map<String, String>> _goalTypes = {
    'LOSE_WEIGHT': {'emoji': '📉', 'label': 'Perdre du poids', 'color': '0xFFE53935'},
    'MAINTAIN': {'emoji': '⚖️', 'label': 'Maintenir', 'color': '0xFF2196F3'},
    'GAIN_WEIGHT': {'emoji': '💪', 'label': 'Prendre du poids', 'color': '0xFF4CAF50'},
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
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
        _profile = profile;
        _heightController.text = profile['heightCm']?.toString() ?? '';
        _weightController.text = profile['initialWeightKg']?.toString() ?? '';
        _ageController.text = profile['age']?.toString() ?? '';
        _gender = profile['gender'] ?? 'MALE';
        _activityLevel = profile['activityLevel'] ?? 'MODERATE';
        _goalType = profile['goalType'] ?? 'MAINTAIN';

        if (profile['dietPreferences'] != null && profile['dietPreferences'] is String) {
          final prefs = (profile['dietPreferences'] as String).split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty);
          _dietaryRestrictions.clear();
          _dietaryRestrictions.addAll(prefs);
        }

        if (profile['allergies'] != null && profile['allergies'] is String) {
          final algs = (profile['allergies'] as String).split(',').map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty);
          _allergies.clear();
          _allergies.addAll(algs);
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
        'heightCm': int.tryParse(_heightController.text) ?? 170,
        'initialWeightKg': double.tryParse(_weightController.text) ?? 70,
        'age': int.tryParse(_ageController.text) ?? 25,
        'gender': _gender,
        'activityLevel': _activityLevel,
        'goalType': _goalType,
        'dietPreferences': _dietaryRestrictions.join(', '),
        'allergies': _allergies.join(', '),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profil mis à jour avec succès !'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences & Profil'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isSaving ? 'Sauvegarde...' : 'Sauvegarder',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.backgroundLight,
        ),
        child: _isLoading
            ? const LoadingIndicator(message: 'Chargement du profil...')
            : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.errorRed),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.errorRed),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.errorRed))),
                              IconButton(
                                icon: const Icon(Icons.close, color: AppTheme.errorRed),
                                onPressed: () => setState(() => _error = null),
                              ),
                            ],
                          ),
                        ),

                      // Section: Informations Personnelles
                      _buildSectionHeader('👤 Informations Personnelles', 'Vos données de base', isDark),
                      _buildInfoCard([
                        _buildNumberField(
                          controller: _heightController,
                          label: 'Taille',
                          suffix: 'cm',
                          icon: Icons.height,
                          iconColor: Colors.blue,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildNumberField(
                          controller: _weightController,
                          label: 'Poids actuel',
                          suffix: 'kg',
                          icon: Icons.monitor_weight,
                          iconColor: Colors.orange,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildNumberField(
                          controller: _ageController,
                          label: 'Âge',
                          suffix: 'ans',
                          icon: Icons.cake,
                          iconColor: Colors.pink,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        _buildGenderSelector(isDark),
                      ], isDark),

                      const SizedBox(height: 24),

                      // Section: Objectif
                      _buildSectionHeader('🎯 Votre Objectif', 'Que souhaitez-vous accomplir ?', isDark),
                      _buildGoalSelector(isDark),

                      const SizedBox(height: 24),

                      // Section: Niveau d'activité
                      _buildSectionHeader('🏃 Niveau d\'Activité', 'À quelle fréquence faites-vous du sport ?', isDark),
                      _buildActivitySelector(isDark),

                      const SizedBox(height: 24),

                      // Section: Restrictions alimentaires
                      _buildSectionHeader('🥗 Régimes & Préférences', 'Sélectionnez vos préférences alimentaires', isDark),
                      _buildDietaryRestrictionsSelector(isDark),

                      const SizedBox(height: 24),

                      // Section: Allergies
                      _buildSectionHeader('⚠️ Allergies', 'Sélectionnez vos allergies alimentaires', isDark),
                      _buildAllergiesSelector(isDark),

                      const SizedBox(height: 32),

                      // Bouton de sauvegarde
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? 'Sauvegarde en cours...' : 'Enregistrer les Modifications'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        filled: true,
        fillColor: isDark ? AppTheme.darkSurfaceLight : Colors.grey[50],
      ),
    );
  }

  Widget _buildGenderSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderOption('MALE', '👨', 'Homme', isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderOption('FEMALE', '👩', 'Femme', isDark),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String value, String emoji, String label, bool isDark) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1)
              : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryGreen
                    : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector(bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: _goalTypes.entries.map((entry) {
            final isSelected = _goalType == entry.key;
            final color = Color(int.parse(entry.value['color']!));
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _goalType = entry.key),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(isDark ? 0.2 : 0.1)
                        : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(entry.value['emoji']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          entry.value['label']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: color, size: 24),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivitySelector(bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: _activityLevels.entries.map((entry) {
            final isSelected = _activityLevel == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _activityLevel = entry.key),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentBlue.withOpacity(isDark ? 0.2 : 0.1)
                        : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentBlue : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
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
                                color: isSelected ? AppTheme.accentBlue : (isDark ? AppTheme.darkTextPrimary : Colors.grey[800]),
                              ),
                            ),
                            Text(
                              entry.value['desc']!,
                              style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppTheme.accentBlue, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDietaryRestrictionsSelector(bool isDark) {
    return Card(
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
          children: _dietaryRestrictionsInfo.entries.map((entry) {
            final isSelected = _dietaryRestrictions.contains(entry.key);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _dietaryRestrictions.remove(entry.key);
                  } else {
                    _dietaryRestrictions.add(entry.key);
                  }
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen.withOpacity(isDark ? 0.25 : 0.15)
                      : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.value['emoji']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      entry.value['label']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: AppTheme.primaryGreen, size: 16),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAllergiesSelector(bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      color: isDark ? AppTheme.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark ? BorderSide(color: AppTheme.darkBorder) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sélectionnez vos allergies pour éviter ces ingrédients dans vos recommandations',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergiesInfo.entries.map((entry) {
                final isSelected = _allergies.contains(entry.key);
                final severityColor = entry.value['severity'] == 'high'
                    ? AppTheme.errorRed
                    : entry.value['severity'] == 'medium'
                        ? Colors.orange
                        : Colors.amber;

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _allergies.remove(entry.key);
                      } else {
                        _allergies.add(entry.key);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? severityColor.withOpacity(isDark ? 0.25 : 0.15)
                          : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? severityColor : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value['emoji']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          entry.value['label']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? severityColor : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.close, color: severityColor, size: 16),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
