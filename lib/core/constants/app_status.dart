/// Centralized status string constants used across quotations, leads, and bookings.
class AppStatus {
  AppStatus._();

  // ── Quotation / Booking Statuses ──────────────────────────────────────────

  /// Record is saved but not yet submitted.
  static const String draft = 'draft';

  /// Record has been submitted and awaits review.
  static const String pending = 'pending';

  /// Record has been reviewed and approved.
  static const String confirmed = 'confirmed';

  /// Record work is in progress.
  static const String inProgress = 'in_progress';

  /// Record has been completed.
  static const String completed = 'completed';

  /// Record has been cancelled.
  static const String cancelled = 'cancelled';

  // ── Lead Statuses ─────────────────────────────────────────────────────────

  /// Lead has been received but not yet contacted.
  static const String new_ = 'new';

  /// Lead has been contacted.
  static const String contacted = 'contacted';

  /// Lead has been qualified as a potential customer.
  static const String qualified = 'qualified';

  /// Lead has been successfully converted.
  static const String converted = 'converted';

  /// Lead has been lost or is no longer active.
  static const String lost = 'lost';

  // ── Availability ──────────────────────────────────────────────────────────

  /// Service is available to book.
  static const String available = 'available';

  /// Service is fully booked.
  static const String fullyBooked = 'fully_booked';

  // ── Migration ─────────────────────────────────────────────────────────────

  /// Firestore settings document key for migration lock.
  static const String migrationCompleted = 'migration_completed';

  /// Firestore settings document key for migration date.
  static const String migrationDate = 'migration_date';

  /// Firestore settings document id for the app lock record.
  static const String settingsAppDoc = 'app';

  /// Firestore settings document id for business info.
  static const String settingsBusinessDoc = 'business_info';
}
