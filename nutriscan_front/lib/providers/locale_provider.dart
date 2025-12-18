import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/date_formatter.dart';

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
      _updateDateFormatterLocale();
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  void _updateDateFormatterLocale() {
    DateFormatter.setLocale(isFrench ? 'fr_FR' : 'en_US');
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;

    _locale = locale;
    _updateDateFormatterLocale();
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

      // Greetings
      'good_morning': 'Bonjour',
      'good_afternoon': 'Bon après-midi',
      'good_evening': 'Bonsoir',
      'eat_healthy': 'Mangez sainement !',
      'user': 'Utilisateur',

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
      'today': 'Aujourd\'hui',
      'yesterday': 'Hier',
      'tomorrow': 'Demain',
      'confirm': 'Confirmer',
      'back': 'Retour',
      'next': 'Suivant',
      'done': 'Terminé',
      'see_all': 'Voir tout',
      'no_data': 'Aucune donnée',

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

      // Dashboard
      'quick_actions': 'Actions Rapides',
      'daily_progress': 'Progression du Jour',
      'tip_of_day': 'Conseil du jour',
      'add_consumed_meal': 'Ajouter un repas consommé',
      'search_recipes': 'Rechercher des recettes',
      'view_grocery_list': 'Voir la liste de courses',
      'consumed': 'Consommé',
      'objective': 'Objectif',
      'remaining': 'Restant',
      'my_meals': 'Mes Repas',
      'plan_week': 'Planifier',
      'shopping': 'Courses',
      'list': 'Liste',
      'week': 'Semaine',
      'barcode': 'Code-barres',
      'find_meal_ideas': 'Trouvez de nouvelles idées de repas',

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
      'no_meals_today': 'Aucun repas enregistré aujourd\'hui',
      'meal_added': 'Repas ajouté avec succès',
      'meal_deleted': 'Repas supprimé',

      // Scanner
      'scan_barcode': 'Scanner un code-barres',
      'scan_meal': 'Scanner un repas',
      'product_details': 'Détails du produit',
      'nutrition_info': 'Informations nutritionnelles',
      'take_photo': 'Prendre une photo',
      'upload_photo': 'Importer une photo',
      'analyzing': 'Analyse en cours...',
      'scan_result': 'Résultat du scan',
      'smart_scanner': 'Scanner intelligent',
      'scan_barcode_title': 'Scanner un Code-Barres',
      'scan_meal_title': 'Analyser un Repas',
      'barcode_description': 'Scannez le code-barres d\'un produit alimentaire',
      'meal_photo_description': 'Prenez ou importez une photo de votre repas',

      // Planner
      'meal_planner': 'Planificateur de repas',
      'generate_plan': 'Générer un plan',
      'grocery_list': 'Liste de courses',
      'weekly_plan': 'Plan hebdomadaire',
      'add_to_consumed': 'Ajouter aux repas consommés',
      'generate_new_plan': 'Générer un nouveau plan',
      'no_plan': 'Aucun plan généré',

      // Recipes
      'recipe_search': 'Recherche de Recettes',
      'recipes_found': 'recettes trouvées',
      'ingredients': 'Ingrédients',
      'instructions': 'Instructions',
      'add_to_plan': 'Ajouter au plan',
      'view_details': 'Détails',
      'no_recipes_found': 'Aucune recette trouvée',
      'search_placeholder': 'Rechercher une recette...',
      'clear': 'Effacer',
      'oops_error': 'Oups ! Une erreur est survenue',
      'searching_recipes': 'Recherche de recettes...',
      'popular_searches': 'Recherches populaires',
      'start_search': 'Commencez votre recherche',
      'enter_search_term': 'Entrez un terme pour rechercher',
      'all_diets': 'Tous',
      'balanced': 'Équilibré',
      'high_protein': 'Riche en protéines',
      'low_carb': 'Faible en glucides',
      'low_fat': 'Faible en gras',
      'vegetarian': 'Végétarien',
      'vegan': 'Végan',
      'gluten_free': 'Sans gluten',
      'dairy_free': 'Sans lactose',
      'peanut_free': 'Sans arachides',
      'tree_nut_free': 'Sans fruits à coque',
      'filters': 'Filtres',
      'diet_type': 'Type de régime',
      'health_labels': 'Labels santé',
      'max_calories': 'Calories max',
      'apply_filters': 'Appliquer les filtres',
      'calories_per_serving': 'calories par portion',
      'servings': 'portions',
      'view_recipe': 'Voir la recette',

      // Weight Tracking
      'weight_tracking': 'Suivi du Poids',
      'add_weight': 'Ajouter une pesée',
      'weight_history': 'Historique',
      'bmi': 'IMC',
      'current_weight': 'Poids actuel',
      'target_weight': 'Poids cible',
      'weight_progress': 'Progression',

      // Settings
      'settings': 'Paramètres',
      'theme': 'Thème',
      'dark_mode': 'Mode sombre',
      'light_mode': 'Mode clair',
      'language': 'Langue',
      'french': 'Français',
      'english': 'Anglais',
      'notifications': 'Notifications',

      // Planner Screen
      'meal_planner_title': 'Planificateur',
      'meal_planner_subtitle': 'de Repas',
      'no_meal_plan': 'Aucun plan de repas',
      'create_first_plan': 'Créez votre premier plan hebdomadaire\npersonnalisé avec l\'IA',
      'create_plan': 'Créer un plan',
      'new_plan': 'Nouveau plan',
      'generate_grocery_list': 'Générer liste de courses',
      'meals_count': 'repas',
      'delete_plan': 'Supprimer le plan',
      'delete_plan_confirm': 'Voulez-vous vraiment supprimer ce plan de repas ? Cette action est irréversible.',
      'weekly': 'Hebdomadaire',
      'daily': 'Quotidien',
      'balanced_plan': 'Plan équilibré',

      // Meals Screen
      'consumed_foods': 'Aliments consommés',
      'food_item': 'aliment',
      'food_items': 'aliments',
      'view_analysis': 'Voir l\'analyse',
      'no_meals_recorded': 'Aucun repas enregistré',
      'add_first_meal': 'Ajoutez votre premier repas\npour commencer le suivi',
      'daily_summary': 'Résumé du jour',

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

      // Greetings
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'eat_healthy': 'Eat healthy!',
      'user': 'User',

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
      'today': 'Today',
      'yesterday': 'Yesterday',
      'tomorrow': 'Tomorrow',
      'confirm': 'Confirm',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'see_all': 'See all',
      'no_data': 'No data',

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

      // Dashboard
      'quick_actions': 'Quick Actions',
      'daily_progress': 'Daily Progress',
      'tip_of_day': 'Tip of the day',
      'add_consumed_meal': 'Add a consumed meal',
      'search_recipes': 'Search recipes',
      'view_grocery_list': 'View grocery list',
      'consumed': 'Consumed',
      'objective': 'Objective',
      'remaining': 'Remaining',
      'my_meals': 'My Meals',
      'plan_week': 'Plan',
      'shopping': 'Shopping',
      'list': 'List',
      'week': 'Week',
      'barcode': 'Barcode',
      'find_meal_ideas': 'Find new meal ideas',

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


      // Planner
      'meal_planner': 'Meal Planner',
      'generate_plan': 'Generate a plan',
      'grocery_list': 'Grocery list',
      'weekly_plan': 'Weekly plan',

      // Recipes
      'recipe_search': 'Recipe Search',
      'recipes_found': 'recipes found',
      'ingredients': 'Ingredients',
      'instructions': 'Instructions',
      'add_to_plan': 'Add to plan',
      'view_details': 'Details',
      'no_recipes_found': 'No recipes found',
      'search_placeholder': 'Search a recipe...',
      'clear': 'Clear',
      'oops_error': 'Oops! An error occurred',
      'searching_recipes': 'Searching recipes...',
      'popular_searches': 'Popular searches',
      'start_search': 'Start your search',
      'enter_search_term': 'Enter a term to search',
      'all_diets': 'All',
      'balanced': 'Balanced',
      'high_protein': 'High Protein',
      'low_carb': 'Low Carb',
      'low_fat': 'Low Fat',
      'vegetarian': 'Vegetarian',
      'vegan': 'Vegan',
      'gluten_free': 'Gluten Free',
      'dairy_free': 'Dairy Free',
      'peanut_free': 'Peanut Free',
      'tree_nut_free': 'Tree Nut Free',
      'filters': 'Filters',
      'diet_type': 'Diet Type',
      'health_labels': 'Health Labels',
      'max_calories': 'Max Calories',
      'apply_filters': 'Apply Filters',
      'calories_per_serving': 'calories per serving',
      'servings': 'servings',
      'view_recipe': 'View Recipe',

      // Weight Tracking
      'weight_tracking': 'Weight Tracking',
      'add_weight': 'Add weight',
      'weight_history': 'History',
      'bmi': 'BMI',
      'current_weight': 'Current weight',
      'target_weight': 'Target weight',
      'weight_progress': 'Progress',

      // Scanner (complet)
      'scan_barcode': 'Scan a barcode',
      'scan_meal': 'Scan a meal',
      'product_details': 'Product details',
      'nutrition_info': 'Nutrition information',
      'take_photo': 'Take a photo',
      'upload_photo': 'Upload a photo',
      'analyzing': 'Analyzing...',
      'scan_result': 'Scan result',
      'smart_scanner': 'Smart Scanner',
      'scan_barcode_title': 'Scan a Barcode',
      'scan_meal_title': 'Analyze a Meal',
      'barcode_description': 'Scan the barcode of a food product',
      'meal_photo_description': 'Take or upload a photo of your meal',

      // Planner extras
      'add_to_consumed': 'Add to consumed meals',
      'generate_new_plan': 'Generate new plan',
      'no_plan': 'No plan generated',
      'no_meals_today': 'No meals recorded today',
      'meal_added': 'Meal added successfully',
      'meal_deleted': 'Meal deleted',

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

      // Planner Screen
      'meal_planner_title': 'Meal',
      'meal_planner_subtitle': 'Planner',
      'no_meal_plan': 'No meal plan',
      'create_first_plan': 'Create your first weekly plan\npersonalized with AI',
      'create_plan': 'Create plan',
      'new_plan': 'New plan',
      'generate_grocery_list': 'Generate grocery list',
      'meals_count': 'meals',
      'delete_plan': 'Delete plan',
      'delete_plan_confirm': 'Are you sure you want to delete this plan?',
      'weekly': 'Weekly',
      'daily': 'Daily',
      'balanced_plan': 'Balanced plan',

      // Meals Screen
      'consumed_foods': 'Consumed foods',
      'food_item': 'item',
      'food_items': 'items',
      'view_analysis': 'View analysis',
      'no_meals_recorded': 'No meals recorded',
      'add_first_meal': 'Add your first meal\nto start tracking',
      'daily_summary': 'Daily Summary',
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
  /// Traduit une clé en utilisant la locale actuelle
  /// Écoute les changements de locale pour reconstruire automatiquement
  String tr(String key) {
    final localeProvider = Provider.of<LocaleProvider>(this, listen: true);
    return AppLocalizations(localeProvider.locale).translate(key);
  }

  /// Version sans écoute (pour callbacks, initState, etc.)
  String trStatic(String key) {
    final localeProvider = Provider.of<LocaleProvider>(this, listen: false);
    return AppLocalizations(localeProvider.locale).translate(key);
  }
}

// Delegate pour les localisations personnalisées
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

