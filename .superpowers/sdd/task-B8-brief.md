# Task B8: Testing

**Files:**
- Create: `frontend/test/auth_test.dart`

**Note:** Task B7 (Code Generation) must be complete before this task.

---

**Step 1: Create basic widget test**

Create `frontend/test/auth_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dntrip/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
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

    testWidgets('LoginScreen has working text fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your email'),
        'test@example.com',
      );
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Sign Up button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => LoginScreen(),
            ),
          ),
        ),
      );

      // Find Sign Up button
      final signUpButton = find.text('Sign Up');
      expect(signUpButton, findsOneWidget);

      // Verify it's a button
      final button = find.ancestor(
        of: signUpButton,
        matching: find.byType(TextButton),
      );
      expect(button, findsOneWidget);
    });
  });
}
```

---

**Step 2: Run widget tests**

Run:
```powershell
cd frontend && flutter test test/auth_test.dart
```

Expected: Tests pass

---

**Step 3: Create repository test (mocked)**

Create `frontend/test/auth_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dntrip/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('UserModel.fromJson parses correctly', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'created_at': '2026-07-03T10:00:00.000000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.createdAt, '2026-07-03T10:00:00.000000Z');
    });

    test('UserModel.toJson serializes correctly', () {
      const user = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        createdAt: '2026-07-03T10:00:00.000000Z',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['created_at'], '2026-07-03T10:00:00.000000Z');
    });
  });
}
```

---

**Step 4: Run repository tests**

Run:
```powershell
cd frontend && flutter test test/auth_repository_test.dart
```

Expected: Tests pass

---

**Step 5: Run all tests**

Run:
```powershell
cd frontend && flutter test
```

Expected: All tests pass
