import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════
  // 🛠️ HELPER FUNCTIONS
  // ═══════════════════════════════════════════════════════════════

  /// Crée une couleur avec opacité de manière sûre (évite les erreurs d'animation)
  static Color withAlpha(Color color, double opacity) {
    return Color.fromARGB(
      (opacity.clamp(0.0, 1.0) * 255).round(),
      color.red,
      color.green,
      color.blue,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎨 PALETTE DE COULEURS PRINCIPALE
  // ═══════════════════════════════════════════════════════════════

  // Verts - Couleur principale (santé & fraîcheur)
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color primaryGreenDark = Color(0xFF00A344);
  static const Color primaryGreenLight = Color(0xFF69F0AE);
  static const Color primaryGreenSoft = Color(0xFFE8F5E9);
  static const Color primaryGreenGlow = Color(0xFF00E676);

  // Oranges - Énergie & dynamisme
  static const Color secondaryOrange = Color(0xFFFF6F00);
  static const Color secondaryOrangeLight = Color(0xFFFF9E40);
  static const Color secondaryOrangeSoft = Color(0xFFFFF3E0);

  // Accents - Innovation & modernité
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentPurpleLight = Color(0xFFB388FF);
  static const Color accentPurpleSoft = Color(0xFFEDE7F6);

  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentBlueLight = Color(0xFF82B1FF);
  static const Color accentBlueSoft = Color(0xFFE3F2FD);

  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentTealLight = Color(0xFF64FFDA);
  static const Color accentTealSoft = Color(0xFFE0F2F1);

  // États
  static const Color errorRed = Color(0xFFE53935);
  static const Color errorRedLight = Color(0xFFFF8A80);
  static const Color successGreen = Color(0xFF00E676);
  static const Color warningYellow = Color(0xFFFFD600);
  static const Color warningYellowLight = Color(0xFFFFF59D);

  // ═══════════════════════════════════════════════════════════════
  // 🌞 COULEURS MODE CLAIR
  // ═══════════════════════════════════════════════════════════════

  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF5F5F5);
  static const Color surfaceGreyLight = Color(0xFFFAFAFA);

  static const Color textDark = Color(0xFF212121);
  static const Color textMedium = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // ═══════════════════════════════════════════════════════════════
  // 🌙 COULEURS MODE SOMBRE
  // ═══════════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF0D1F1B);
  static const Color darkBackgroundSecondary = Color(0xFF1A3A32);
  static const Color darkSurface = Color(0xFF162D27);
  static const Color darkSurfaceLight = Color(0xFF1E3F36);
  static const Color darkSurfaceElevated = Color(0xFF254A42);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkTextTertiary = Color(0xFF78909C);

  static const Color darkBorder = Color(0xFF2E5249);
  static const Color darkDivider = Color(0xFF263D36);

  // ═══════════════════════════════════════════════════════════════
  // 🎭 GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGlowGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, accentPurpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [secondaryOrange, secondaryOrangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [accentBlue, accentBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [accentTeal, accentTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient sombre élégant
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D1F1B),
      Color(0xFF1A3A32),
      Color(0xFF0F2922),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [darkSurfaceLight, darkSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════════════════════════════
  // 🏆 NUTRI-SCORE & ECO-SCORE
  // ═══════════════════════════════════════════════════════════════

  static const Map<String, Color> nutriScoreColors = {
    'A': Color(0xFF038141),
    'B': Color(0xFF85BB2F),
    'C': Color(0xFFFECB02),
    'D': Color(0xFFEE8100),
    'E': Color(0xFFE63E11),
  };

  static const Map<String, Color> ecoScoreColors = {
    'A': Color(0xFF038141),
    'B': Color(0xFF85BB2F),
    'C': Color(0xFFFECB02),
    'D': Color(0xFFEE8100),
    'E': Color(0xFFE63E11),
  };

  static Color getNutriScoreColor(String? score) {
    if (score == null) return Colors.grey;
    return nutriScoreColors[score.toUpperCase()] ?? Colors.grey;
  }

  static Color getEcoScoreColor(String? score) {
    if (score == null) return Colors.grey;
    return ecoScoreColors[score.toUpperCase()] ?? Colors.grey;
  }

  // ═══════════════════════════════════════════════════════════════
  // 🍎 COULEURS MACRONUTRIMENTS
  // ═══════════════════════════════════════════════════════════════

  static const Color caloriesColor = Color(0xFFFF7043);
  static const Color proteinColor = Color(0xFFEF5350);
  static const Color carbsColor = Color(0xFFFFB74D);
  static const Color fatColor = Color(0xFF66BB6A);
  static const Color fiberColor = Color(0xFF8D6E63);
  static const Color sugarColor = Color(0xFFE91E63);
  static const Color sodiumColor = Color(0xFF5C6BC0);

  // ═══════════════════════════════════════════════════════════════
  // 🌟 SHADOWS
  // ═══════════════════════════════════════════════════════════════

  static List<BoxShadow> softShadow = [
    const BoxShadow(
      color: Color(0x0D000000), // black with 5% opacity
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    const BoxShadow(
      color: Color(0x14000000), // black with 8% opacity
      blurRadius: 25,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> strongShadow = [
    const BoxShadow(
      color: Color(0x26000000), // black with 15% opacity
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> coloredShadow(Color color) => [
    BoxShadow(
      color: Color.fromARGB(77, color.red, color.green, color.blue), // 30% opacity
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: Color.fromARGB(102, color.red, color.green, color.blue), // 40% opacity
      blurRadius: 25,
      spreadRadius: 2,
    ),
  ];

  // Ombres pour le mode sombre
  static List<BoxShadow> darkSoftShadow = [
    const BoxShadow(
      color: Color(0x4D000000), // black with 30% opacity
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkGlowShadow(Color color) => [
    BoxShadow(
      color: Color.fromARGB(64, color.red, color.green, color.blue), // 25% opacity
      blurRadius: 30,
      spreadRadius: 2,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // 📐 BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  static const double radiusXXLarge = 32;
  static const double radiusRound = 100;

  // ═══════════════════════════════════════════════════════════════
  // ☀️ THÈME CLAIR
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: primaryGreenLight,
      secondary: secondaryOrange,
      onSecondary: Colors.white,
      secondaryContainer: secondaryOrangeLight,
      tertiary: accentPurple,
      error: errorRed,
      surface: surfaceWhite,
      onSurface: textDark,
      surfaceContainerHighest: surfaceGrey,
      outline: textLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: textDark, size: 24),
    ),
    textTheme: _buildTextTheme(textDark, textMedium),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(false),
    chipTheme: _buildChipTheme(false),
    bottomNavigationBarTheme: _buildBottomNavTheme(false),
    floatingActionButtonTheme: _buildFabTheme(),
    snackBarTheme: _buildSnackBarTheme(),
    bottomSheetTheme: _buildBottomSheetTheme(false),
    dividerTheme: const DividerThemeData(color: surfaceGrey, thickness: 1, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryGreen,
      linearTrackColor: primaryGreenSoft,
    ),
    cardTheme: CardThemeData(
      color: surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🌙 THÈME SOMBRE
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      onPrimary: Colors.white,
      primaryContainer: primaryGreenDark,
      secondary: secondaryOrange,
      onSecondary: Colors.white,
      secondaryContainer: secondaryOrangeLight,
      tertiary: accentPurple,
      error: errorRedLight,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkSurfaceElevated,
      outline: darkBorder,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: darkTextPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
        letterSpacing: 0.5,
      ),
      iconTheme: const IconThemeData(color: darkTextPrimary, size: 24),
    ),
    textTheme: _buildTextTheme(darkTextPrimary, darkTextSecondary),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(true),
    chipTheme: _buildChipTheme(true),
    bottomNavigationBarTheme: _buildBottomNavTheme(true),
    floatingActionButtonTheme: _buildFabTheme(),
    snackBarTheme: _buildSnackBarTheme(),
    bottomSheetTheme: _buildBottomSheetTheme(true),
    dividerTheme: const DividerThemeData(color: darkDivider, thickness: 1, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryGreen,
      linearTrackColor: primaryGreen.withOpacity(0.2),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // 🛠️ HELPERS DE CONSTRUCTION DES THÈMES
  // ═══════════════════════════════════════════════════════════════

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w700, color: primary, height: 1.12),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w700, color: primary, height: 1.16),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, color: primary, height: 1.22),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: primary, height: 1.25),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: primary, height: 1.29),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primary, height: 1.33),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary, height: 1.27),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary, height: 1.50, letterSpacing: 0.15),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, height: 1.43, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.50, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.43, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.33, letterSpacing: 0.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary, height: 1.43, letterSpacing: 0.1),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary, height: 1.33, letterSpacing: 0.5),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary, height: 1.45, letterSpacing: 0.5),
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
        side: const BorderSide(color: primaryGreen, width: 2),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(bool isDark) {
    final fillColor = isDark ? darkSurfaceLight : surfaceWhite;
    final borderColor = isDark ? darkBorder : const Color(0xFFE0E0E0);
    final labelColor = isDark ? darkTextSecondary : textMedium;
    final hintColor = isDark ? darkTextTertiary : textLight;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor),
      hintStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: hintColor),
      errorStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: errorRed),
    );
  }

  static ChipThemeData _buildChipTheme(bool isDark) {
    return ChipThemeData(
      backgroundColor: isDark ? darkSurfaceLight : surfaceGrey,
      selectedColor: isDark ? primaryGreen.withOpacity(0.3) : primaryGreenSoft,
      labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusRound)),
    );
  }

  static BottomNavigationBarThemeData _buildBottomNavTheme(bool isDark) {
    return BottomNavigationBarThemeData(
      backgroundColor: isDark ? darkSurface : surfaceWhite,
      elevation: 8,
      selectedItemColor: primaryGreen,
      unselectedItemColor: isDark ? darkTextTertiary : textLight,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      type: BottomNavigationBarType.fixed,
    );
  }

  static FloatingActionButtonThemeData _buildFabTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge)),
    );
  }

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMedium)),
      contentTextStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  static BottomSheetThemeData _buildBottomSheetTheme(bool isDark) {
    return BottomSheetThemeData(
      backgroundColor: isDark ? darkSurface : surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎁 DECORATIONS HELPERS
  // ═══════════════════════════════════════════════════════════════

  static BoxDecoration cardDecoration(bool isDark) => BoxDecoration(
    color: isDark ? darkSurface : surfaceWhite,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: isDark ? darkSoftShadow : softShadow,
  );

  static BoxDecoration glassDecoration(bool isDark) => BoxDecoration(
    color: isDark
        ? darkSurface.withOpacity(0.8)
        : surfaceWhite.withOpacity(0.9),
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.white.withOpacity(0.5),
    ),
    boxShadow: isDark ? darkSoftShadow : softShadow,
  );

  static BoxDecoration gradientCardDecoration(Gradient gradient, {bool isDark = false}) => BoxDecoration(
    gradient: gradient,
    borderRadius: BorderRadius.circular(radiusXLarge),
    boxShadow: isDark ? darkSoftShadow : mediumShadow,
  );

  // Décoration avec glow effect
  static BoxDecoration glowDecoration(Color color, {bool isDark = false}) => BoxDecoration(
    color: isDark ? darkSurface : surfaceWhite,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: color.withOpacity(0.3)),
    boxShadow: glowShadow(color),
  );
}
