# Task B2: Core Infrastructure

**Files:**
- Create: `frontend/lib/core/constants/app_constants.dart`
- Create: `frontend/lib/core/storage/hive_storage.dart`
- Create: `frontend/lib/core/api/api_exception.dart`
- Create: `frontend/lib/core/api/api_endpoints.dart`
- Create: `frontend/lib/core/api/api_interceptor.dart`
- Create: `frontend/lib/core/api/api_client.dart`
- Create: `frontend/lib/core/theme/app_theme.dart`
- Create: `frontend/lib/core/router/app_router.dart`

**Interfaces:**
- Consumes: Hive, Dio
- Produces: ApiClient singleton, HiveStorage singleton, AppRouter

**Note:** Task B1 (Flutter project setup) must be complete before this task.

---

**Step 1: Create AppConstants**

Create `frontend/lib/core/constants/app_constants.dart`:
```dart
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Hive boxes
  static const String authBox = 'auth_box';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
```

---

**Step 2: Create HiveStorage**

Create `frontend/lib/core/storage/hive_storage.dart`:
```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveStorage {
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.authBox);
  }

  // Token operations
  Future<void> saveToken(String token) async {
    await _box.put(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _box.get(AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _box.delete(AppConstants.tokenKey);
  }

  // User operations
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.put(AppConstants.userKey, user);
  }

  Map<String, dynamic>? getUser() {
    final user = _box.get(AppConstants.userKey);
    if (user != null) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  Future<void> clearUser() async {
    await _box.delete(AppConstants.userKey);
  }

  // Clear all auth data
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Check if logged in
  bool isLoggedIn() {
    return getToken() != null;
  }
}
```

---

**Step 3: Create ApiException**

Create `frontend/lib/core/api/api_exception.dart`:
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response.data;
      final statusCode = error.response.statusCode;

      // Handle validation errors (422)
      if (statusCode == 422 && data is Map<String, dynamic>) {
        return ApiException(
          message: data['message'] ?? 'Validation failed',
          statusCode: statusCode,
          errors: data['errors'] != null
              ? Map<String, dynamic>.from(data['errors'])
              : null,
        );
      }

      // Handle unauthorized (401)
      if (statusCode == 401) {
        return ApiException(
          message: 'Session expired. Please login again.',
          statusCode: statusCode,
        );
      }

      // Handle server error (500)
      if (statusCode == 500) {
        return ApiException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      }

      // Generic error
      return ApiException(
        message: data['message'] ?? 'Something went wrong',
        statusCode: statusCode,
      );
    }

    // Network error
    return ApiException(message: 'No internet connection');
  }

  @override
  String toString() => message;
}
```

---

**Step 4: Create ApiEndpoints**

Create `frontend/lib/core/api/api_endpoints.dart`:
```dart
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
}
```

---

**Step 5: Create AuthInterceptor**

Create `frontend/lib/core/api/api_interceptor.dart`:
```dart
import 'package:dio/dio.dart';
import '../storage/hive_storage.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final HiveStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip token injection for public auth endpoints
    final publicEndpoints = [
      AppConstants.baseUrl + '/register',
      AppConstants.baseUrl + '/login',
    ];

    if (publicEndpoints.contains(options.uri.toString())) {
      return handler.next(options);
    }

    final token = _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid - clear storage
      _storage.clearAll();
    }
    return handler.next(err);
  }
}
```

---

**Step 6: Create ApiClient**

Create `frontend/lib/core/api/api_client.dart`:
```dart
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/hive_storage.dart';
import 'api_interceptor.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  final HiveStorage _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'data': data};
  }
}
```

---

**Step 7: Create AppTheme**

Create `frontend/lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // Material Blue
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

---

**Step 8: Create AppRouter (placeholder)**

Create `frontend/lib/core/router/app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home - Setup pending')),
        ),
      ),
    ],
  );
}
```

---

**Step 9: Verify imports**

Create a simple test file to verify all imports work:
```dart
// frontend/lib/core/test_imports.dart
import 'constants/app_constants.dart';
import 'storage/hive_storage.dart';
import 'api/api_exception.dart';
import 'api/api_endpoints.dart';
import 'api/api_client.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

void main() {
  print('All imports successful');
}
```

Run:
```powershell
cd frontend && flutter analyze lib/core/
```

Expected: No import errors
