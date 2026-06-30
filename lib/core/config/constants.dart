class AppConstants {
  static const String businessName = "Om Events";
  static const String businessPhone = "919512149944";
  static const String businessEmail = "omeventsanddecorators@gmail.com";
  static const String whatsappMessage = "Hello Om Events, I'd like to plan an event.";

  // Pricing & Calculations
  static const double gstPercent = 18.0;
  static const double deliveryCharge = 500.0;
  static const double travelCharge = 0.0;

  // Toggle to reconcile client estimates vs server-calculated invoices
  // If true, the client estimates in the UI waive GST and delivery charges
  static const bool enableClientFeeWaiver = true;

  // Local Storage Cache Keys
  static const String cartCacheKey = "oe-cart-selection";
  static const String themeCacheKey = "oe-app-theme";
  static const String adminTokenKey = "oe-admin-jwt-token";
}
