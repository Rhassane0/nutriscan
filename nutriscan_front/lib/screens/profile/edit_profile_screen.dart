import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;
  String? _selectedGoalType;

  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _genderOptions = ['MALE', 'FEMALE', 'OTHER'];
  final Map<String, String> _genderLabels = {
    'MALE': 'Homme',
    'FEMALE': 'Femme',
    'OTHER': 'Autre',
  };

  final List<String> _activityLevels = [
    'SEDENTARY',
    'LIGHT',
    'MODERATE',
    'ACTIVE',
    'VERY_ACTIVE',
  ];
  final Map<String, String> _activityLabels = {
    'SEDENTARY': 'Sédentaire',
    'LIGHT': 'Légèrement actif',
    'MODERATE': 'Modérément actif',
    'ACTIVE': 'Actif',
    'VERY_ACTIVE': 'Très actif',
  };

  final List<String> _goalTypes = ['LOSE_WEIGHT', 'MAINTAIN', 'GAIN_WEIGHT'];
  final Map<String, String> _goalLabels = {
    'LOSE_WEIGHT': 'Perdre du poids',
    'MAINTAIN': 'Maintenir le poids',
    'GAIN_WEIGHT': 'Prendre du poids',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userService = context.read<UserService>();
      final profile = await userService.getProfile();

      setState(() {
        _fullNameController.text = profile['fullName'] ?? '';
        _ageController.text = (profile['age'] ?? '').toString();
        _heightController.text = (profile['heightCm'] ?? '').toString();
        _weightController.text = (profile['initialWeightKg'] ?? '').toString();
        _selectedGender = profile['gender'];
        _selectedActivityLevel = profile['activityLevel'];
        _selectedGoalType = profile['goalType'];
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = context.read<UserService>();

      final data = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
      };

      if (_ageController.text.isNotEmpty) {
        data['age'] = int.tryParse(_ageController.text);
      }
      if (_heightController.text.isNotEmpty) {
        // heightCm doit être un Integer
        data['heightCm'] = int.tryParse(_heightController.text);
      }
      if (_weightController.text.isNotEmpty) {
        data['initialWeightKg'] = double.tryParse(_weightController.text);
      }
      if (_selectedGender != null) {
        data['gender'] = _selectedGender;
      }
      if (_selectedActivityLevel != null) {
        data['activityLevel'] = _selectedActivityLevel;
      }
      if (_selectedGoalType != null) {
        data['goalType'] = _selectedGoalType;
      }

      await userService.updateProfile(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom complet
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Genre
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        prefixIcon: Icon(Icons.wc),
                        border: OutlineInputBorder(),
                      ),
                      items: _genderOptions.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(_genderLabels[gender] ?? gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Âge
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Âge',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Taille
                    TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Taille (cm)',
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Poids
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Poids initial (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Niveau d'activité
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      decoration: const InputDecoration(
                        labelText: 'Niveau d\'activité',
                        prefixIcon: Icon(Icons.directions_run),
                        border: OutlineInputBorder(),
                      ),
                      items: _activityLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(_activityLabels[level] ?? level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedActivityLevel = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Objectif
                    DropdownButtonFormField<String>(
                      value: _selectedGoalType,
                      decoration: const InputDecoration(
                        labelText: 'Objectif',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: _goalTypes.map((goal) {
                        return DropdownMenuItem(
                          value: goal,
                          child: Text(_goalLabels[goal] ?? goal),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGoalType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Enregistrer',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

