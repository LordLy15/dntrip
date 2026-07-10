class AppConstants {
  AppConstants._();

  // API - Vercel Backend
  // TODO: Update with Vercel backend URL after deployment
  // Example: https://dntrip-api.vercel.app/api
  static const String baseUrl = 'https://dntrip-backend.vercel.app/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Hive boxes
  static const String authBox = 'auth_box';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
