import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dntrip/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays all UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify key UI elements
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign in to continue your trip'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
