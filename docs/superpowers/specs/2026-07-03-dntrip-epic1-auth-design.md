# DNTrip Epic 1: User Authentication - Design Specification

**Tanggal:** 2026-07-03
**Epic:** Epic 1 - User Authentication & Profile
**Status:** Draft

---

## 1. Overview

Epic 1 adalah fondasi utama untuk aplikasi DNTrip. Implementasi ini mencakup authentication system lengkap menggunakan Laravel Sanctum (backend) dan Flutter dengan Riverpod (frontend).

### Goals
- User registration dengan email & password
- User login dengan token-based authentication
- Secure token storage dan refresh mechanism
- User profile retrieval

### Tech Stack Decisions
| Component | Choice | Rationale |
|-----------|--------|-----------|
| Backend | Laravel 10 + Sanctum | REST API focused, no web scaffolding |
| Frontend | Flutter + Riverpod codegen | Type-safe, clean architecture |
| Local Storage | Hive | Lightweight, fast read-only caching |
| Navigation | go_router | Official Flutter routing solution |
| Architecture | Feature-First | Modular, easy navigation |

---

## 2. Backend Design (Laravel + Sanctum)

### 2.1 Project Structure

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       └── AuthController.php
│   │   └── Requests/
│   │       ├── RegisterRequest.php
│   │       └── LoginRequest.php
│   └── Models/
│       └── User.php
├── config/
│   └── sanctum.php
├── database/
│   └── migrations/
│       └── (users table - default Laravel)
├── routes/
│   └── api.php
├── .env
└── composer.json
```

### 2.2 API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/register` | No | Register new user |
| POST | `/api/login` | No | Login user, return token |
| POST | `/api/logout` | Yes | Revoke current token |
| GET | `/api/user` | Yes | Get current user profile |

### 2.3 Request/Response Specifications

#### POST /api/register

**Request:**
```json
{
  "name": "Andi",
  "email": "andi@email.com",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Success Response (201):**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "name": "Andi",
      "email": "andi@email.com",
      "created_at": "2026-07-03T10:00:00.000000Z"
    },
    "token": "1|abc123xyz..."
  },
  "message": "Registration successful"
}
```

#### POST /api/login

**Request:**
```json
{
  "email": "andi@email.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "name": "Andi",
      "email": "andi@email.com",
      "created_at": "2026-07-03T10:00:00.000000Z"
    },
    "token": "2|def456..."
  },
  "message": "Login successful"
}
```

#### POST /api/logout

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

#### GET /api/user

**Headers:** `Authorization: Bearer {token}`

**Success Response (200):**
```json
{
  "status": "success",
  "data": {
    "user": {
      "id": 1,
      "name": "Andi",
      "email": "andi@email.com",
      "created_at": "2026-07-03T10:00:00.000000Z"
    }
  }
}
```

### 2.4 Error Responses

**Validation Error (422):**
```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": {
    "email": ["The email has already been taken."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

**Authentication Error (401):**
```json
{
  "status": "error",
  "message": "Invalid credentials"
}
```

### 2.5 Validation Rules

| Endpoint | Field | Rules |
|----------|-------|-------|
| register | name | required, string, min:2, max:255 |
| register | email | required, string, email, max:255, unique:users |
| register | password | required, string, min:8, confirmed |
| login | email | required, string, email |
| login | password | required, string |

### 2.6 Database Schema

**users table (Laravel default):**
| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | primary key, auto increment |
| name | varchar(255) | not null |
| email | varchar(255) | not null, unique |
| email_verified_at | timestamp | nullable |
| password | varchar(255) | not null |
| remember_token | varchar(100) | nullable |
| created_at | timestamp | nullable |
| updated_at | timestamp | nullable |

**personal_access_tokens table (Sanctum):**
| Column | Type | Constraints |
|--------|------|-------------|
| id | bigint | primary key, auto increment |
| tokenable_type | varchar(255) | not null |
| tokenable_id | bigint | not null |
| name | varchar(255) | not null |
| token | varchar(64) | not null, unique |
| abilities | text | nullable |
| last_used_at | timestamp | nullable |
| expires_at | timestamp | nullable |
| created_at | timestamp | nullable |
| updated_at | timestamp | nullable |

---

## 3. Frontend Design (Flutter + Riverpod)

### 3.1 Project Structure

```
frontend/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # App widget with ProviderScope
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart      # Dio instance with interceptors
│   │   │   ├── api_endpoints.dart   # Endpoint constants
│   │   │   ├── api_exception.dart   # Custom exception handling
│   │   │   └── api_interceptor.dart # Auth token injection
│   │   ├── router/
│   │   │   └── app_router.dart      # go_router configuration
│   │   ├── storage/
│   │   │   └── hive_storage.dart    # Hive wrapper for token/user
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Material 3 theme
│   │   └── constants/
│   │       └── app_constants.dart    # App-wide constants
│   └── features/
│       └── auth/
│           ├── data/
│           │   ├── auth_repository.dart
│           │   ├── models/
│           │   │   └── user_model.dart
│           │   └── datasources/
│           │       └── auth_remote_datasource.dart
│           ├── domain/
│           │   └── auth_providers.dart  # Riverpod providers
│           └── presentation/
│               ├── screens/
│               │   ├── splash_screen.dart
│               │   ├── login_screen.dart
│               │   └── register_screen.dart
│               └── widgets/
│                   └── auth_text_field.dart
├── pubspec.yaml
└── analysis_options.yaml
```

### 3.2 Navigation Flow

```
┌─────────────────┐
│  SplashScreen   │ (check token from Hive)
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
Token?    No Token
    │         │
    ▼         ▼
┌────────┐ ┌──────────┐
│  Home  │ │ Login    │
│  (TBD) │ │ Screen   │
└────────┘ └────┬─────┘
                │
           Register Link
                │
                ▼
         ┌──────────────┐
         │   Register   │
         │    Screen    │
         └──────┬───────┘
                │
           Success
                │
                ▼
         ┌──────────┐
         │ Login    │
         │ Screen   │
         └──────────┘
```

### 3.3 State Management (Riverpod + freezed)

```dart
// Auth State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// Providers
@riverpod
class AuthNotifier extends _$AuthNotifier {
  // Check token, load user, logout
}

@riverpod
class LoginNotifier extends _$LoginNotifier {
  // Login logic with validation
}

@riverpod
class RegisterNotifier extends _$RegisterNotifier {
  // Register logic with validation
}
```

### 3.4 Data Models

```dart
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

### 3.5 API Client Configuration

```dart
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator

  final Dio _dio;
  final HiveStorage _storage;

  ApiClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
}

class AuthInterceptor extends Interceptor {
  final HiveStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
```

### 3.6 Form Validation

| Screen | Field | Rules | Error Message |
|--------|-------|-------|---------------|
| Login | email | required, valid email | "Email is required" / "Invalid email format" |
| Login | password | required, min 8 | "Password is required" / "Password min 8 characters" |
| Register | name | required, min 2 | "Name is required" / "Name min 2 characters" |
| Register | email | required, valid email | "Email is required" / "Invalid email format" |
| Register | password | required, min 8 | "Password is required" / "Password min 8 characters" |
| Register | confirmPassword | required, match password | "Confirm password is required" / "Passwords do not match" |

### 3.7 Error Handling

| Error Type | UI Response |
|------------|-------------|
| Network Error | Snackbar: "No internet connection" |
| 401 Unauthorized | Clear token, redirect to login |
| 422 Validation | Show inline field errors |
| 500 Server Error | Snackbar: "Server error. Please try again." |
| Unknown Error | Snackbar: "Something went wrong" |

---

## 4. Implementation Checklist

### Backend
- [ ] Create Laravel project
- [ ] Configure .env (DB, APP_URL)
- [ ] Install Sanctum
- [ ] Publish Sanctum migrations
- [ ] Update User model with HasApiTokens
- [ ] Create RegisterRequest validation
- [ ] Create LoginRequest validation
- [ ] Create AuthController
- [ ] Define API routes
- [ ] Test all endpoints with Postman/curl

### Frontend
- [ ] Create Flutter project
- [ ] Configure pubspec.yaml (dependencies)
- [ ] Setup Hive initialization
- [ ] Create API client with Dio
- [ ] Create AuthInterceptor
- [ ] Create User model with freezed
- [ ] Create AuthRepository
- [ ] Create Riverpod providers
- [ ] Setup go_router
- [ ] Create SplashScreen
- [ ] Create LoginScreen
- [ ] Create RegisterScreen
- [ ] Create AuthTextField widget
- [ ] Setup Material 3 theme
- [ ] Test auth flow

---

## 5. Dependencies

### Backend (composer.json)
```json
{
  "require": {
    "laravel/framework": "^10.0",
    "laravel/sanctum": "^3.3"
  }
}
```

### Frontend (pubspec.yaml)
```yaml
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
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
  flutter_lints: ^3.0.1
```

---

## 6. Notes & Considerations

### Security
- Password hashing menggunakan bcrypt (Laravel default)
- Token storage menggunakan Hive dengan encryption
- Bearer token injection via interceptor
- HTTPS required untuk production

### Testing Strategy
- Backend: PHPUnit tests untuk AuthController
- Frontend: Widget tests untuk screens

### Future Enhancements (Out of Scope for Epic 1)
- Email verification
- Password reset
- Biometric authentication
- Token refresh mechanism

---

*Design specification v1.0 - 2026-07-03*
