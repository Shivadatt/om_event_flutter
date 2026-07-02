import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../domain/entities/business_details_entity.dart';
import '../../data/models/business_details_model.dart';

class BusinessDetailsCacheService extends GetxService {
  static BusinessDetailsCacheService get to => Get.find<BusinessDetailsCacheService>();
  
  final SharedPreferences _prefs = Get.find<SharedPreferences>();
  static const String _cacheKey = 'cached_business_details';

  Future<void> cacheBusinessDetails(BusinessDetailsEntity details) async {
    final jsonStr = jsonEncode(BusinessDetailsModel.toJson(details));
    await _prefs.setString(_cacheKey, jsonStr);
  }

  BusinessDetailsEntity? getCachedBusinessDetails() {
    final jsonStr = _prefs.getString(_cacheKey);
    if (jsonStr == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return BusinessDetailsModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
  }
}
