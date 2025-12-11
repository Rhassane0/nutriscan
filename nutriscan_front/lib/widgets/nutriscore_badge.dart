import 'package:flutter/material.dart';
import '../config/theme.dart';

class NutriScoreBadge extends StatelessWidget {
  final String? score;
  final double size;

  const NutriScoreBadge({
    super.key,
    required this.score,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final color = AppTheme.getNutriScoreColor(score);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          score!.toUpperCase(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class EcoScoreBadge extends StatelessWidget {
  final String? score;
  final double size;

  const EcoScoreBadge({
    super.key,
    required this.score,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.eco_outlined,
            size: 24,
            color: Colors.white,
          ),
        ),
      );
    }

    final color = AppTheme.getEcoScoreColor(score);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.eco,
            size: 20,
            color: Colors.white,
          ),
          Text(
            score!.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

