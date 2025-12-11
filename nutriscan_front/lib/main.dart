import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/food_service.dart';
import 'services/ai_service.dart';
import 'services/meal_service.dart';
import 'services/meal_planner_service.dart';
import 'services/grocery_service.dart';
import 'services/weight_tracking_service.dart';
import 'services/goals_service.dart';
import 'services/user_service.dart';
import 'providers/auth_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/planner_provider.dart';
import 'providers/weight_tracking_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les formats de date pour éviter LocaleDataException
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);

  // Initialiser le service API
  final apiService = ApiService.instance;
  await apiService.init();

  runApp(NutriScanApp(apiService: apiService));
}

class NutriScanApp extends StatelessWidget {
  final ApiService apiService;

  const NutriScanApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider - doit être en premier pour être accessible partout
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        // Locale Provider - pour le changement de langue
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),

        // Services
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>(
          create: (_) => AuthService(apiService),
        ),
        Provider<FoodService>(
          create: (_) => FoodService(apiService),
        ),
        Provider<AiService>(
          create: (_) => AiService(apiService),
        ),
        Provider<MealService>(
          create: (_) => MealService(apiService),
        ),
        Provider<MealPlannerService>(
          create: (_) => MealPlannerService(apiService),
        ),
        Provider<GroceryService>(
          create: (_) => GroceryService(apiService),
        ),
        Provider<WeightTrackingService>(
          create: (_) => WeightTrackingService(apiService),
        ),
        Provider<GoalsService>(
          create: (_) => GoalsService(apiService),
        ),
        Provider<UserService>(
          create: (_) => UserService(apiService),
        ),

        // Providers avec état
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<MealProvider>(
          create: (context) => MealProvider(
            context.read<MealService>(),
          ),
        ),
        ChangeNotifierProvider<PlannerProvider>(
          create: (context) => PlannerProvider(
            context.read<MealPlannerService>(),
            context.read<GroceryService>(),
          ),
        ),
        ChangeNotifierProvider<WeightTrackingProvider>(
          create: (context) => WeightTrackingProvider(
            context.read<WeightTrackingService>(),
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'NutriScan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
