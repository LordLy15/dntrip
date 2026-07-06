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

    final data = response['data'] as Map<String, dynamic>?;
    final userData = data?['user'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;

    if (userData == null || token == null) {
      throw Exception('Invalid response from server');
    }

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

    final data = response['data'] as Map<String, dynamic>?;
    final userData = data?['user'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;

    if (userData == null || token == null) {
      throw Exception('Invalid response from server');
    }

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
    final data = response['data'] as Map<String, dynamic>?;
    final userData = data?['user'] as Map<String, dynamic>?;

    if (userData == null) {
      throw Exception('Invalid response from server');
    }

    return UserModel.fromJson(userData);
  }
}
