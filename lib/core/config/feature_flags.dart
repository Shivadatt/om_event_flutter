// TEMP DISABLED - OM EVENTS ADVANCED FEATURE
// REASON: Not required for current business flow.
// DO NOT DELETE - Keep for future reactivation.

/// Centralized configuration flags for Om Events & Decorators.
/// Allows safe disabling/enabling of enterprise and advanced features.
class FeatureFlags {
  FeatureFlags._();

  /// Maintenance Center UI and manual/automatic maintenance triggers.
  static const bool advancedMaintenance = false;

  /// Scheduler health monitoring UI, polling, and diagnostics.
  static const bool schedulerHealth = false;

  /// Complete notification infrastructure (FCM, local notifications, queues).
  static const bool notifications = false;

  /// Real-time quotation collaboration stream and message sending.
  /// (Customer contact CTAs like WhatsApp and Instagram remain active).
  static const bool realtimeQuotationChat = false;

  /// Advanced quotation negotiation workflows and version comparison.
  static const bool quotationNegotiation = false;

  /// Multi-version quotation revision requests and history sheets.
  static const bool quotationRevisions = false;
}
