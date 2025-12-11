import 'dart:math';
import '../models/meal.dart';
import '../models/weight_entry.dart';

/// Service pour générer des conseils personnalisés et des analyses
class TipsService {
  static final Random _random = Random();

  /// Génère un conseil basé sur l'heure et les données de l'utilisateur
  static Tip getTipOfTheDay({
    List<Meal>? todayMeals,
    List<WeightEntry>? weightHistory,
    Map<String, double>? nutritionTotals,
  }) {
    final hour = DateTime.now().hour;
    final dayOfWeek = DateTime.now().weekday;

    // Conseils personnalisés selon le contexte
    final tips = <Tip>[];

    // Conseils basés sur l'heure
    if (hour >= 6 && hour < 10) {
      tips.addAll(_getMorningTips());
    } else if (hour >= 10 && hour < 12) {
      tips.addAll(_getMidMorningTips());
    } else if (hour >= 12 && hour < 14) {
      tips.addAll(_getLunchTips());
    } else if (hour >= 14 && hour < 17) {
      tips.addAll(_getAfternoonTips());
    } else if (hour >= 17 && hour < 20) {
      tips.addAll(_getEveningTips());
    } else {
      tips.addAll(_getNightTips());
    }

    // Conseils basés sur les repas d'aujourd'hui
    if (todayMeals != null && todayMeals.isNotEmpty) {
      tips.addAll(_getMealBasedTips(todayMeals));
    }

    // Conseils basés sur la nutrition
    if (nutritionTotals != null) {
      tips.addAll(_getNutritionBasedTips(nutritionTotals));
    }

    // Conseils basés sur le poids
    if (weightHistory != null && weightHistory.length >= 2) {
      tips.addAll(_getWeightBasedTips(weightHistory));
    }

    // Conseils pour le week-end
    if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
      tips.addAll(_getWeekendTips());
    }

    // Ajoute des conseils généraux si la liste est vide
    if (tips.isEmpty) {
      tips.addAll(_getGeneralTips());
    }

    // Sélectionne un conseil aléatoire
    return tips[_random.nextInt(tips.length)];
  }

  /// Conseils du matin
  static List<Tip> _getMorningTips() {
    return [
      const Tip(
        emoji: '🌅',
        title: 'Bon réveil !',
        message: 'Commencez la journée avec un verre d\'eau pour réveiller votre métabolisme.',
        color: TipColor.blue,
      ),
      const Tip(
        emoji: '🥣',
        title: 'Petit-déjeuner',
        message: 'Un petit-déjeuner riche en protéines vous gardera rassasié plus longtemps.',
        color: TipColor.orange,
      ),
      const Tip(
        emoji: '☀️',
        title: 'Énergie matinale',
        message: 'Les céréales complètes libèrent de l\'énergie progressivement toute la matinée.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '🍳',
        title: 'Protéines du matin',
        message: 'Les œufs sont une excellente source de protéines pour bien démarrer.',
        color: TipColor.orange,
      ),
    ];
  }

  /// Conseils de mi-matinée
  static List<Tip> _getMidMorningTips() {
    return [
      const Tip(
        emoji: '💧',
        title: 'Hydratation',
        message: 'Avez-vous bu assez d\'eau ce matin ? Visez 2L par jour.',
        color: TipColor.blue,
      ),
      const Tip(
        emoji: '🍎',
        title: 'Collation saine',
        message: 'Si vous avez faim, optez pour un fruit ou quelques noix.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '🚶',
        title: 'Pause active',
        message: 'Levez-vous et marchez quelques minutes pour activer votre circulation.',
        color: TipColor.purple,
      ),
    ];
  }

  /// Conseils pour le déjeuner
  static List<Tip> _getLunchTips() {
    return [
      const Tip(
        emoji: '🥗',
        title: 'Légumes d\'abord',
        message: 'Commencez votre repas par les légumes pour mieux contrôler votre appétit.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '🍽️',
        title: 'Manger lentement',
        message: 'Prenez 20 minutes pour manger, votre cerveau a besoin de temps pour sentir la satiété.',
        color: TipColor.blue,
      ),
      const Tip(
        emoji: '🌈',
        title: 'Assiette colorée',
        message: 'Plus votre assiette est colorée, plus elle est riche en nutriments variés.',
        color: TipColor.purple,
      ),
    ];
  }

  /// Conseils de l'après-midi
  static List<Tip> _getAfternoonTips() {
    return [
      const Tip(
        emoji: '🍵',
        title: 'Thé vert',
        message: 'Le thé vert booste le métabolisme et est riche en antioxydants.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '🥜',
        title: 'Énergie durable',
        message: 'Une poignée d\'amandes peut vous aider à tenir jusqu\'au dîner.',
        color: TipColor.orange,
      ),
      const Tip(
        emoji: '💪',
        title: 'Mouvement',
        message: 'Une marche de 15 minutes après le déjeuner aide la digestion.',
        color: TipColor.purple,
      ),
    ];
  }

  /// Conseils du soir
  static List<Tip> _getEveningTips() {
    return [
      const Tip(
        emoji: '🌙',
        title: 'Dîner léger',
        message: 'Un dîner plus léger favorise un sommeil de meilleure qualité.',
        color: TipColor.blue,
      ),
      const Tip(
        emoji: '🐟',
        title: 'Oméga-3',
        message: 'Le poisson est excellent pour le dîner : léger et riche en bons acides gras.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '⏰',
        title: 'Timing',
        message: 'Essayez de dîner au moins 2h avant de vous coucher.',
        color: TipColor.orange,
      ),
    ];
  }

  /// Conseils de nuit
  static List<Tip> _getNightTips() {
    return [
      const Tip(
        emoji: '😴',
        title: 'Repos réparateur',
        message: 'Un bon sommeil est essentiel pour réguler votre appétit.',
        color: TipColor.purple,
      ),
      const Tip(
        emoji: '🌿',
        title: 'Tisane relaxante',
        message: 'Une tisane à la camomille favorise l\'endormissement.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '📱',
        title: 'Écrans',
        message: 'Évitez les écrans 1h avant de dormir pour un meilleur sommeil.',
        color: TipColor.blue,
      ),
    ];
  }

  /// Conseils du week-end
  static List<Tip> _getWeekendTips() {
    return [
      const Tip(
        emoji: '🏃',
        title: 'Activité du week-end',
        message: 'Profitez du week-end pour une activité physique en extérieur !',
        color: TipColor.purple,
      ),
      const Tip(
        emoji: '🍳',
        title: 'Brunch équilibré',
        message: 'Un brunch peut être sain : œufs, avocat, légumes frais.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '🥘',
        title: 'Cuisine maison',
        message: 'Profitez du week-end pour préparer vos repas de la semaine.',
        color: TipColor.orange,
      ),
    ];
  }

  /// Conseils basés sur les repas du jour
  static List<Tip> _getMealBasedTips(List<Meal> meals) {
    final tips = <Tip>[];

    // Calcul des totaux
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalCalories = 0;

    for (var meal in meals) {
      totalProtein += meal.totalProtein;
      totalCarbs += meal.totalCarbs;
      totalFat += meal.totalFat;
      totalCalories += meal.totalCalories;
    }

    // Conseils selon les macros
    if (totalProtein < 50) {
      tips.add(const Tip(
        emoji: '🥩',
        title: 'Plus de protéines',
        message: 'Votre apport en protéines est faible aujourd\'hui. Ajoutez de la viande maigre ou des légumineuses.',
        color: TipColor.orange,
      ));
    }

    if (totalCarbs > 200) {
      tips.add(const Tip(
        emoji: '🍞',
        title: 'Glucides élevés',
        message: 'Beaucoup de glucides aujourd\'hui. Privilégiez les protéines pour votre prochain repas.',
        color: TipColor.orange,
      ));
    }

    if (totalCalories > 1800 && DateTime.now().hour < 18) {
      tips.add(const Tip(
        emoji: '⚡',
        title: 'Calories',
        message: 'Vous approchez de votre objectif calorique. Optez pour un dîner léger.',
        color: TipColor.orange,
      ));
    }

    return tips;
  }

  /// Conseils basés sur la nutrition
  static List<Tip> _getNutritionBasedTips(Map<String, double> totals) {
    final tips = <Tip>[];

    final calories = totals['calories'] ?? 0;
    final proteins = totals['proteins'] ?? 0;

    if (calories < 500 && DateTime.now().hour > 12) {
      tips.add(const Tip(
        emoji: '🍽️',
        title: 'N\'oubliez pas de manger',
        message: 'Vous n\'avez pas beaucoup mangé aujourd\'hui. Pensez à faire des repas réguliers.',
        color: TipColor.orange,
      ));
    }

    if (proteins > 100) {
      tips.add(const Tip(
        emoji: '💪',
        title: 'Excellent apport protéique',
        message: 'Bel apport en protéines aujourd\'hui ! Parfait pour la récupération musculaire.',
        color: TipColor.green,
      ));
    }

    return tips;
  }

  /// Conseils basés sur l'historique du poids
  static List<Tip> _getWeightBasedTips(List<WeightEntry> history) {
    final tips = <Tip>[];

    // Trie par date
    final sorted = List<WeightEntry>.from(history)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.length >= 2) {
      final latest = sorted.last.weight;
      final previous = sorted[sorted.length - 2].weight;
      final diff = latest - previous;

      if (diff < -0.5) {
        tips.add(Tip(
          emoji: '📉',
          title: 'Progression !',
          message: 'Vous avez perdu ${(-diff).toStringAsFixed(1)}kg récemment. Continuez ainsi !',
          color: TipColor.green,
        ));
      } else if (diff > 0.5) {
        tips.add(const Tip(
          emoji: '💪',
          title: 'Restez motivé',
          message: 'Une petite prise de poids est normale. Concentrez-vous sur vos habitudes alimentaires.',
          color: TipColor.blue,
        ));
      } else {
        tips.add(const Tip(
          emoji: '⚖️',
          title: 'Stabilité',
          message: 'Votre poids est stable. C\'est un bon signe de régularité !',
          color: TipColor.green,
        ));
      }
    }

    return tips;
  }

  /// Conseils généraux
  static List<Tip> _getGeneralTips() {
    return [
      const Tip(
        emoji: '💧',
        title: 'Hydratation',
        message: 'Buvez au moins 8 verres d\'eau par jour pour rester bien hydraté.',
        color: TipColor.blue,
      ),
      const Tip(
        emoji: '🥬',
        title: '5 fruits et légumes',
        message: 'Mangez 5 portions de fruits et légumes par jour pour votre santé.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '🏃',
        title: 'Activité physique',
        message: 'Faites 30 minutes d\'activité physique par jour.',
        color: TipColor.orange,
      ),
      const Tip(
        emoji: '😴',
        title: 'Sommeil',
        message: '7-8 heures de sommeil aident à réguler votre appétit.',
        color: TipColor.purple,
      ),
      const Tip(
        emoji: '🧘',
        title: 'Gestion du stress',
        message: 'Le stress peut affecter votre alimentation. Prenez du temps pour vous.',
        color: TipColor.purple,
      ),
      const Tip(
        emoji: '🍎',
        title: 'Snacks sains',
        message: 'Gardez des fruits et noix à portée de main pour les fringales.',
        color: TipColor.green,
      ),
      const Tip(
        emoji: '📝',
        title: 'Suivi alimentaire',
        message: 'Noter vos repas aide à prendre conscience de votre alimentation.',
        color: TipColor.blue,
      ),
      const Tip(
        emoji: '🥗',
        title: 'Préparation',
        message: 'Préparer vos repas à l\'avance évite les choix impulsifs.',
        color: TipColor.green,
      ),
    ];
  }
}

/// Modèle pour un conseil
class Tip {
  final String emoji;
  final String title;
  final String message;
  final TipColor color;

  const Tip({
    required this.emoji,
    required this.title,
    required this.message,
    required this.color,
  });
}

/// Couleurs pour les conseils
enum TipColor { green, blue, orange, purple }

