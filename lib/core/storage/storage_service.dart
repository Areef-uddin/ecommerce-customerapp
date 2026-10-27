import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserData = 'user_data';
  static const String _keyOnboarded = 'is_onboarded';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveTokens({required String access, required String refresh}) async {
    await _prefs.setString(_keyToken, access);
    await _prefs.setString(_keyRefreshToken, refresh);
  }

  static String? getAccessToken() {
    return _prefs.getString(_keyToken);
  }

  static String? getRefreshToken() {
    return _prefs.getString(_keyRefreshToken);
  }

  static bool get isLoggedIn => getAccessToken() != null;

  // User Profile
  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _prefs.setString(_keyUserData, jsonEncode(userMap));
  }

  static Map<String, dynamic>? getUser() {
    final raw = _prefs.getString(_keyUserData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Onboarding
  static Future<void> setOnboarded(bool value) async {
    await _prefs.setBool(_keyOnboarded, value);
  }

  static bool get isOnboarded => _prefs.getBool(_keyOnboarded) ?? false;

  // Clear session
  static Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyUserData);
  }
}
