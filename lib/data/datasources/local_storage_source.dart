import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';

class LocalStorageSource {
  final SharedPreferences _prefs;
  LocalStorageSource(this._prefs);

  // Cart Caching
  Future<bool> saveCart(String cartJson) async {
    return await _prefs.setString(AppStrings.cartCacheKey, cartJson);
  }

  String? getCart() {
    return _prefs.getString(AppStrings.cartCacheKey);
  }

  Future<bool> clearCart() async {
    return await _prefs.remove(AppStrings.cartCacheKey);
  }

  // Theme Caching
  Future<bool> saveTheme(String themeName) async {
    return await _prefs.setString(AppStrings.themeCacheKey, themeName);
  }

  String? getTheme() {
    return _prefs.getString(AppStrings.themeCacheKey);
  }

  // Admin Access Token Caching
  Future<bool> saveAdminToken(String token) async {
    return await _prefs.setString(AppStrings.adminTokenKey, token);
  }

  String? getAdminToken() {
    return _prefs.getString(AppStrings.adminTokenKey);
  }

  Future<bool> clearAdminToken() async {
    return await _prefs.remove(AppStrings.adminTokenKey);
  }

  // User Role Caching
  Future<bool> saveUserRole(String role) async {
    return await _prefs.setString('oe-user-role', role);
  }

  String? getUserRole() {
    return _prefs.getString('oe-user-role');
  }

  Future<bool> clearUserRole() async {
    return await _prefs.remove('oe-user-role');
  }
}
