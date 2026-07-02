import 'package:om_event/core/services/business_details_service.dart';
import 'package:om_event/core/services/app_config_service.dart';
import '../../domain/entities/business_details_entity.dart';
import '../constants/app_strings.dart';

/// Legacy constants gateway — pricing and business configuration.
/// Cache key access now routes through [AppStrings].
class AppConstants {
  // ── Business ──────────────────────────────────────────────────────────────
  static String get businessName =>
      BusinessDetailsService.to.rxDetails.value.general.businessName;
  static String get businessPhone {
    final contacts = BusinessDetailsService.to.rxDetails.value.contacts;
    final primary = contacts.phones.firstWhere(
      (cn) => cn.isPrimary && cn.isActive,
      orElse: () => contacts.phones.firstWhere(
        (cn) => cn.isActive,
        orElse: () => contacts.phones.isNotEmpty
            ? contacts.phones.first
            : const ContactItemEntity(
                id: '',
                label: '',
                value: '9512149944',
                isPrimary: false,
                isActive: false,
                displayOrder: 0,
              ),
      ),
    );
    return primary.value;
  }
  static String get businessEmail {
    final contacts = BusinessDetailsService.to.rxDetails.value.contacts;
    final primary = contacts.emails.firstWhere(
      (cn) => cn.isPrimary && cn.isActive,
      orElse: () => contacts.emails.firstWhere(
        (cn) => cn.isActive,
        orElse: () => contacts.emails.isNotEmpty
            ? contacts.emails.first
            : const ContactItemEntity(
                id: '',
                label: '',
                value: 'omeventsanddecorators@gmail.com',
                isPrimary: false,
                isActive: false,
                displayOrder: 0,
              ),
      ),
    );
    return primary.value;
  }
  static String get whatsappMessage =>
      "Hello Om Events, I'd like to plan an event.";

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
