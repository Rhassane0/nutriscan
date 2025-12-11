import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/goals_service.dart';
import '../../widgets/loading_indicator.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _goals;

  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
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
        // Les noms corrects du backend
        _caloriesController.text = goals['targetCalories']?.toString() ?? '';
        _proteinController.text = goals['proteinGr']?.toString() ?? '';
        _carbsController.text = goals['carbsGr']?.toString() ?? '';
        _fatController.text = goals['fatGr']?.toString() ?? '';
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
      _isLoading = true;
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
          const SnackBar(content: Text('Objectifs mis à jour !')),
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
          const SnackBar(content: Text('Objectifs recalculés depuis votre profil !')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objectifs Nutritionnels'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recalculateGoals,
            tooltip: 'Recalculer depuis le profil',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Chargement...')
          : RefreshIndicator(
              onRefresh: _loadGoals,
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
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorRed),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.errorRed),
                        ),
                      ),

                    // Informations actuelles
                    if (_goals != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Objectifs Actuels',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildGoalRow('Type d\'objectif', _goals!['goalType'], ''),
                              _buildGoalRow('Niveau d\'activité', _goals!['activityLevel'], ''),
                              _buildGoalRow('Calories de maintien', _goals!['maintenanceCalories'], 'kcal'),
                              _buildGoalRow('Calories cibles', _goals!['targetCalories'], 'kcal'),
                              _buildGoalRow('Protéines', _goals!['proteinGr'], 'g'),
                              _buildGoalRow('Glucides', _goals!['carbsGr'], 'g'),
                              _buildGoalRow('Lipides', _goals!['fatGr'], 'g'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Formulaire de modification
                    const Text(
                      'Modifier les Objectifs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories quotidiennes',
                        suffixText: 'kcal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Protéines quotidiennes',
                        suffixText: 'g',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.egg),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _carbsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Glucides quotidiens',
                        suffixText: 'g',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grain),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lipides quotidiens',
                        suffixText: 'g',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.water_drop),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _saveGoals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Enregistrer les Objectifs'),
                    ),

                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: _recalculateGoals,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recalculer depuis le profil'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGoalRow(String label, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${value ?? 0} $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

