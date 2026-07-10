class AppConstants {
  AppConstants._();

  // API - Production (Render.com)
  // TODO: Update with Render deployment URL after setup
  static const String baseUrl = 'https://dntrip-api.onrender.com/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Hive boxes
  static const String authBox = 'auth_box';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
