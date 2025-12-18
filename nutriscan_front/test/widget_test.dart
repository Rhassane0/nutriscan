import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriscan_front/main.dart';
import 'package:nutriscan_front/services/api_service.dart';

void main() {
  testWidgets('NutriScan app builds MaterialApp', (WidgetTester tester) async {
    final apiService = ApiService.instance;
    await tester.pumpWidget(NutriScanApp(apiService: apiService));
    // Allow one frame to build; avoid pumpAndSettle to prevent waiting on async initializers
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
