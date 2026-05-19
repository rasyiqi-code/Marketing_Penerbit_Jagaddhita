import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketing_penerbit_jagaddhita/src/features/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/services/auth_service.dart';

void main() {
  testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<AuthService>(
          create: (_) => AuthService(),
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Penerbit Jagaddhita'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
  });
}
