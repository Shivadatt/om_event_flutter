import '../constants/app_strings.dart';

/// Legacy constants gateway — pricing and business configuration.
/// Cache key access now routes through [AppStrings].
class AppConstants {
  // ── Business ──────────────────────────────────────────────────────────────
  static const String businessName = AppStrings.businessName;
  static const String businessPhone = AppStrings.businessPhone;
  static const String businessEmail = AppStrings.businessEmail;
  static const String whatsappMessage = AppStrings.whatsappMessage;

  // ── Pricing & Calculations ────────────────────────────────────────────────
  static const double gstPercent = 18.0;
  static const double deliveryCharge = 500.0;
  static const double travelCharge = 0.0;

  /// When true, client-side estimates waive GST and delivery charges.
  static const bool enableClientFeeWaiver = true;

  // ── Local Storage Cache Keys ──────────────────────────────────────────────
  static const String cartCacheKey = AppStrings.cartCacheKey;
  static const String themeCacheKey = AppStrings.themeCacheKey;
  static const String adminTokenKey = AppStrings.adminTokenKey;
}
