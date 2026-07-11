import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/models/user_model.dart';

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

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarBase64,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final user = await repository.updateProfile(
      name: name,
      email: email,
      avatarBase64: avatarBase64,
    );
    state = AsyncData(Authenticated(user));
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
  LoginState build() => const LoginInitial();

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

      if (e is ApiException && e.errors != null) {
        fieldErrors = e.errors;
        message = e.message;
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
  RegisterState build() => const RegisterInitial();

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

      if (e is ApiException && e.errors != null) {
        fieldErrors = e.errors;
        message = e.message;
      }

      state = RegisterError(message, fieldErrors: fieldErrors);
    }
  }

  void reset() {
    state = const RegisterInitial();
  }
}
