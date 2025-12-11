class Constants {
  // Meal Types
  static const List<String> mealTypes = [
    'BREAKFAST',
    'LUNCH',
    'DINNER',
    'SNACK',
  ];

  static const Map<String, String> mealTypeLabels = {
    'BREAKFAST': 'Petit-déjeuner',
    'LUNCH': 'Déjeuner',
    'DINNER': 'Dîner',
    'SNACK': 'Collation',
  };

  static const Map<String, String> mealTypeIcons = {
    'BREAKFAST': '🌅',
    'LUNCH': '🌞',
    'DINNER': '🌙',
    'SNACK': '🍎',
  };

  // Diet Types
  static const Map<String, String> dietTypes = {
    'balanced': 'Équilibré',
    'high-protein': 'Riche en protéines',
    'low-carb': 'Faible en glucides',
    'low-fat': 'Faible en graisses',
  };

  // Health Labels
  static const Map<String, String> healthLabels = {
    'vegan': 'Végétalien',
    'vegetarian': 'Végétarien',
    'paleo': 'Paléo',
    'dairy-free': 'Sans produits laitiers',
    'gluten-free': 'Sans gluten',
  };

  // Common Allergies
  static const List<String> commonAllergies = [
    'peanuts',
    'tree-nuts',
    'milk',
    'eggs',
    'wheat',
    'soy',
    'fish',
    'shellfish',
  ];

  static const Map<String, String> allergyLabels = {
    'peanuts': 'Arachides',
    'tree-nuts': 'Fruits à coque',
    'milk': 'Lait',
    'eggs': 'Œufs',
    'wheat': 'Blé',
    'soy': 'Soja',
    'fish': 'Poisson',
    'shellfish': 'Crustacés',
  };

  // Error Messages
  static const String errorGeneric = 'Une erreur est survenue';
  static const String errorNetwork = 'Erreur de connexion réseau';
  static const String errorAuth = 'Authentification échouée';
  static const String errorTimeout = 'Délai d\'attente dépassé';
  static const String errorServer = 'Erreur serveur';
  static const String errorNotFound = 'Ressource non trouvée';

  // Success Messages
  static const String successLogin = 'Connexion réussie';
  static const String successRegister = 'Inscription réussie';
  static const String successMealCreated = 'Repas créé avec succès';
  static const String successMealUpdated = 'Repas mis à jour';
  static const String successMealDeleted = 'Repas supprimé';
  static const String successPlanGenerated = 'Plan généré avec succès';

  // Validation Messages
  static const String validationRequired = 'Ce champ est requis';
  static const String validationEmail = 'Email invalide';
  static const String validationPassword = 'Mot de passe trop court (min 6 caractères)';
  static const String validationUsername = 'Nom d\'utilisateur trop court (min 3 caractères)';
}

