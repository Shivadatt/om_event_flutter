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
      benefits: [
        {
          'icon': '◇',
          'title': 'Personal Design',
          'desc':
              'A concept shaped around your story, venue and budget — never a fixed package.',
        },
        {
          'icon': '†',
          'title': 'Clear Live Pricing',
          'desc':
              'Build your wishlist and see every charge before you send an enquiry.',
        },
        {
          'icon': '○',
          'title': 'One Accountable Team',
          'desc':
              'Design, production & collection — one team that stays with you end-to-end.',
        },
        {
          'icon': '✓',
          'title': 'Venue-Ready Planning',
          'desc':
              'Timelines, layouts, permit and installation details — you stay well in advance.',
        },
        {
          'icon': '+',
          'title': 'Premium Execution',
          'desc':
              'Proposal to install, careful finishing and a crew that respects the space.',
        },
        {
          'icon': '◎',
          'title': 'Calm on Event Day',
          'desc':
              'A dedicated coordinator keeps the moving parts invisible to you.',
        },
      ],
      about: "",
      cta: "",
      whyChooseUs: "",
      galleryHeader: "",
      reviewHeader: "",
      faqHeader: "",
      sectionVisibility: {},
      sectionOrder: [],
      faqs: [
        {
          'category': 'BOOKING',
          'question': 'How far in advance should I book?',
          'answer':
              'We recommend booking at least 7 to 30 days in advance for milestone birthdays and private celebrations, and 2 to 6 months for lavish weddings and grand receptions. Because we commit to an exclusive single-event-per-day focus for peak dates, early reservations lock your date securely.',
        },
        {
          'category': 'BOOKING',
          'question': 'Can I book within 24 hours?',
          'answer':
              'Last-minute bookings (within 24–48 hours) depend on slot availability, warehouse inventory, and crew bandwidth. If our studio has open capacity, we can accommodate express setups. Please contact our team directly via WhatsApp for instant feasibility.',
        },
        {
          'category': 'BOOKING',
          'question': 'How many events can you handle per day?',
          'answer':
              'To guarantee flawless execution, bespoke craftsmanship, and uncompromised attention to detail, we strictly limit our schedule to 1 or 2 premium events per day. We do not mass-produce setups.',
        },
        {
          'category': 'BOOKING',
          'question': 'How do I check date availability?',
          'answer':
              'You can check real-time date availability directly on our booking form by selecting your desired date. Our system performs live calendar verification against booked slots.',
        },
        {
          'category': 'PACKAGES',
          'question': 'What are Basic, Premium, and Luxury packages?',
          'answer':
              'Basic packages feature refined core elements like standard arch backdrops, balloon garlands, and elegant focal points. Premium packages introduce layered textures, ambient neon lighting, themed props, and floral accents. Luxury packages deliver couture ceiling installations, imported fresh florals, bespoke signage, cold pyro effects, and custom fabricated structures.',
        },
        {
          'category': 'PACKAGES',
          'question': 'Can I customize an existing package?',
          'answer':
              'Yes, every package is fully customizable. You can mix and match color tones, balloon finishes (matte, chrome, pastel, metallic), floral types, custom cutouts, and lighting styles to suit your venue.',
        },
        {
          'category': 'PACKAGES',
          'question': 'Can I send a reference image for my design?',
          'answer':
              'Absolutely! When submitting a booking request on our website, you can upload your Pinterest boards, Instagram photos, or custom sketches. Our creative directors will align our fabrication with your reference.',
        },
        {
          'category': 'LOCATION',
          'question': 'Which areas do you serve?',
          'answer':
              'Our dual base studios are in Kadi (Mehsana) and Thangadh (Surendranagar). We offer free standard delivery across Kadi, Kalol, Mehsana, Ahmedabad, Gandhinagar, Thangadh, and Surendranagar. We also cater to extended Gujarat cities (Rajkot, Anand, Vadodara, Patan, Himatnagar) and destination venues.',
        },
        {
          'category': 'LOCATION',
          'question': 'Are travel charges applicable for outstation events?',
          'answer':
              'Travel and logistics within our primary zones are included. For extended Gujarat zones or destination venues outside 40 km from our studios, transparent round-trip logistics and crew transport charges apply and are itemized in your quote.',
        },
        {
          'category': 'CANCELLATION',
          'question': 'How can I cancel a booking?',
          'answer':
              'You can request cancellation directly from your online Booking Tracker by clicking "Request Cancellation" and providing a reason, or by contacting your assigned coordinator on WhatsApp.',
        },
        {
          'category': 'CANCELLATION',
          'question': 'When can I request cancellation and what is the refund policy?',
          'answer':
              'Cancellations requested 15+ days prior to the event are eligible for rescheduling credit or refund minus minimal processing fees. Between 7–14 days prior, 50% of the advance is retained for already procured custom materials. Cancellations under 7 days are non-refundable due to slot and prop reservation.',
        },
        {
          'category': 'CANCELLATION',
          'question': 'What happens after I submit a cancellation request?',
          'answer':
              'Your request is logged with a timestamp in our system. You will receive an immediate in-app and WhatsApp confirmation, and our administrative coordinator will review and process eligible refunds within 5–7 business days.',
        },
        {
          'category': 'BOOKING PROCESS',
          'question': 'How do I track my booking status?',
          'answer':
              'Enter your unique Booking ID (e.g., OM-20260928-104) into the Booking Tracker dialog accessible from the top navigation bar or footer. You can monitor request acceptance, proposal finalization, and event day execution in real time.',
        },
        {
          'category': 'BOOKING PROCESS',
          'question': 'What is my Booking ID?',
          'answer':
              'Your Booking ID is generated instantly upon submitting your reservation form. It follows the format OM-YYYYMMDD-XXX and is displayed on your screen, sent via WhatsApp, and stored in your browser session.',
        },
        {
          'category': 'BOOKING PROCESS',
          'question': 'How will I know if my booking is accepted?',
          'answer':
              'You will receive an in-app notification update and our team will connect with you via WhatsApp and phone within a few hours to finalize your styling brief and confirm advance token payment.',
        },
        {
          'category': 'DECORATION',
          'question': 'Do you provide decoration only, or complete event management?',
          'answer':
              'Our primary specialization is luxury decor, floral design, thematic backdrops, and atmospheric lighting. We also collaborate closely with trusted catering, photography, and sound partners upon request.',
        },
        {
          'category': 'DECORATION',
          'question': 'Can I choose specific colors and thematic materials?',
          'answer':
              'Yes, our styling team presents detailed digital color swatches and mood boards. We match exact pantone shades, fabric textures (velvet, silk, linen), and floral species to your celebration vision.',
        },
      ],
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
