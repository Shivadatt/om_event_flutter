class OfficeBranch {
  final String id;
  final String branchName;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String googleMapUrl;
  final String latitude;
  final String longitude;
  final String phone1;
  final String phone2;
  final String whatsapp;
  final String email;
  final String instagram;
  final String businessHours;
  final bool isPrimary;

  const OfficeBranch({
    required this.id,
    required this.branchName,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.googleMapUrl,
    required this.latitude,
    required this.longitude,
    required this.phone1,
    required this.phone2,
    required this.whatsapp,
    required this.email,
    required this.instagram,
    required this.businessHours,
    required this.isPrimary,
  });

  factory OfficeBranch.fromMap(String id, Map<dynamic, dynamic> map) {
    return OfficeBranch(
      id: id,
      branchName: map['branchName'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      pincode: map['pincode'] ?? '',
      googleMapUrl: map['googleMapUrl'] ?? '',
      latitude: map['latitude'] ?? '',
      longitude: map['longitude'] ?? '',
      phone1: map['phone1'] ?? '',
      phone2: map['phone2'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      instagram: map['instagram'] ?? '',
      businessHours: map['businessHours'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branchName': branchName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'googleMapUrl': googleMapUrl,
      'latitude': latitude,
      'longitude': longitude,
      'phone1': phone1,
      'phone2': phone2,
      'whatsapp': whatsapp,
      'email': email,
      'instagram': instagram,
      'businessHours': businessHours,
      'isPrimary': isPrimary,
    };
  }
}

class BusinessProfile {
  final String name;
  final String companyName;
  final String logo;
  final String whiteLogo;
  final String favicon;
  final String gst;
  final String pan;
  final String ownerName;
  final String phone;
  final String email;
  final String whatsapp;
  final List<OfficeBranch> officeBranches;
  final String workingHours;
  final Map<String, String> socialLinks;

  const BusinessProfile({
    required this.name,
    required this.companyName,
    required this.logo,
    required this.whiteLogo,
    required this.favicon,
    required this.gst,
    required this.pan,
    required this.ownerName,
    required this.phone,
    required this.email,
    required this.whatsapp,
    required this.officeBranches,
    required this.workingHours,
    required this.socialLinks,
  });

  factory BusinessProfile.defaultVal() {
    return const BusinessProfile(
      name: "Om Events",
      companyName: "Om Events & Decorators",
      logo: "",
      whiteLogo: "",
      favicon: "",
      gst: "",
      pan: "",
      ownerName: "Shivadatt",
      phone: "919512149944",
      email: "omeventsanddecorators@gmail.com",
      whatsapp: "Hello Om Events, I'd like to plan an event.",
      officeBranches: [
        OfficeBranch(
          id: "branch_1",
          branchName: "Kadi Main Office",
          address: "near mahadev mandir medha",
          city: "kadi",
          state: "mahesana",
          country: "India",
          pincode: "382715",
          googleMapUrl: "",
          latitude: "",
          longitude: "",
          phone1: "919512149944",
          phone2: "",
          whatsapp: "919512149944",
          email: "omeventsanddecorators@gmail.com",
          instagram: "https://www.instagram.com/om_events_and_decorators/",
          businessHours: "9:00 AM - 8:00 PM",
          isPrimary: true,
        ),
        OfficeBranch(
          id: "branch_2",
          branchName: "Thangadh Office",
          address: "thangath",
          city: "Thangath",
          state: "Gujarat",
          country: "India",
          pincode: "",
          googleMapUrl: "",
          latitude: "",
          longitude: "",
          phone1: "9313513156",
          phone2: "",
          whatsapp: "9313513156",
          email: "omeventsanddecorators@gmail.com",
          instagram: "https://www.instagram.com/om_events__decorators/",
          businessHours: "9:00 AM - 8:00 PM",
          isPrimary: false,
        ),
      ],
      workingHours: "9:00 AM - 8:00 PM",
      socialLinks: {
        "instagram_kadi": "https://www.instagram.com/om_events_and_decorators/",
        "instagram_thangadh":
            "https://www.instagram.com/om_events__decorators/",
      },
    );
  }
}

class HomepageSettings {
  final String heroTitle;
  final String heroSubtitle;
  final String heroEyebrow;
  final List<dynamic> heroButtons;
  final List<dynamic> heroImages;
  final String heroVideo;
  final String heroBadge;
  final List<dynamic> statistics;
  final List<dynamic> benefits;
  final String about;
  final String cta;
  final String whyChooseUs;
  final String galleryHeader;
  final String reviewHeader;
  final String faqHeader;
  final Map<String, dynamic> sectionVisibility;
  final List<dynamic> sectionOrder;
  final List<dynamic> faqs;

  const HomepageSettings({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroEyebrow,
    required this.heroButtons,
    required this.heroImages,
    required this.heroVideo,
    required this.heroBadge,
    required this.statistics,
    required this.benefits,
    required this.about,
    required this.cta,
    required this.whyChooseUs,
    required this.galleryHeader,
    required this.reviewHeader,
    required this.faqHeader,
    required this.sectionVisibility,
    required this.sectionOrder,
    required this.faqs,
  });

  factory HomepageSettings.defaultVal() {
    return const HomepageSettings(
      heroTitle: "Celebrations,\nthoughtfully composed.",
      heroSubtitle:
          "From the first sketch to the final flower, create an experience that feels...",
      heroEyebrow: "BESPOKE EVENT DESIGN • AHMEDABAD",
      heroButtons: [],
      heroImages: [],
      heroVideo: "",
      heroBadge: "Ivory Vow",
      statistics: [],
      benefits: [],
      about: "",
      cta: "",
      whyChooseUs: "",
      galleryHeader: "",
      reviewHeader: "",
      faqHeader: "",
      sectionVisibility: {},
      sectionOrder: [],
      faqs: [],
    );
  }
}

class ThemeSettings {
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final Map<String, dynamic> darkColors;
  final Map<String, dynamic> lightColors;
  final String typography;
  final double borderRadius;
  final String buttonStyle;
  final String cardStyle;
  final double animationSpeed;

  const ThemeSettings({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.darkColors,
    required this.lightColors,
    required this.typography,
    required this.borderRadius,
    required this.buttonStyle,
    required this.cardStyle,
    required this.animationSpeed,
  });

  factory ThemeSettings.defaultVal() {
    return const ThemeSettings(
      primaryColor: "#1E2B27",
      secondaryColor: "#D3AD7B",
      accentColor: "#C9A77E",
      darkColors: {},
      lightColors: {},
      typography: "Italiana",
      borderRadius: 4.0,
      buttonStyle: "solid",
      cardStyle: "flat",
      animationSpeed: 1.0,
    );
  }
}

class SEOSettings {
  final String defaultTitle;
  final String metaDescription;
  final String keywords;
  final String canonicalUrl;
  final Map<String, dynamic> openGraph;
  final Map<String, dynamic> twitterCard;
  final Map<String, dynamic> jsonLd;
  final String robots;

  const SEOSettings({
    required this.defaultTitle,
    required this.metaDescription,
    required this.keywords,
    required this.canonicalUrl,
    required this.openGraph,
    required this.twitterCard,
    required this.jsonLd,
    required this.robots,
  });

  factory SEOSettings.defaultVal() {
    return const SEOSettings(
      defaultTitle: "Om Events — Crafting Unforgettable Moments",
      metaDescription: "Bespoke event planning and decorators.",
      keywords: "om events, decorators",
      canonicalUrl: "",
      openGraph: {},
      twitterCard: {},
      jsonLd: {},
      robots: "index, follow",
    );
  }
}

class FooterSettings {
  final String description;
  final String copyright;
  final List<dynamic> quickLinks;
  final List<dynamic> legalLinks;
  final Map<String, dynamic> contact;
  final Map<String, dynamic> socialLinks;

  const FooterSettings({
    required this.description,
    required this.copyright,
    required this.quickLinks,
    required this.legalLinks,
    required this.contact,
    required this.socialLinks,
  });

  factory FooterSettings.defaultVal() {
    return const FooterSettings(
      description: "Moments pass. Beautiful ones echo.",
      copyright: "© 2026 Om Events. Made with care in Gujarat.",
      quickLinks: [],
      legalLinks: [],
      contact: {},
      socialLinks: {},
    );
  }
}

class ContactSettings {
  final String phone;
  final String email;
  final String whatsapp;
  final String address;
  final String googleMaps;
  final List<dynamic> branches;

  const ContactSettings({
    required this.phone,
    required this.email,
    required this.whatsapp,
    required this.address,
    required this.googleMaps,
    required this.branches,
  });

  factory ContactSettings.defaultVal() {
    return const ContactSettings(
      phone: "919512149944",
      email: "omeventsanddecorators@gmail.com",
      whatsapp: "Hello Om Events...",
      address: "Gujarat, India",
      googleMaps: "",
      branches: [],
    );
  }
}

class PricingSettings {
  final double gst;
  final double deliveryCharge;
  final double travelCharge;
  final double discount;
  final List<dynamic> coupons;
  final double advanceAmount;

  const PricingSettings({
    required this.gst,
    required this.deliveryCharge,
    required this.travelCharge,
    required this.discount,
    required this.coupons,
    required this.advanceAmount,
  });

  factory PricingSettings.defaultVal() {
    return const PricingSettings(
      gst: 18.0,
      deliveryCharge: 500.0,
      travelCharge: 0.0,
      discount: 0.0,
      coupons: [],
      advanceAmount: 0.0,
    );
  }
}

class BookingSettings {
  final List<dynamic> bookingRules;
  final int advanceDays;
  final String workingHours;
  final List<dynamic> cancellationRules;
  final List<dynamic> refundRules;

  const BookingSettings({
    required this.bookingRules,
    required this.advanceDays,
    required this.workingHours,
    required this.cancellationRules,
    required this.refundRules,
  });

  factory BookingSettings.defaultVal() {
    return const BookingSettings(
      bookingRules: [],
      advanceDays: 7,
      workingHours: "9:00 AM - 8:00 PM",
      cancellationRules: [],
      refundRules: [],
    );
  }
}

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

class StatisticsSettings {
  final int completedEvents;
  final int happyClients;
  final int cities;
  final int years;

  const StatisticsSettings({
    required this.completedEvents,
    required this.happyClients,
    required this.cities,
    required this.years,
  });

  factory StatisticsSettings.defaultVal() {
    return const StatisticsSettings(
      completedEvents: 650,
      happyClients: 650,
      cities: 12,
      years: 8,
    );
  }
}

class FeatureFlagsSettings {
  final bool enableReviews;
  final bool enableGallery;
  final bool enableBooking;
  final bool enablePayments;
  final bool enableCart;
  final bool enableQuotes;
  final bool enableAnalytics;

  const FeatureFlagsSettings({
    required this.enableReviews,
    required this.enableGallery,
    required this.enableBooking,
    required this.enablePayments,
    required this.enableCart,
    required this.enableQuotes,
    required this.enableAnalytics,
  });

  factory FeatureFlagsSettings.defaultVal() {
    return const FeatureFlagsSettings(
      enableReviews: true,
      enableGallery: true,
      enableBooking: true,
      enablePayments: false,
      enableCart: true,
      enableQuotes: true,
      enableAnalytics: false,
    );
  }
}

class MaintenanceSettings {
  final bool maintenanceMode;
  final String message;
  final String eta;

  const MaintenanceSettings({
    required this.maintenanceMode,
    required this.message,
    required this.eta,
  });

  factory MaintenanceSettings.defaultVal() {
    return const MaintenanceSettings(
      maintenanceMode: false,
      message: "System is undergoing scheduled maintenance.",
      eta: "2 hours",
    );
  }
}

class AppSettings {
  final String version;
  final bool forceUpdate;
  final int buildNumber;

  const AppSettings({
    required this.version,
    required this.forceUpdate,
    required this.buildNumber,
  });

  factory AppSettings.defaultVal() {
    return const AppSettings(
      version: "1.0.0",
      forceUpdate: false,
      buildNumber: 1,
    );
  }
}

// Additional dynamic CMS classes
class AboutSettings {
  final String description;
  final String mission;
  final String vision;
  final String story;

  const AboutSettings({
    required this.description,
    required this.mission,
    required this.vision,
    required this.story,
  });

  factory AboutSettings.defaultVal() {
    return const AboutSettings(
      description: "",
      mission: "",
      vision: "",
      story: "",
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

class DashboardSettings {
  final String welcomeMessage;
  final List<dynamic> activeWidgets;
  const DashboardSettings({
    required this.welcomeMessage,
    required this.activeWidgets,
  });
  factory DashboardSettings.defaultVal() {
    return const DashboardSettings(
      welcomeMessage: "Welcome back, Admin",
      activeWidgets: [],
    );
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

class HomeSectionsSettings {
  final List<dynamic> activeSections;
  const HomeSectionsSettings({required this.activeSections});
  factory HomeSectionsSettings.defaultVal() {
    return const HomeSectionsSettings(activeSections: []);
  }
}

class CtaSettings {
  final String buttonText;
  final String buttonUrl;
  const CtaSettings({required this.buttonText, required this.buttonUrl});
  factory CtaSettings.defaultVal() {
    return const CtaSettings(buttonText: "Get Started", buttonUrl: "");
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
    return const VideoSettings(videosList: []);
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
