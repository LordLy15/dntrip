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
