import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../utils/constants.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    Constants.mealTypeIcons[meal.mealType] ?? '🍽️',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          Constants.mealTypeLabels[meal.mealType] ?? meal.mealType,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrientInfo(
                    '🔥',
                    meal.totalCalories.toStringAsFixed(0),
                    'cal',
                  ),
                  _buildNutrientInfo(
                    '🥩',
                    meal.totalProteins.toStringAsFixed(1),
                    'g',
                  ),
                  _buildNutrientInfo(
                    '🍞',
                    meal.totalCarbs.toStringAsFixed(1),
                    'g',
                  ),
                  _buildNutrientInfo(
                    '🥑',
                    meal.totalFats.toStringAsFixed(1),
                    'g',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${meal.foods.length} aliment${meal.foods.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String emoji, String value, String unit) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

