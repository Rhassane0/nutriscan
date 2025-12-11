import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nutriscan_front/main.dart';
import 'package:nutriscan_front/services/api_service.dart';

void main() {
  testWidgets('NutriScan app smoke test', (WidgetTester tester) async {
    // Initialiser l'ApiService pour les tests
    final apiService = ApiService.instance;

    // Build our app and trigger a frame.
    await tester.pumpWidget(NutriScanApp(apiService: apiService));

    // Vérifier que l'écran de connexion est affiché
    expect(find.text('Connexion'), findsWidgets);
  });
}
