import '../../../core/storage/hive_storage.dart';
import 'models/user_model.dart';
import 'datasources/auth_remote_datasource.dart';

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

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? avatarBase64,
  }) async {
    final user = await _remoteDatasource.updateProfile(
      name: name,
      email: email,
      avatarBase64: avatarBase64,
    );
    await _storage.saveUser(user.toJson());
    return user;
  }

  bool isLoggedIn() => _storage.isLoggedIn();
}
