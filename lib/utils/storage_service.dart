import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Token methods
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, json.encode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(_userDataKey);
    return data != null ? json.decode(data) : null;
  }

  Future<void> removeUserData() async {
    await _prefs.remove(_userDataKey);
  }

  // Login status
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearAuthData() async {
    await removeToken();
    await removeUserData();
    await _prefs.remove(_isLoggedInKey);
  }

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static StorageService? _instance;
  static Future<StorageService> getInstance() async {
    _instance ??= await create();
    return _instance!;
  }
}
