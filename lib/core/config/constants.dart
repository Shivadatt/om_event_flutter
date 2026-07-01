import 'package:om_event/core/services/app_config_service.dart';
import '../constants/app_strings.dart';

/// Legacy constants gateway — pricing and business configuration.
/// Cache key access now routes through [AppStrings].
class AppConstants {
  // ── Business ──────────────────────────────────────────────────────────────
  static String get businessName =>
      AppConfigService.to.rxBusinessProfile.value.name;
  static String get businessPhone =>
      AppConfigService.to.rxBusinessProfile.value.phone;
  static String get businessEmail =>
      AppConfigService.to.rxBusinessProfile.value.email;
  static String get whatsappMessage =>
      AppConfigService.to.rxBusinessProfile.value.whatsapp;

  // ── Pricing & Calculations ────────────────────────────────────────────────
  static double get gstPercent =>
      AppConfigService.to.rxPricingSettings.value.gst;
  static double get deliveryCharge =>
      AppConfigService.to.rxPricingSettings.value.deliveryCharge;
  static double get travelCharge =>
      AppConfigService.to.rxPricingSettings.value.travelCharge;

  /// When true, client-side estimates waive GST and delivery charges.
  static bool get enableClientFeeWaiver => true;

  // ── Local Storage Cache Keys ──────────────────────────────────────────────
  static const String cartCacheKey = AppStrings.cartCacheKey;
  static const String themeCacheKey = AppStrings.themeCacheKey;
  static const String adminTokenKey = AppStrings.adminTokenKey;
}
