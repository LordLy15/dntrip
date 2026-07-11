class AppConstants {
  AppConstants._();

  // API - Railway Backend
  // After deploying backend to Railway, update this URL
  static const String baseUrl = 'https://dntrip-production.up.railway.app/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Hive boxes
  static const String authBox = 'auth_box';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
