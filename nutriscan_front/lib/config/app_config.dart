class AppConfig {
  // Configuration API
  // Pour Web (Chrome, Edge) et développement local
  static const String baseUrl = 'http://localhost:8082/api';

  // Pour émulateur Android, décommentez cette ligne :
  // static const String baseUrl = 'http://10.0.2.2:8082/api';

  // Pour iOS Simulator, décommentez cette ligne :
  // static const String baseUrl = 'http://localhost:8082/api';

  // Pour device physique (remplacez par votre IP locale) :
  // static const String baseUrl = 'http://192.168.1.X:8082/api';

  // Endpoints
  static const String authEndpoint = '/auth';
  static const String foodsEndpoint = '/foods';
  static const String mealsEndpoint = '/meals';
  static const String aiEndpoint = '/ai';
  static const String mealPlannerEndpoint = '/meal-planner';
  static const String groceryListEndpoint = '/grocery-list';
  static const String recipesEndpoint = '/recipes';
  static const String nutritionEndpoint = '/nutrition';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // App Info
  static const String appName = 'NutriScan';
  static const String appVersion = '1.0.0';
}

