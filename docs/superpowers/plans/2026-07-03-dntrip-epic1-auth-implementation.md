# DNTrip Epic 1: User Authentication - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement complete user authentication system with Laravel Sanctum backend and Flutter frontend

**Architecture:** 
- Backend: Laravel 10 with Sanctum for API token authentication
- Frontend: Flutter with Riverpod codegen, Feature-First architecture, Hive for local storage
- Project structure: Monorepo with `backend/` and `frontend/` directories

**Tech Stack:** Laravel 10, Sanctum 3.3, Flutter 3.x, Riverpod 2.x, Dio 5.x, go_router 13.x, Hive 2.x, freezed

---

## Global Constraints

- Laravel version: ^10.0
- Sanctum version: ^3.3
- Flutter Riverpod: ^2.4.9
- Riverpod codegen: ^2.3.9
- Dio: ^5.4.0
- go_router: ^13.0.0
- Hive: ^2.2.3
- freezed: ^2.4.6
- API base URL: http://10.0.2.2:8000/api (Android emulator)
- Response format: `{ "status": "success"|"error", "data": {...}, "message": "..." }`

---

## Part A: Backend (Laravel + Sanctum)

### Task A1: Setup Laravel Project with Sanctum

**Files:**
- Create: `backend/` (Laravel project directory)
- Modify: `backend/.env`
- Modify: `backend/app/Models/User.php`
- Modify: `backend/routes/api.php`
- Create: `backend/app/Http/Controllers/Api/AuthController.php`
- Create: `backend/app/Http/Requests/RegisterRequest.php`
- Create: `backend/app/Http/Requests/LoginRequest.php`

**Interfaces:**
- Produces: API endpoints `/api/register`, `/api/login`, `/api/logout`, `/api/user`

---

- [ ] **Step 1: Create Laravel project**

Run in PowerShell (from `c:\xampp\htdocs\DNTrip`):
```powershell
composer create-project laravel/laravel backend "^10.0"
```

Expected: Laravel project created in `backend/` directory

---

- [ ] **Step 2: Install Sanctum**

Run in PowerShell (from `c:\xampp\htdocs\DNTrip\backend`):
```powershell
composer require laravel/sanctum "^3.3"
```

Expected: Sanctum installed successfully

---

- [ ] **Step 3: Publish Sanctum migrations**

Run:
```powershell
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

Expected: Migrations published to `database/migrations/`

---

- [ ] **Step 4: Configure .env**

Edit `backend/.env`:
```env
APP_NAME=DNTrip
APP_ENV=local
APP_KEY=base64:GENERATED_KEY_HERE
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dntrip
DB_USERNAME=root
DB_PASSWORD=

SANCTUM_STATEFUL_DOMAINS=localhost:8000
```

Run to generate APP_KEY:
```powershell
php artisan key:generate
```

---

- [ ] **Step 5: Update User model with HasApiTokens**

Edit `backend/app/Models/User.php`:
```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
}
```

---

- [ ] **Step 6: Create RegisterRequest validation**

Create `backend/app/Http/Requests/RegisterRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'Name is required',
            'name.min' => 'Name must be at least 2 characters',
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'email.unique' => 'Email has already been taken',
            'password.required' => 'Password is required',
            'password.min' => 'Password must be at least 8 characters',
            'password.confirmed' => 'Password confirmation does not match',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

- [ ] **Step 7: Create LoginRequest validation**

Create `backend/app/Http/Requests/LoginRequest.php`:
```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'email.required' => 'Email is required',
            'email.email' => 'Invalid email format',
            'password.required' => 'Password is required',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(response()->json([
            'status' => 'error',
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
        ], 422));
    }
}
```

---

- [ ] **Step 8: Create AuthController**

Create `backend/app/Http/Controllers/Api/AuthController.php`:
```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => $request->password, // Auto-hashed by $casts in model
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at->toISOString(),
                ],
                'token' => $token,
            ],
            'message' => 'Registration successful',
        ], 201);
    }

    /**
     * Login user
     */
    public function login(LoginRequest $request): JsonResponse
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'status' => 'error',
                'message' => 'Invalid credentials',
            ], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at->toISOString(),
                ],
                'token' => $token,
            ],
            'message' => 'Login successful',
        ]);
    }

    /**
     * Logout user (revoke token)
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logged out successfully',
        ]);
    }

    /**
     * Get current user
     */
    public function user(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'created_at' => $user->created_at->toISOString(),
                ],
            ],
        ]);
    }
}
```

---

- [ ] **Step 9: Define API routes**

Edit `backend/routes/api.php`:
```php
<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
});
```

---

- [ ] **Step 10: Run migrations**

Run:
```powershell
php artisan migrate
```

Expected: Users and personal_access_tokens tables created

---

- [ ] **Step 11: Test API endpoints**

Test with curl or Postman:

```powershell
# Test register
Invoke-RestMethod -Method Post -Uri "http://localhost:8000/api/register" `
  -ContentType "application/json" `
  -Body '{"name":"Test User","email":"test@example.com","password":"password123","password_confirmation":"password123"}'

# Test login
Invoke-RestMethod -Method Post -Uri "http://localhost:8000/api/login" `
  -ContentType "application/json" `
  -Body '{"email":"test@example.com","password":"password123"}'

# Test user (with token)
$token = "PASTE_TOKEN_HERE"
Invoke-RestMethod -Method Get -Uri "http://localhost:8000/api/user" `
  -Headers @{ "Authorization" = "Bearer $token" }
```

Expected: Valid JSON responses as per spec

---

## Part B: Frontend (Flutter + Riverpod)

### Task B1: Setup Flutter Project Structure

**Files:**
- Create: `frontend/lib/main.dart`
- Create: `frontend/lib/app.dart`
- Modify: `frontend/pubspec.yaml`

**Interfaces:**
- Produces: Flutter project scaffold with dependencies

---

- [ ] **Step 1: Create Flutter project**

Run in PowerShell (from `c:\xampp\htdocs\DNTrip`):
```powershell
flutter create --org com.dntrip frontend
```

Expected: Flutter project created in `frontend/` directory

---

- [ ] **Step 2: Configure pubspec.yaml**

Edit `frontend/pubspec.yaml`:
```yaml
name: dntrip
description: Trip sharing and expense tracking app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  dio: ^5.4.0
  go_router: ^13.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
```

Run:
```powershell
cd frontend && flutter pub get
```

Expected: Dependencies installed

---

### Task B2: Core Infrastructure

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

---

- [ ] **Step 1: Create AppConstants**

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

- [ ] **Step 2: Create HiveStorage**

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

- [ ] **Step 3: Create ApiException**

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

- [ ] **Step 4: Create ApiEndpoints**

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

- [ ] **Step 5: Create AuthInterceptor**

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

- [ ] **Step 6: Create ApiClient**

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

- [ ] **Step 7: Create AppTheme**

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

- [ ] **Step 8: Create AppRouter**

Create `frontend/lib/core/router/app_router.dart`:
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
      final isLoggedIn = authState is Authenticated;
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
      appBar: AppBar(title: const Text('DNTrip')),
      body: const Center(child: Text('Home Screen (TBD)')),
    );
  }
}
```

---

### Task B3: Auth Feature - Data Layer

**Files:**
- Create: `frontend/lib/features/auth/data/models/user_model.dart`
- Create: `frontend/lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Create: `frontend/lib/features/auth/data/auth_repository.dart`

**Interfaces:**
- Consumes: ApiClient
- Produces: AuthRepository

---

- [ ] **Step 1: Create UserModel with freezed**

Create `frontend/lib/features/auth/data/models/user_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    required String name,
    required String email,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

---

- [ ] **Step 2: Create AuthRemoteDatasource**

Create `frontend/lib/features/auth/data/datasources/auth_remote_datasource.dart`:
```dart
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final userData = response['data']['user'] as Map<String, dynamic>;
    final token = response['data']['token'] as String;

    return (
      user: UserModel.fromJson(userData),
      token: token,
    );
  }

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final userData = response['data']['user'] as Map<String, dynamic>;
    final token = response['data']['token'] as String;

    return (
      user: UserModel.fromJson(userData),
      token: token,
    );
  }

  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiEndpoints.user);
    final userData = response['data']['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }
}
```

---

- [ ] **Step 3: Create AuthRepository**

Create `frontend/lib/features/auth/data/auth_repository.dart`:
```dart
import '../../../../core/storage/hive_storage.dart';
import '../models/user_model.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final HiveStorage _storage;

  AuthRepository(this._remoteDatasource, this._storage);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _remoteDatasource.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    await _storage.saveToken(result.token);
    await _storage.saveUser(result.user.toJson());

    return result.user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDatasource.login(
      email: email,
      password: password,
    );

    await _storage.saveToken(result.token);
    await _storage.saveUser(result.user.toJson());

    return result.user;
  }

  Future<void> logout() async {
    try {
      await _remoteDatasource.logout();
    } finally {
      await _storage.clearAll();
    }
  }

  UserModel? getCachedUser() {
    final userData = _storage.getUser();
    if (userData != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }

  bool isLoggedIn() => _storage.isLoggedIn();
}
```

---

### Task B4: Auth Feature - Domain Layer (Riverpod Providers)

**Files:**
- Create: `frontend/lib/features/auth/domain/auth_providers.dart`

**Interfaces:**
- Consumes: AuthRepository, HiveStorage
- Produces: AuthNotifier, LoginNotifier, RegisterNotifier

---

- [ ] **Step 1: Create AuthProviders with Riverpod codegen**

Create `frontend/lib/features/auth/domain/auth_providers.dart`:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../core/api/api_client.dart';
import '../../data/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

part 'auth_providers.g.dart';

// Base providers
@riverpod
HiveStorage hiveStorage(HiveStorageRef ref) {
  return HiveStorage();
}

@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final storage = ref.watch(hiveStorageProvider);
  return ApiClient(storage);
}

@riverpod
AuthRemoteDatasource authRemoteDatasource(AuthRemoteDatasourceRef ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDatasource(apiClient);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final remote = ref.watch(authRemoteDatasourceProvider);
  final storage = ref.watch(hiveStorageProvider);
  return AuthRepository(remote, storage);
}

// Auth state
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// Auth notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final repository = ref.watch(authRepositoryProvider);

    if (!repository.isLoggedIn()) {
      return const Unauthenticated();
    }

    final cachedUser = repository.getCachedUser();
    if (cachedUser != null) {
      return Authenticated(cachedUser);
    }

    return const Unauthenticated();
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    ref.invalidateSelf();
  }
}

// Login state
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserModel user;
  const LoginSuccess(this.user);
}

class LoginError extends LoginState {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  const LoginError(this.message, {this.fieldErrors});
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState get build() => const LoginInitial();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(
        email: email,
        password: password,
      );
      state = LoginSuccess(user);
      ref.invalidate(authNotifierProvider);
    } catch (e) {
      String message = e.toString();
      Map<String, dynamic>? fieldErrors;

      if (e.toString().contains('422') && e is ApiException && e.errors != null) {
        fieldErrors = e.errors;
        message = 'Validation failed';
      }

      state = LoginError(message, fieldErrors: fieldErrors);
    }
  }

  void reset() {
    state = const LoginInitial();
  }
}

// Register state
sealed class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserModel user;
  const RegisterSuccess(this.user);
}

class RegisterError extends RegisterState {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  const RegisterError(this.message, {this.fieldErrors});
}

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  @override
  RegisterState get build() => const RegisterInitial();

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const RegisterLoading();

    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
      );
      state = RegisterSuccess(user);
      ref.invalidate(authNotifierProvider);
    } catch (e) {
      String message = e.toString();
      Map<String, dynamic>? fieldErrors;

      if (e.toString().contains('422') && e is ApiException && e.errors != null) {
        fieldErrors = e.errors;
        message = 'Validation failed';
      }

      state = RegisterError(message, fieldErrors: fieldErrors);
    }
  }

  void reset() {
    state = const RegisterInitial();
  }
}
```

**Note:** Add this import at the top of auth_providers.dart:
```dart
import '../../../../core/api/api_exception.dart';
```

---

### Task B5: Auth Feature - Presentation Layer (Screens)

**Files:**
- Create: `frontend/lib/features/auth/presentation/screens/splash_screen.dart`
- Create: `frontend/lib/features/auth/presentation/screens/login_screen.dart`
- Create: `frontend/lib/features/auth/presentation/screens/register_screen.dart`
- Create: `frontend/lib/features/auth/presentation/widgets/auth_text_field.dart`

---

- [ ] **Step 1: Create AuthTextField widget**

Create `frontend/lib/features/auth/presentation/widgets/auth_text_field.dart`:
```dart
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? errorText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
```

---

- [ ] **Step 2: Create SplashScreen**

Create `frontend/lib/features/auth/presentation/screens/splash_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Small delay for splash effect
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    await authState.when(
      data: (state) async {
        if (!mounted) return;
        
        if (state is Authenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      },
      loading: () {},
      error: (_, __) {
        if (!mounted) return;
        context.go('/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.luggage_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'DNTrip',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 3: Create LoginScreen**

Create `frontend/lib/features/auth/presentation/screens/login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    ref.read(loginNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginNotifierProvider);

    ref.listen<LoginState>(loginNotifierProvider, (previous, next) {
      if (next is LoginSuccess) {
        context.go('/home');
      } else if (next is LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              Icon(
                Icons.luggage_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your trip',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Email field
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Password field
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 32),

              // Login button
              ElevatedButton(
                onPressed: loginState is LoginLoading ? null : _login,
                child: loginState is LoginLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 24),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

- [ ] **Step 4: Create RegisterScreen**

Create `frontend/lib/features/auth/presentation/screens/register_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_providers.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    // Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(registerNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerNotifierProvider);

    ref.listen<RegisterState>(registerNotifierProvider, (previous, next) {
      if (next is RegisterSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      } else if (next is RegisterError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join DNTrip',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to start planning your trips',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 32),

              // Name field
              AuthTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Email field
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Password field
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min 8 characters',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Confirm Password field
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _register(),
              ),
              const SizedBox(height: 32),

              // Register button
              ElevatedButton(
                onPressed:
                    registerState is RegisterLoading ? null : _register,
                child: registerState is RegisterLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 24),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Task B6: App Entry Points

**Files:**
- Modify: `frontend/lib/main.dart`
- Create: `frontend/lib/app.dart`

---

- [ ] **Step 1: Create main.dart**

Edit `frontend/lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_storage.dart';
import 'app.dart';

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

**Note:** Add this import at the top:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/domain/auth_providers.dart';
```

---

- [ ] **Step 2: Create app.dart**

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

### Task B7: Run Code Generation

**Files Generated:**
- `frontend/lib/features/auth/data/models/user_model.freezed.dart`
- `frontend/lib/features/auth/data/models/user_model.g.dart`
- `frontend/lib/features/auth/domain/auth_providers.g.dart`
- `frontend/lib/core/router/app_router.g.dart`

---

- [ ] **Step 1: Run build_runner**

Run in PowerShell:
```powershell
cd frontend && flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: Generated files created successfully

If there are errors, check for:
1. Import paths are correct
2. All freezed annotations are properly formatted
3. Riverpod annotations use correct syntax

---

### Task B8: Testing

**Files:**
- Modify: `frontend/test/auth_test.dart`

---

- [ ] **Step 1: Create basic widget test**

Create `frontend/test/auth_test.dart`:
```dart
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
```

Run test:
```powershell
cd frontend && flutter test test/auth_test.dart
```

Expected: Test passes

---

## Verification Checklist

After all tasks complete, verify:

- [ ] Backend API responds correctly (test all 4 endpoints)
- [ ] Flutter app builds without errors
- [ ] Auth flow works: Splash → Login → Register → Login → Home
- [ ] Token stored in Hive after login
- [ ] Logout clears token and redirects to login
- [ ] Form validation shows inline errors
- [ ] API errors show snackbar messages

---

*Implementation plan v1.0 - 2026-07-03*
