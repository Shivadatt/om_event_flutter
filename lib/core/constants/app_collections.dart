/// Centralized Firestore collection name constants.
/// All collection queries must use these identifiers.
class AppCollections {
  AppCollections._();

  /// Administrator role profiles.
  static const String admin = 'admin';

  /// Published event categories.
  static const String categories = 'categories';

  /// Decoration service items.
  static const String items = 'items';

  /// Item secondary gallery images.
  static const String itemImages = 'item_images';

  /// CRM customer profiles.
  static const String customers = 'customers';

  /// Contact form & inquiry leads.
  static const String leads = 'leads';

  /// Event quotations (proposals).
  static const String quotations = 'quotations';

  /// Quotation line items.
  static const String quotationItems = 'quotation_items';

  /// Studio bookings.
  static const String bookings = 'bookings';

  /// Published customer reviews.
  static const String reviews = 'reviews';

  /// Activity audit logs.
  static const String activityLogs = 'activity_logs';

  /// Application configuration.
  static const String settings = 'settings';

  /// Registered app users.
  static const String users = 'users';

  /// Payment records.
  static const String payments = 'payments';

  // ==========================================
  // CUSTOMER PORTAL COLLECTIONS
  // ==========================================
  static const String customerProfiles = 'customer_profiles';
  static const String customerLeads = 'customer_leads';
  static const String customerQuotes = 'customer_quotes';
  static const String customerBookings = 'customer_bookings';
  static const String customerNotifications = 'customer_notifications';
  static const String customerReviews = 'customer_reviews';
  static const String customerPayments = 'customer_payments';
  static const String customerWishlist = 'customer_wishlist';
  static const String customerGallery = 'customer_gallery';
  static const String customerActivity = 'customer_activity';

  static const String bookingTimelines = 'booking_timelines';
  static const String paymentReceipts = 'payment_receipts';
  static const String customerDocuments = 'customer_documents';
  static const String bookingGallery = 'booking_gallery';
  static const String rebookRequests = 'rebook_requests';
  static const String offers = 'offers';
  static const String promotions = 'promotions';
  static const String supportTickets = 'support_tickets';
  static const String coupons = 'coupons';
  static const String coordinators = 'coordinators';
  static const String inventory = 'inventory';
  static const String staffLogs = 'staff_logs';
  static const String expenses = 'expenses';
  static const String websiteCms = 'website_cms';
}
