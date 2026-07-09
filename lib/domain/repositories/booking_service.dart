import '../entities/quotation.dart';

abstract class BookingService {
  /// Converts an approved quotation into a formal booked reservation.
  /// This interface prepares the system for future booking workflow automation
  /// without introducing mocked or fake implementations.
  Future<void> createFromQuotation(Quotation quotation);
}
