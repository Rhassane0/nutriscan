import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/meal_provider.dart';
import '../../config/theme.dart';
import '../../widgets/theme_widgets.dart';
import '../auth/login_screen.dart';
import '../recipes/recipe_search_screen.dart';
import '../tracking/weight_tracking_screen.dart';
import 'edit_profile_screen.dart';
import 'goals_screen.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les repas du jour pour les stats
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadMealsForDate(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final mealProvider = context.watch<MealProvider>();
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.user;

    // Calculer les stats
    final todayMeals = mealProvider.meals;
    final totalCalories = todayMeals.fold<double>(0, (sum, meal) => sum + (meal.totalCalories ?? 0));
    final mealCount = todayMeals.length;
    const targetCalories = 2000; // Valeur par défaut
    final progress = targetCalories > 0 ? ((totalCalories / targetCalories) * 100).clamp(0, 100).toInt() : 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryGreenSoft,
                    AppTheme.backgroundLight,
                  ],
                  stops: const [0.0, 0.4],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // En-tête profil
                _buildProfileHeader(user, isDark),

                const SizedBox(height: 24),

                // Stats rapides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildQuickStats(isDark, totalCalories.toInt(), mealCount, progress),
                ),

                const SizedBox(height: 24),

                // Menu principal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildMainMenu(context, isDark),
                ),

                const SizedBox(height: 16),

                // Paramètres d'apparence
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildAppearanceSection(context, themeProvider, isDark),
                ),

                const SizedBox(height: 16),

                // Paramètres de langue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildLanguageSection(context, isDark),
                ),

                const SizedBox(height: 16),

                // Autres options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildOtherOptions(context, isDark),
                ),

                const SizedBox(height: 24),

                // Bouton déconnexion
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildLogoutButton(context, authProvider, isDark),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.transparent,
          ),
          boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.mediumShadow,
        ),
        child: Column(
          children: [
            // Avatar avec glow
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGlowGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text('👤', style: TextStyle(fontSize: 52)),
              ),
            ),
            const SizedBox(height: 20),

            // Nom
            Text(
              user?.username ?? 'Utilisateur',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),

            // Email
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Badge membre avec glow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen.withOpacity(isDark ? 0.3 : 0.15),
                    AppTheme.primaryGreen.withOpacity(isDark ? 0.15 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.watch<LocaleProvider>().isFrench ? 'Membre NutriScan' : 'NutriScan Member',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isDark, int calories, int mealCount, int progress) {
    final localeProvider = context.watch<LocaleProvider>();
    final isFrench = localeProvider.isFrench;

    return Row(
      children: [
        Expanded(child: _buildStatCard('🔥', '$calories', isFrench ? 'Calories\naujourd\'hui' : 'Calories\ntoday', AppTheme.caloriesColor, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('📊', '$mealCount', isFrench ? 'Repas\nsuivis' : 'Meals\ntracked', AppTheme.accentBlue, isDark)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('🎯', '$progress%', isFrench ? 'Objectif\natteint' : 'Goal\nachieved', AppTheme.primaryGreen, isDark)),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.15),
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ThemeProvider themeProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF311B92)])
                      : const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF9800)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.watch<LocaleProvider>().isFrench ? 'Apparence' : 'Appearance',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      isDark
                        ? (context.watch<LocaleProvider>().isFrench ? 'Mode sombre activé' : 'Dark mode enabled')
                        : (context.watch<LocaleProvider>().isFrench ? 'Mode clair activé' : 'Light mode enabled'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const CompactThemeToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, bool isDark) {
    final localeProvider = context.watch<LocaleProvider>();
    final isFrench = localeProvider.isFrench;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFrench ? 'Langue' : 'Language',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      isFrench ? 'Français sélectionné' : 'English selected',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLanguageOption(
                  context,
                  flag: '🇫🇷',
                  label: 'Français',
                  isSelected: isFrench,
                  isDark: isDark,
                  onTap: () => localeProvider.setFrench(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLanguageOption(
                  context,
                  flag: '🇬🇧',
                  label: 'English',
                  isSelected: !isFrench,
                  isDark: isDark,
                  onTap: () => localeProvider.setEnglish(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String flag,
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1)
              : (isDark ? AppTheme.darkSurfaceLight : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : (isDark ? AppTheme.darkBorder : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : (isDark ? AppTheme.darkTextPrimary : Colors.grey[700]),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, bool isDark) {
    final localeProvider = context.watch<LocaleProvider>();
    final isFrench = localeProvider.isFrench;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            emoji: '👤',
            title: isFrench ? 'Informations personnelles' : 'Personal Information',
            subtitle: isFrench ? 'Modifier votre profil' : 'Edit your profile',
            color: AppTheme.accentBlue,
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: '🔍',
            title: isFrench ? 'Rechercher des recettes' : 'Search Recipes',
            subtitle: isFrench ? 'Trouvez de nouvelles idées' : 'Find new ideas',
            color: AppTheme.accentTeal,
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeSearchScreen())),
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: '⚖️',
            title: isFrench ? 'Suivi du poids' : 'Weight Tracking',
            subtitle: isFrench ? 'Suivez votre progression' : 'Track your progress',
            color: AppTheme.secondaryOrange,
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightTrackingScreen())),
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: '🎯',
            title: isFrench ? 'Objectifs nutritionnels' : 'Nutrition Goals',
            subtitle: isFrench ? 'Définir vos objectifs' : 'Set your goals',
            color: AppTheme.primaryGreen,
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: '🥗',
            title: isFrench ? 'Préférences alimentaires' : 'Food Preferences',
            subtitle: isFrench ? 'Allergies et restrictions' : 'Allergies and restrictions',
            color: AppTheme.accentPurple,
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherOptions(BuildContext context, bool isDark) {
    final localeProvider = context.watch<LocaleProvider>();
    final isFrench = localeProvider.isFrench;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.transparent,
        ),
        boxShadow: isDark ? AppTheme.darkSoftShadow : AppTheme.softShadow,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            emoji: '📜',
            title: isFrench ? 'Historique' : 'History',
            subtitle: isFrench ? 'Voir vos repas passés' : 'View your past meals',
            color: Colors.brown,
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: '⚙️',
            title: isFrench ? 'Paramètres' : 'Settings',
            subtitle: isFrench ? 'Notifications, langue...' : 'Notifications, language...',
            color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: '❓',
            title: isFrench ? 'Aide & Support' : 'Help & Support',
            subtitle: isFrench ? 'FAQ et contact' : 'FAQ and contact',
            color: AppTheme.accentBlue,
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            context,
            emoji: 'ℹ️',
            title: isFrench ? 'À propos' : 'About',
            subtitle: 'Version 1.0.0',
            color: isDark ? AppTheme.darkTextTertiary : AppTheme.textMedium,
            isDark: isDark,
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'NutriScan',
              applicationVersion: '1.0.0',
              applicationLegalese: isFrench
                  ? '© 2025 NutriScan\nVotre compagnon nutrition'
                  : '© 2025 NutriScan\nYour nutrition companion',
              applicationIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🥗', style: TextStyle(fontSize: 32)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: color,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppTheme.darkDivider : AppTheme.surfaceGrey,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider, bool isDark) {
    final isFrench = context.watch<LocaleProvider>().isFrench;

    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              isFrench ? 'Déconnexion' : 'Logout',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
              ),
            ),
            content: Text(
              isFrench ? 'Voulez-vous vraiment vous déconnecter ?' : 'Are you sure you want to log out?',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  isFrench ? 'Annuler' : 'Cancel',
                  style: TextStyle(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMedium,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  isFrench ? 'Déconnecter' : 'Logout',
                  style: const TextStyle(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.errorRed.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 22),
            const SizedBox(width: 12),
            Text(
              isFrench ? 'Se déconnecter' : 'Log out',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

