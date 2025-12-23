import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/theme.dart';
import '../../services/user_service.dart';
import '../../services/goals_service.dart';
import '../../providers/theme_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'MALE';
  String _selectedActivityLevel = 'MODERATE';
  String _selectedGoalType = 'MAINTAIN';

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isInitialized = false;

  late AnimationController _rotateController;

  final Map<String, Map<String, dynamic>> _genderOptions = {
    'MALE': {'emoji': '👨', 'label': 'Homme'},
    'FEMALE': {'emoji': '👩', 'label': 'Femme'},
  };

  final Map<String, Map<String, dynamic>> _activityLevels = {
    'SEDENTARY': {'emoji': '🪑', 'label': 'Sédentaire', 'desc': 'Peu ou pas d\'exercice'},
    'LIGHT': {'emoji': '🚶', 'label': 'Légèrement actif', 'desc': 'Exercice léger 1-3j/sem'},
    'MODERATE': {'emoji': '🏃', 'label': 'Modérément actif', 'desc': 'Exercice modéré 3-5j/sem'},
    'ACTIVE': {'emoji': '💪', 'label': 'Actif', 'desc': 'Exercice intense 6-7j/sem'},
    'VERY_ACTIVE': {'emoji': '🏋️', 'label': 'Très actif', 'desc': 'Exercice très intense'},
  };

  final Map<String, Map<String, dynamic>> _goalTypes = {
    'LOSE_WEIGHT': {'emoji': '📉', 'label': 'Perdre du poids', 'color': AppTheme.errorRed},
    'MAINTAIN': {'emoji': '⚖️', 'label': 'Maintenir', 'color': AppTheme.accentBlue},
    'GAIN_WEIGHT': {'emoji': '💪', 'label': 'Prendre du poids', 'color': AppTheme.successGreen},
  };

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final userService = context.read<UserService>();
      final profile = await userService.getProfile();

      setState(() {
        _fullNameController.text = profile['fullName'] ?? '';
        _ageController.text = (profile['age'] ?? '').toString();
        _heightController.text = (profile['heightCm'] ?? '').toString();
        _weightController.text = (profile['initialWeightKg'] ?? '').toString();
        _selectedGender = profile['gender'] ?? 'MALE';
        _selectedActivityLevel = profile['activityLevel'] ?? 'MODERATE';
        _selectedGoalType = profile['goalType'] ?? 'MAINTAIN';
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userService = context.read<UserService>();

      await userService.updateProfile({
        'fullName': _fullNameController.text.trim(),
        'age': int.tryParse(_ageController.text),
        'heightCm': int.tryParse(_heightController.text),
        'initialWeightKg': double.tryParse(_weightController.text),
        'gender': _selectedGender,
        'activityLevel': _selectedActivityLevel,
        'goalType': _selectedGoalType,
      });

      // Recalculer les objectifs
      try {
        final goalsService = context.read<GoalsService>();
        await goalsService.recalculateGoals();
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profil mis à jour !'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E21) : AppTheme.backgroundLight,
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : Stack(
              children: [
                if (isDark) _buildAnimatedBackground(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(isDark),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          physics: const BouncingScrollPhysics(),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _buildNameField(isDark),
                                const SizedBox(height: 24),
                                _buildGenderSection(isDark),
                                const SizedBox(height: 24),
                                _buildMeasurementsSection(isDark),
                                const SizedBox(height: 24),
                                _buildActivitySection(isDark),
                                const SizedBox(height: 24),
                                _buildGoalSection(isDark),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  'Informations',
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
                    'Personnelles',
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

  Widget _buildNameField(bool isDark) {
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
                child: const Icon(Icons.person, color: AppTheme.accentBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Nom complet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fullNameController,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Entrez votre nom',
              hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400]),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez entrer votre nom';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '👤 Genre',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
        Row(
          children: _genderOptions.entries.map((entry) {
            final isSelected = _selectedGender == entry.key;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: entry.key == 'MALE' ? 12 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF1A1F38) : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryGreen : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        blurRadius: 12,
                      ),
                    ] : null,
                  ),
                  child: Column(
                    children: [
                      Text(entry.value['emoji']!, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        entry.value['label']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryGreen : (isDark ? Colors.white : AppTheme.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMeasurementsSection(bool isDark) {
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
                  color: AppTheme.secondaryOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.straighten, color: AppTheme.secondaryOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Mesures corporelles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildMeasureField(_ageController, 'Âge', 'ans', Icons.cake, AppTheme.accentPurple, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMeasureField(_heightController, 'Taille', 'cm', Icons.height, AppTheme.accentBlue, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMeasureField(_weightController, 'Poids', 'kg', Icons.monitor_weight, AppTheme.primaryGreen, isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureField(TextEditingController controller, String label, String suffix, IconData icon, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              suffixText: suffix,
              suffixStyle: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '🏃 Niveau d\'activité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
        ..._activityLevels.entries.map((entry) {
          final isSelected = _selectedActivityLevel == entry.key;
          return GestureDetector(
            onTap: () => setState(() => _selectedActivityLevel = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentBlue.withOpacity(isDark ? 0.2 : 0.1)
                    : (isDark ? const Color(0xFF1A1F38) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.accentBlue : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(entry.value['emoji']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value['label']!,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppTheme.accentBlue : (isDark ? Colors.white : AppTheme.textDark),
                          ),
                        ),
                        Text(
                          entry.value['desc']!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.accentBlue, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildGoalSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '🎯 Objectif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ),
        ..._goalTypes.entries.map((entry) {
          final isSelected = _selectedGoalType == entry.key;
          final color = entry.value['color'] as Color;
          return GestureDetector(
            onTap: () => setState(() => _selectedGoalType = entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(isDark ? 0.2 : 0.1)
                    : (isDark ? const Color(0xFF1A1F38) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 12,
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(entry.value['emoji']!, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      entry.value['label']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? color : (isDark ? Colors.white : AppTheme.textDark),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
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
            onPressed: _isSaving ? null : _saveProfile,
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
                        'Enregistrer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

