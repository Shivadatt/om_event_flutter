import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/quotation.dart';
import '../constants/app_strings.dart';
import '../services/business_details_service.dart';
import '../utils/formatters.dart';

/// Model representing a canonical business contact option (WhatsApp or Voice Phone).
class BusinessContactOption {
  final String label;
  final String rawPhone;
  final String displayPhone;
  final bool isPrimary;

  const BusinessContactOption({
    required this.label,
    required this.rawPhone,
    required this.displayPhone,
    this.isPrimary = false,
  });
}

/// Centralized utility for phone normalization and customer-facing WhatsApp & booking communication.
class BookingCommunicationHelper {
  BookingCommunicationHelper._();

  /// Normalizes any phone string (+91 95121 49944, 91-95121-49944, 9512149944)
  /// into a standard E.164 country-code prefixed numeric string (e.g. 919512149944).
  static String normalizePhone(String rawPhone) {
    final clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '91$clean';
    } else if (clean.length == 12 && clean.startsWith('91')) {
      return clean;
    } else if (clean.length == 11 && clean.startsWith('0')) {
      return '91${clean.substring(1)}';
    }
    return clean.isNotEmpty ? clean : AppStrings.businessPhone;
  }

  /// Formats any phone number cleanly for human display (+91 95121 49944).
  static String formatDisplayPhone(String rawPhone) {
    final clean = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '+91 ${clean.substring(0, 5)} ${clean.substring(5)}';
    } else if (clean.length == 12 && clean.startsWith('91')) {
      final ten = clean.substring(2);
      return '+91 ${ten.substring(0, 5)} ${ten.substring(5)}';
    }
    return rawPhone.trim().isNotEmpty ? rawPhone.trim() : '+91 95121 49944';
  }

  /// Resolves all active business WhatsApp contact options (Primary & Secondary).
  static List<BusinessContactOption> getBusinessWhatsAppOptions() {
    final List<BusinessContactOption> options = [];
    try {
      if (Get.isRegistered<BusinessDetailsService>()) {
        final details = BusinessDetailsService.to.rxDetails.value;
        final activeWa = details.contacts.whatsapps.where((c) => c.isActive && c.value.isNotEmpty).toList();
        if (activeWa.isNotEmpty) {
          for (final wa in activeWa) {
            final isPrimary = wa.isPrimary ||
                wa.label.toLowerCase().contains('primary') ||
                wa.value.contains('93135');
            String cleanLabel = wa.label
                .replaceAll(RegExp(r'\s*WhatsApp\s*$', caseSensitive: false), '')
                .trim();
            if (cleanLabel.isEmpty) {
              cleanLabel = isPrimary ? "WhatsApp" : "Kadi (Medha)";
            }
            final display = formatDisplayPhone(wa.value);
            options.add(BusinessContactOption(
              label: cleanLabel,
              rawPhone: wa.value,
              displayPhone: display,
              isPrimary: isPrimary,
            ));
          }
        }
      }
    } catch (_) {}

    // Ensure both canonical business numbers exist
    if (options.isEmpty) {
      options.add(const BusinessContactOption(
        label: "WhatsApp",
        rawPhone: "+91 93135 13156",
        displayPhone: "+91 93135 13156",
        isPrimary: true,
      ));
      options.add(const BusinessContactOption(
        label: "Kadi (Medha)",
        rawPhone: "+91 95121 49944",
        displayPhone: "+91 95121 49944",
        isPrimary: false,
      ));
    } else if (options.length == 1) {
      if (options.first.rawPhone.contains('93135')) {
        options.add(const BusinessContactOption(
          label: "Kadi (Medha)",
          rawPhone: "+91 95121 49944",
          displayPhone: "+91 95121 49944",
          isPrimary: false,
        ));
      } else {
        options.insert(
          0,
          const BusinessContactOption(
            label: "WhatsApp",
            rawPhone: "+91 93135 13156",
            displayPhone: "+91 93135 13156",
            isPrimary: true,
          ),
        );
      }
    }
    return options;
  }

  /// Resolves all active business phone contact options for voice calling (Primary & Secondary).
  static List<BusinessContactOption> getBusinessPhoneOptions() {
    final List<BusinessContactOption> options = [];
    try {
      if (Get.isRegistered<BusinessDetailsService>()) {
        final details = BusinessDetailsService.to.rxDetails.value;
        final activePhones = details.contacts.phones.where((c) => c.isActive && c.value.isNotEmpty).toList();
        if (activePhones.isNotEmpty) {
          for (final p in activePhones) {
            final isPrimary = p.isPrimary ||
                p.label.toLowerCase().contains('primary') ||
                p.value.contains('93135');
            String cleanLabel = p.label.trim();
            if (cleanLabel.isEmpty) {
              cleanLabel = isPrimary ? "Primary" : "Secondary";
            }
            final display = formatDisplayPhone(p.value);
            options.add(BusinessContactOption(
              label: cleanLabel,
              rawPhone: p.value,
              displayPhone: display,
              isPrimary: isPrimary,
            ));
          }
        }
      }
    } catch (_) {}

    // Ensure both canonical business numbers exist
    if (options.isEmpty) {
      options.add(const BusinessContactOption(
        label: "Primary",
        rawPhone: "+91 93135 13156",
        displayPhone: "+91 93135 13156",
        isPrimary: true,
      ));
      options.add(const BusinessContactOption(
        label: "Secondary",
        rawPhone: "+91 95121 49944",
        displayPhone: "+91 95121 49944",
        isPrimary: false,
      ));
    } else if (options.length == 1) {
      if (options.first.rawPhone.contains('93135')) {
        options.add(const BusinessContactOption(
          label: "Secondary",
          rawPhone: "+91 95121 49944",
          displayPhone: "+91 95121 49944",
          isPrimary: false,
        ));
      } else {
        options.insert(
          0,
          const BusinessContactOption(
            label: "Primary",
            rawPhone: "+91 93135 13156",
            displayPhone: "+91 93135 13156",
            isPrimary: true,
          ),
        );
      }
    }
    return options;
  }

  /// Resolves the primary active business WhatsApp number from dynamic settings or fallback.
  static String getBusinessWhatsAppNumber() {
    final options = getBusinessWhatsAppOptions();
    return normalizePhone(options.first.rawPhone);
  }

  /// Resolves the primary business phone number for voice calling.
  static String getBusinessPhoneNumber() {
    final options = getBusinessPhoneOptions();
    return normalizePhone(options.first.rawPhone);
  }

  /// Resolves the primary business email address.
  static String getBusinessEmail() {
    try {
      if (Get.isRegistered<BusinessDetailsService>()) {
        final details = BusinessDetailsService.to.rxDetails.value;
        final activeEmails = details.contacts.emails.where((c) => c.isActive).toList();
        if (activeEmails.isNotEmpty) {
          final primary = activeEmails.firstWhere((c) => c.isPrimary, orElse: () => activeEmails.first);
          return primary.value;
        }
      }
    } catch (_) {}
    return AppStrings.businessEmail;
  }

  /// Constructs a standard booking WhatsApp message respecting milestone status.
  static String generateBookingWhatsAppMessage({
    required String bookingId,
    required String serviceName,
    required String packageName,
    required DateTime eventDate,
    QuotationStatus? status,
  }) {
    final formattedDate = AppFormatters.formatDate(eventDate);
    final buffer = StringBuffer();
    buffer.writeln("Hello Om Events & Decorators,");
    buffer.writeln();

    if (status == QuotationStatus.cancelled) {
      buffer.writeln("I am contacting you regarding my cancelled booking.");
    } else if (status == QuotationStatus.acceptedByClient || status == QuotationStatus.bookingConfirmed) {
      buffer.writeln("I am contacting you regarding my confirmed booking.");
    } else {
      buffer.writeln("I am contacting you regarding my booking.");
    }

    buffer.writeln();
    buffer.writeln("Booking ID: $bookingId");
    if (serviceName.isNotEmpty) {
      buffer.writeln("Service: $serviceName");
    }
    if (packageName.isNotEmpty) {
      buffer.writeln("Package: $packageName");
    }
    buffer.writeln("Event Date: $formattedDate");
    buffer.writeln();
    buffer.write("Please assist me with my booking.");

    return buffer.toString();
  }

  /// Generates a general customer inquiry message.
  static String generateGeneralInquiryMessage({
    String? customerName,
    String? eventType,
    String? preferredDate,
  }) {
    final buffer = StringBuffer();
    buffer.writeln("Hello Om Events & Decorators,");
    buffer.writeln();
    if (customerName != null && customerName.trim().isNotEmpty) {
      buffer.writeln("My name is ${customerName.trim()}.");
    }
    buffer.writeln("I would like to inquire about event decoration and styling.");
    if (eventType != null && eventType.trim().isNotEmpty) {
      buffer.writeln("Event Type: ${eventType.trim()}");
    }
    if (preferredDate != null && preferredDate.trim().isNotEmpty) {
      buffer.writeln("Estimated Date: ${preferredDate.trim()}");
    }
    buffer.writeln();
    buffer.write("Please share availability and package details.");
    return buffer.toString();
  }

  /// Launches WhatsApp with the target phone and encoded message.
  static Future<bool> openWhatsApp({
    String? phone,
    required String message,
  }) async {
    final targetPhone = phone != null && phone.isNotEmpty
        ? normalizePhone(phone)
        : getBusinessWhatsAppNumber();

    final uri = Uri.parse("https://wa.me/$targetPhone?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Launches direct phone dialer.
  static Future<bool> openCall([String? phone]) async {
    final targetPhone = phone != null && phone.isNotEmpty
        ? normalizePhone(phone)
        : getBusinessPhoneNumber();
    final uri = Uri.parse("tel:+$targetPhone");
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Launches email composer.
  static Future<bool> openEmail({
    String? email,
    String? subject,
    String? body,
  }) async {
    final targetEmail = email != null && email.isNotEmpty
        ? email
        : getBusinessEmail();
    final query = <String>[];
    if (subject != null && subject.isNotEmpty) {
      query.add("subject=${Uri.encodeComponent(subject)}");
    }
    if (body != null && body.isNotEmpty) {
      query.add("body=${Uri.encodeComponent(body)}");
    }
    final queryString = query.isNotEmpty ? "?${query.join('&')}" : "";
    final uri = Uri.parse("mailto:$targetEmail$queryString");
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }
}
