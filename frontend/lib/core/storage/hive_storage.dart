import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveStorage {
  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.authBox);
  }

  // Token operations
  Future<void> saveToken(String token) async {
    await _box.put(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _box.get(AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _box.delete(AppConstants.tokenKey);
  }

  // User operations
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.put(AppConstants.userKey, user);
  }

  Map<String, dynamic>? getUser() {
    final user = _box.get(AppConstants.userKey);
    if (user != null) {
      return Map<String, dynamic>.from(user);
    }
    return null;
  }

  Future<void> clearUser() async {
    await _box.delete(AppConstants.userKey);
  }

  // Clear all auth data
  Future<void> clearAll() async {
    await _box.clear();
  }

  // Check if logged in
  bool isLoggedIn() {
    return getToken() != null;
  }
}
