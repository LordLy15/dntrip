# Task B6: App Entry Points

**Files:**
- Modify: `frontend/lib/main.dart`
- Modify: `frontend/lib/app.dart`
- Update: `frontend/lib/core/router/app_router.dart`

**Interfaces:**
- Produces: Entry point with ProviderScope, MaterialApp with router

**Note:** Task B5 (Auth Presentation) must be complete before this task.

---

**Step 1: Update main.dart with Hive initialization**

Edit `frontend/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_storage.dart';
import 'app.dart';
import 'features/auth/domain/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  final storage = HiveStorage();
  await storage.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveStorageProvider.overrideWithValue(storage),
      ],
      child: const DNTripApp(),
    ),
  );
}
```

---

**Step 2: Create app.dart**

Create `frontend/lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class DNTripApp extends ConsumerWidget {
  const DNTripApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DNTrip',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

**Step 3: Update app_router.dart with full routing**

Edit `frontend/lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/domain/auth_providers.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (state) => state is Authenticated,
        orElse: () => false,
      );
      final isOnAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isOnAuthRoute && state.matchedLocation != '/') {
        return '/login';
      }

      if (isLoggedIn && isOnAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePlaceholder(),
      ),
    ],
  );
}

// Temporary home placeholder
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DNTrip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home Screen (TBD - Epic 2)')),
    );
  }
}
```

---

**Step 4: Verify main.dart and app.dart compile**

Run:
```powershell
cd frontend && flutter analyze lib/main.dart lib/app.dart
```

Expected: No errors
