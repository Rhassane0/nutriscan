import 'package:flutter/material.dart';
import '../../models/food.dart';
import '../../config/theme.dart';

class ScanResultScreen extends StatelessWidget {
  final Food food;

  const ScanResultScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du scan'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec nom du produit
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withValues(alpha: 0.7)],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    food.label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (food.category != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      food.category!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations nutritionnelles
                  _buildSection(
                    context,
                    'Informations nutritionnelles',
                    Icons.analytics,
                    child: Column(
                      children: [
                        _buildNutrientRow('Calories', food.nutrients.calories ?? 0, 'kcal'),
                        _buildNutrientRow('Protéines', food.nutrients.proteins ?? 0, 'g'),
                        _buildNutrientRow('Glucides', food.nutrients.carbs ?? 0, 'g'),
                        _buildNutrientRow('Lipides', food.nutrients.fats ?? 0, 'g'),
                        if (food.nutrients.sugars != null)
                          _buildNutrientRow('Sucres', food.nutrients.sugars!, 'g'),
                        if (food.nutrients.fiber != null)
                          _buildNutrientRow('Fibres', food.nutrients.fiber!, 'g'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Ajouter aux repas
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter aux repas'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, {required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

