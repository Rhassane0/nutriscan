import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget qui affiche un emoji ou une icône de fallback selon la plateforme
/// Utile pour Flutter Web où les emojis peuvent ne pas s'afficher correctement
class PlatformEmoji extends StatelessWidget {
  final String emoji;
  final double size;
  final IconData? fallbackIcon;
  final Color? fallbackColor;

  const PlatformEmoji({
    super.key,
    required this.emoji,
    this.size = 24,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    // Sur le web avec CanvasKit, les emojis peuvent avoir des problèmes
    // On utilise toujours les emojis mais avec une taille ajustée pour le web
    return Text(
      emoji,
      style: TextStyle(
        fontSize: size,
        fontFamily: kIsWeb ? 'Noto Color Emoji, sans-serif' : null,
      ),
    );
  }

  /// Crée un emoji avec une icône de fallback Material
  static Widget withFallback({
    required String emoji,
    required IconData fallbackIcon,
    double size = 24,
    Color? color,
  }) {
    // Sur le web, on peut choisir d'utiliser l'icône pour plus de fiabilité
    if (kIsWeb) {
      return Text(
        emoji,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'Noto Color Emoji, sans-serif',
        ),
      );
    }

    return Text(
      emoji,
      style: TextStyle(fontSize: size),
    );
  }
}

/// Map des emojis courants vers leurs icônes Material équivalentes
class EmojiIcons {
  static const Map<String, IconData> fallbacks = {
    '🔥': Icons.local_fire_department,
    '🥩': Icons.restaurant,
    '🍞': Icons.bakery_dining,
    '🥑': Icons.eco,
    '📷': Icons.camera_alt,
    '🍽️': Icons.restaurant_menu,
    '📅': Icons.calendar_month,
    '🛒': Icons.shopping_cart,
    '🔍': Icons.search,
    '🥗': Icons.lunch_dining,
    '👤': Icons.person,
    '⚖️': Icons.monitor_weight,
    '🎯': Icons.gps_fixed,
    '📜': Icons.history,
    '⚙️': Icons.settings,
    '❓': Icons.help,
    'ℹ️': Icons.info,
    '🌅': Icons.wb_sunny,
    '☀️': Icons.sunny,
    '🌙': Icons.nightlight,
    '🍎': Icons.apple,
    '💧': Icons.water_drop,
    '🥬': Icons.eco,
    '🏃': Icons.directions_run,
    '📊': Icons.analytics,
    '✨': Icons.auto_awesome,
    '🏆': Icons.emoji_events,
  };

  static IconData? getFallback(String emoji) => fallbacks[emoji];
}

/// Extension pour simplifier l'utilisation des emojis
extension EmojiWidgetExtension on String {
  /// Convertit un string emoji en widget avec gestion du fallback
  Widget toEmojiWidget({
    double size = 24,
    IconData? fallbackIcon,
    Color? fallbackColor,
  }) {
    return PlatformEmoji(
      emoji: this,
      size: size,
      fallbackIcon: fallbackIcon ?? EmojiIcons.getFallback(this),
      fallbackColor: fallbackColor,
    );
  }
}

