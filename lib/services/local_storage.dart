import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String keyToken = 'auth_token';
  static const String keyLastRoute = 'last_route';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await init();
    await _prefs.setString(keyToken, token);
  }

  static Future<String?> getToken() async {
    await init();
    return _prefs.getString(keyToken);
  }

  static Future<void> clearToken() async {
    await init();
    await _prefs.remove(keyToken);
  }

  static Future<void> saveLastRoute(String route) async {
    await init();
    await _prefs.setString(keyLastRoute, route);
  }

  static Future<String?> getLastRoute() async {
    await init();
    return _prefs.getString(keyLastRoute);
  }
}
