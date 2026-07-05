# Task B3: Auth Feature - Data Layer

**Files:**
- Create: `frontend/lib/features/auth/data/models/user_model.dart`
- Create: `frontend/lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Create: `frontend/lib/features/auth/data/auth_repository.dart`

**Interfaces:**
- Consumes: ApiClient
- Produces: AuthRepository

**Note:** Task B2 (Core Infrastructure) must be complete before this task.

---

**Step 1: Create UserModel with freezed**

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

**Step 2: Create AuthRemoteDatasource**

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

**Step 3: Create AuthRepository**

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

**Step 4: Verify data layer compiles**

Run:
```powershell
cd frontend && flutter analyze lib/features/auth/data/
```

Expected: No errors
