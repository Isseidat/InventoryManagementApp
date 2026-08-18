import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // ignore: unused_field
  final SharedPreferences _prefs; // Vẫn giữ để tương thích DI, dù không dùng

  SharedPrefsHelper(this._prefs);

  // LƯU TRÊN RAM: Biến tĩnh (tắt app là mất)
  static String? _inMemoryToken;
  static String? _inMemoryRole;

  Future<bool> saveToken(String token) async {
    _inMemoryToken = token;
    return true;
  }

  String? getToken() {
    return _inMemoryToken;
  }

  Future<bool> clearToken() async {
    _inMemoryToken = null;
    return true;
  }

  bool hasToken() {
    return _inMemoryToken != null;
  }

  Future<bool> saveRole(String role) async {
    _inMemoryRole = role;
    return true;
  }

  String? getRole() {
    return _inMemoryRole;
  }
}
