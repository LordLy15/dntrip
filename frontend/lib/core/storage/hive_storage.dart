import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveStorage {
  Box? _box;

  Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox(AppConstants.authBox);
  }

  // Token operations
  Future<void> saveToken(String token) async {
    await _box?.put(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _box?.get(AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _box?.delete(AppConstants.tokenKey);
  }

  // User operations
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _box?.put(AppConstants.userKey, user);
  }

  Map<String, dynamic>? getUser() {
    try {
      final user = _box?.get(AppConstants.userKey);
      if (user != null) {
        return Map<String, dynamic>.from(user);
      }
    } catch (_) {}
    return null;
  }

  Future<void> clearUser() async {
    await _box?.delete(AppConstants.userKey);
  }

  // Itinerary cache operations
  static const String _itineraryPrefix = 'itinerary_';

  Future<void> saveItinerary(int tripId, Map<String, dynamic> data) async {
    if (_box == null) return;
    try {
      final key = '$_itineraryPrefix$tripId';
      await _box!.put(key, jsonEncode(data));
      await _box!.put('${key}_time', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  Map<String, dynamic>? getItinerary(int tripId) {
    if (_box == null) return null;
    try {
      final key = '$_itineraryPrefix$tripId';
      final data = _box!.get(key);
      if (data != null) {
        return Map<String, dynamic>.from(jsonDecode(data));
      }
    } catch (_) {}
    return null;
  }

  bool isItineraryCacheValid(int tripId, {Duration maxAge = const Duration(minutes: 30)}) {
    if (_box == null) return false;
    try {
      final key = '$_itineraryPrefix$tripId';
      final time = _box!.get('${key}_time') as int?;
      if (time == null) return false;
      final age = DateTime.now().millisecondsSinceEpoch - time;
      return Duration(milliseconds: age) < maxAge;
    } catch (_) {}
    return false;
  }

  Future<void> clearItinerary(int tripId) async {
    if (_box == null) return;
    try {
      final key = '$_itineraryPrefix$tripId';
      await _box!.delete(key);
      await _box!.delete('${key}_time');
    } catch (_) {}
  }

  // Clear all auth data
  Future<void> clearAll() async {
    await _box?.clear();
  }

  // Check if logged in
  bool isLoggedIn() {
    return getToken() != null;
  }
}
