import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/theme_provider.dart';

/// Helper pour créer des couleurs avec opacité de manière sûre
Color _colorWithAlpha(Color color, double opacity) {
  return Color.fromARGB(
    (opacity * 255).round().clamp(0, 255),
    color.red,
    color.green,
    color.blue,
  );
}

/// Bouton de changement de thème avec animation époustouflante
class ThemeToggleButton extends StatefulWidget {
  final double size;
  final bool showLabel;

  const ThemeToggleButton({
    super.key,
    this.size = 48,
    this.showLabel = false,
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme(ThemeProvider themeProvider) {
    _controller.forward(from: 0);
    themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final shadowColor = isDark ? const Color(0xFF311B92) : const Color(0xFFFF9800);

    return GestureDetector(
      onTap: () => _toggleTheme(themeProvider),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF311B92)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _colorWithAlpha(shadowColor, 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: _rotationAnimation.value * math.pi * 2,
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: widget.size * 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Version compacte du bouton de thème pour la barre de navigation
class CompactThemeToggle extends StatelessWidget {
  const CompactThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final shadowColor = isDark ? const Color(0xFF311B92) : const Color(0xFFFF9800);

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 32,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isDark
              ? const LinearGradient(
                  colors: [AppTheme.darkSurface, AppTheme.darkSurfaceLight],
                )
              : const LinearGradient(
                  colors: [AppTheme.surfaceGrey, AppTheme.surfaceWhite],
                ),
          border: Border.all(
            color: _colorWithAlpha(AppTheme.primaryGreen, isDark ? 0.3 : 0.2),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF311B92)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: _colorWithAlpha(shadowColor, 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card stylisée pour les fonctionnalités - VERSION SIMPLIFIÉE SANS ANIMATION DE GLOW
class FeatureIconCard extends StatefulWidget {
  final IconData icon;
  final String? emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Gradient? gradient;
  final VoidCallback onTap;
  final bool isWide;

  const FeatureIconCard({
    super.key,
    this.icon = Icons.star,
    this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    this.gradient,
    required this.onTap,
    this.isWide = false,
  });

  @override
  State<FeatureIconCard> createState() => _FeatureIconCardState();
}

class _FeatureIconCardState extends State<FeatureIconCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveGradient = widget.gradient ??
        LinearGradient(
          colors: [widget.color, _colorWithAlpha(widget.color, 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: EdgeInsets.all(widget.isWide ? 20 : 18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _colorWithAlpha(widget.color, isDark ? 0.3 : 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _colorWithAlpha(widget.color, isDark ? 0.15 : 0.1),
                blurRadius: 20,
                spreadRadius: isDark ? 2 : 0,
              ),
              if (!isDark)
                const BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
            ],
          ),
          child: widget.isWide
              ? _buildWideContent(effectiveGradient, isDark)
              : _buildCompactContent(effectiveGradient, isDark),
        ),
      ),
    );
  }

  Widget _buildCompactContent(Gradient gradient, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _colorWithAlpha(widget.color, 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.emoji != null
                ? Text(widget.emoji!, style: const TextStyle(fontSize: 28))
                : Icon(widget.icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: widget.color,
          ),
        ),
      ],
    );
  }

  Widget _buildWideContent(Gradient gradient, bool isDark) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _colorWithAlpha(widget.color, 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.emoji != null
                ? Text(widget.emoji!, style: const TextStyle(fontSize: 28))
                : Icon(widget.icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _colorWithAlpha(widget.color, isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: widget.color,
            size: 16,
          ),
        ),
      ],
    );
  }
}

/// Section de statistiques avec animation
class AnimatedStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double? progress;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _colorWithAlpha(color, isDark ? 0.3 : 0.15),
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _colorWithAlpha(color, isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              if (progress != null)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: _colorWithAlpha(color, 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      Center(
                        child: Text(
                          '${(progress! * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.darkTextTertiary : AppTheme.textLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

