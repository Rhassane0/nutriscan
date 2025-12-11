import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr', 'FR');
  bool _isLoaded = false;

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isFrench => _locale.languageCode == 'fr';
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isLoaded => _isLoaded;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'fr';
      final countryCode = prefs.getString('country_code') ?? 'FR';
      _locale = Locale(languageCode, countryCode);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;

    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');
      debugPrint('✅ Locale saved: ${locale.languageCode}');
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  void setFrench() {
    debugPrint('🇫🇷 Setting French');
    setLocale(const Locale('fr', 'FR'));
  }

  void setEnglish() {
    debugPrint('🇬🇧 Setting English');
    setLocale(const Locale('en', 'US'));
  }

  void toggleLanguage() {
    if (isFrench) {
      setEnglish();
    } else {
      setFrench();
    }
  }
}

// Traductions
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
           AppLocalizations(const Locale('fr', 'FR'));
  }

  static final Map<String, Map<String, String>> _translations = {
    'fr': {
      // Navigation
      'home': 'Accueil',
      'meals': 'Repas',
      'scan': 'Scanner',
      'planner': 'Planificateur',
      'profile': 'Profil',

      // General
      'save': 'Sauvegarder',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'search': 'Rechercher',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'close': 'Fermer',
      'retry': 'Réessayer',

      // Auth
      'login': 'Connexion',
      'logout': 'Déconnexion',
      'register': 'Inscription',
      'email': 'Email',
      'password': 'Mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      'forgot_password': 'Mot de passe oublié ?',
      'no_account': 'Pas de compte ?',
      'have_account': 'Déjà un compte ?',

      // Profile
      'preferences': 'Préférences & Profil',
      'personal_info': 'Informations Personnelles',
      'your_goal': 'Votre Objectif',
      'activity_level': 'Niveau d\'Activité',
      'dietary_preferences': 'Régimes & Préférences',
      'allergies': 'Allergies',
      'height': 'Taille',
      'weight': 'Poids actuel',
      'age': 'Âge',
      'male': 'Homme',
      'female': 'Femme',
      'lose_weight': 'Perdre du poids',
      'maintain': 'Maintenir',
      'gain_weight': 'Prendre du poids',

      // Meals
      'breakfast': 'Petit-déjeuner',
      'lunch': 'Déjeuner',
      'dinner': 'Dîner',
      'snack': 'Collation',
      'add_meal': 'Ajouter un repas',
      'meal_journal': 'Journal alimentaire',
      'calories': 'Calories',
      'protein': 'Protéines',
      'carbs': 'Glucides',
      'fat': 'Lipides',

      // Scanner
      'scan_barcode': 'Scanner un code-barres',
      'scan_meal': 'Scanner un repas',
      'product_details': 'Détails du produit',
      'nutrition_info': 'Informations nutritionnelles',

      // Planner
      'meal_planner': 'Planificateur de repas',
      'generate_plan': 'Générer un plan',
      'grocery_list': 'Liste de courses',
      'weekly_plan': 'Plan hebdomadaire',

      // Recipes
      'search_recipes': 'Recherche de Recettes',
      'recipes_found': 'recettes trouvées',
      'ingredients': 'Ingrédients',
      'instructions': 'Instructions',
      'add_to_plan': 'Ajouter au plan',
      'view_details': 'Détails',

      // Weight Tracking
      'weight_tracking': 'Suivi du Poids',
      'add_weight': 'Ajouter une pesée',
      'weight_history': 'Historique',
      'bmi': 'IMC',

      // Settings
      'settings': 'Paramètres',
      'theme': 'Thème',
      'dark_mode': 'Mode sombre',
      'light_mode': 'Mode clair',
      'language': 'Langue',
      'french': 'Français',
      'english': 'Anglais',
      'notifications': 'Notifications',

      // Errors
      'no_results': 'Aucun résultat',
      'connection_error': 'Erreur de connexion',
      'try_again': 'Veuillez réessayer',
    },
    'en': {
      // Navigation
      'home': 'Home',
      'meals': 'Meals',
      'scan': 'Scan',
      'planner': 'Planner',
      'profile': 'Profile',

      // General
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'close': 'Close',
      'retry': 'Retry',

      // Auth
      'login': 'Login',
      'logout': 'Logout',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm password',
      'forgot_password': 'Forgot password?',
      'no_account': 'No account?',
      'have_account': 'Have an account?',

      // Profile
      'preferences': 'Preferences & Profile',
      'personal_info': 'Personal Information',
      'your_goal': 'Your Goal',
      'activity_level': 'Activity Level',
      'dietary_preferences': 'Dietary Preferences',
      'allergies': 'Allergies',
      'height': 'Height',
      'weight': 'Current weight',
      'age': 'Age',
      'male': 'Male',
      'female': 'Female',
      'lose_weight': 'Lose weight',
      'maintain': 'Maintain',
      'gain_weight': 'Gain weight',

      // Meals
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
      'add_meal': 'Add a meal',
      'meal_journal': 'Food journal',
      'calories': 'Calories',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fat': 'Fat',

      // Scanner
      'scan_barcode': 'Scan a barcode',
      'scan_meal': 'Scan a meal',
      'product_details': 'Product details',
      'nutrition_info': 'Nutrition information',

      // Planner
      'meal_planner': 'Meal Planner',
      'generate_plan': 'Generate a plan',
      'grocery_list': 'Grocery list',
      'weekly_plan': 'Weekly plan',

      // Recipes
      'search_recipes': 'Recipe Search',
      'recipes_found': 'recipes found',
      'ingredients': 'Ingredients',
      'instructions': 'Instructions',
      'add_to_plan': 'Add to plan',
      'view_details': 'Details',

      // Weight Tracking
      'weight_tracking': 'Weight Tracking',
      'add_weight': 'Add weight',
      'weight_history': 'History',
      'bmi': 'BMI',

      // Settings
      'settings': 'Settings',
      'theme': 'Theme',
      'dark_mode': 'Dark mode',
      'light_mode': 'Light mode',
      'language': 'Language',
      'french': 'French',
      'english': 'English',
      'notifications': 'Notifications',

      // Errors
      'no_results': 'No results',
      'connection_error': 'Connection error',
      'try_again': 'Please try again',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _translations[langCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  // Helper method for easy access
  String get(String key) => translate(key);
}

// Extension pour faciliter l'utilisation
extension TranslateExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this).translate(key);
  }
}

