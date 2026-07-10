class AppConstants {
  AppConstants._();

  // API - Vercel Backend (dntrip-backend)
  // After deploying backend to Vercel, update this URL
  static const String baseUrl = 'https://dntrip-backend.vercel.app/api';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Hive boxes
  static const String authBox = 'auth_box';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
}
