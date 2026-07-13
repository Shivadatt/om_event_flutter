part of '../settings_entities.dart';

class NotificationsSettings {
  final Map<String, dynamic> pushTemplates;
  final Map<String, dynamic> smsTemplates;
  final Map<String, dynamic> emailTemplates;

  const NotificationsSettings({
    required this.pushTemplates,
    required this.smsTemplates,
    required this.emailTemplates,
  });

  factory NotificationsSettings.defaultVal() {
    return const NotificationsSettings(
      pushTemplates: {},
      smsTemplates: {},
      emailTemplates: {},
    );
  }
}

class PDFSettings {
  final String invoiceHeader;
  final String invoiceFooter;
  final String terms;
  final Map<String, dynamic> bankDetails;
  final String upi;
  final String signature;

  const PDFSettings({
    required this.invoiceHeader,
    required this.invoiceFooter,
    required this.terms,
    required this.bankDetails,
    required this.upi,
    required this.signature,
  });

  factory PDFSettings.defaultVal() {
    return const PDFSettings(
      invoiceHeader: "",
      invoiceFooter: "",
      terms: "",
      bankDetails: {},
      upi: "",
      signature: "",
    );
  }
}

class EmailTemplatesSettings {
  final Map<String, dynamic> templates;
  const EmailTemplatesSettings({required this.templates});
  factory EmailTemplatesSettings.defaultVal() {
    return const EmailTemplatesSettings(templates: {});
  }
}

class SmsTemplatesSettings {
  final Map<String, dynamic> templates;
  const SmsTemplatesSettings({required this.templates});
  factory SmsTemplatesSettings.defaultVal() {
    return const SmsTemplatesSettings(templates: {});
  }
}

class InvoiceSettings {
  final String taxNumber;
  final String invoiceNote;
  const InvoiceSettings({required this.taxNumber, required this.invoiceNote});
  factory InvoiceSettings.defaultVal() {
    return const InvoiceSettings(taxNumber: "", invoiceNote: "");
  }
}

class AnalyticsSettings {
  final String measurementId;
  final bool enableTracking;
  const AnalyticsSettings({
    required this.measurementId,
    required this.enableTracking,
  });
  factory AnalyticsSettings.defaultVal() {
    return const AnalyticsSettings(measurementId: "", enableTracking: false);
  }
}

class WorkingHoursSettings {
  final List<dynamic> weekdayHours;
  final List<dynamic> holidays;
  const WorkingHoursSettings({
    required this.weekdayHours,
    required this.holidays,
  });
  factory WorkingHoursSettings.defaultVal() {
    return const WorkingHoursSettings(weekdayHours: [], holidays: []);
  }
}

class PoliciesSettings {
  final String privacyPolicy;
  final String termsOfService;
  final String refundPolicy;
  const PoliciesSettings({
    required this.privacyPolicy,
    required this.termsOfService,
    required this.refundPolicy,
  });
  factory PoliciesSettings.defaultVal() {
    return const PoliciesSettings(
      privacyPolicy: "",
      termsOfService: "",
      refundPolicy: "",
    );
  }
}

class ValidationSettings {
  final Map<String, dynamic> validationRules;
  const ValidationSettings({required this.validationRules});
  factory ValidationSettings.defaultVal() {
    return const ValidationSettings(validationRules: {});
  }
}

class MessagesSettings {
  final Map<String, dynamic> customMessages;
  const MessagesSettings({required this.customMessages});
  factory MessagesSettings.defaultVal() {
    return const MessagesSettings(customMessages: {});
  }
}

class GallerySettings {
  final bool enableGrid;
  final int columns;
  const GallerySettings({required this.enableGrid, required this.columns});
  factory GallerySettings.defaultVal() {
    return const GallerySettings(enableGrid: true, columns: 3);
  }
}

class VideoSettings {
  final List<dynamic> videosList;
  const VideoSettings({required this.videosList});
  factory VideoSettings.defaultVal() {
    return const VideoSettings(videosList: [
      {
        'eyebrow': 'LIVE FROM THE SETUP',
        'titlePart1': 'A Glimpse Before',
        'titlePart2': 'the big day.',
        'description': 'A raw snapshot of the layout and styling details as we ready a celebration. No filters, no edits — just an honest look at how our crew sets up.',
        'facts': [
          'Balloon decor setup walk',
          'Luxury hotel setting',
          'Pre-event quality inspection'
        ],
        'videoAsset': 'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/Video/Birthday.mp4',
        'posterAsset': 'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public/gallery/images/birthday.jpg',
      },
      {
        'eyebrow': 'MOMENTS IN MOTION',
        'titlePart1': 'Balloon Blast',
        'titlePart2': 'the perfect surprise.',
        'description': 'A high-energy moment captured as hundreds of vibrant balloons take flight. Designed for maximum visual impact during key entry or milestone moments.',
        'facts': [
          'Hundreds of floating balloons',
          'Synchronized release system',
          'Joyous outdoor celebration'
        ],
        'videoAsset': 'assets/videos/Balloonblast.mp4',
        'posterAsset': 'assets/images/BaloonBlast.jpg',
      }
    ]);
  }
}

class ReviewSettings {
  final bool enableSorting;
  final double minimumStars;
  const ReviewSettings({
    required this.enableSorting,
    required this.minimumStars,
  });
  factory ReviewSettings.defaultVal() {
    return const ReviewSettings(enableSorting: true, minimumStars: 4.0);
  }
}

class FaqSettings {
  final String title;
  final bool enableAccordion;
  const FaqSettings({required this.title, required this.enableAccordion});
  factory FaqSettings.defaultVal() {
    return const FaqSettings(title: "FAQ", enableAccordion: true);
  }
}
