import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/constants.dart';

class LocalStorageSource {
  final SharedPreferences _prefs;
  LocalStorageSource(this._prefs);

  // Cart Caching
  Future<bool> saveCart(String cartJson) async {
    return await _prefs.setString(AppConstants.cartCacheKey, cartJson);
  }

  String? getCart() {
    return _prefs.getString(AppConstants.cartCacheKey);
  }

  Future<bool> clearCart() async {
    return await _prefs.remove(AppConstants.cartCacheKey);
  }

  // Theme Caching
  Future<bool> saveTheme(String themeName) async {
    return await _prefs.setString(AppConstants.themeCacheKey, themeName);
  }

  String? getTheme() {
    return _prefs.getString(AppConstants.themeCacheKey);
  }

  // Admin Access Token Caching
  Future<bool> saveAdminToken(String token) async {
    return await _prefs.setString(AppConstants.adminTokenKey, token);
  }

  String? getAdminToken() {
    return _prefs.getString(AppConstants.adminTokenKey);
  }

  Future<bool> clearAdminToken() async {
    return await _prefs.remove(AppConstants.adminTokenKey);
  }
}
