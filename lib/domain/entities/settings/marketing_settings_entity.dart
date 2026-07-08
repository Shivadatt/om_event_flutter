part of '../settings_entities.dart';

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

class CtaSettings {
  final String buttonText;
  final String buttonUrl;
  const CtaSettings({required this.buttonText, required this.buttonUrl});
  factory CtaSettings.defaultVal() {
    return const CtaSettings(buttonText: "Get Started", buttonUrl: "");
  }
}

class HomeSectionsSettings {
  final List<dynamic> activeSections;
  const HomeSectionsSettings({required this.activeSections});
  factory HomeSectionsSettings.defaultVal() {
    return const HomeSectionsSettings(activeSections: []);
  }
}
