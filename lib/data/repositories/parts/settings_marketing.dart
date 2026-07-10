part of '../settings_repository_impl.dart';

mixin SettingsMarketing {
  DocumentReference<Map<String, dynamic>> _getDocRef(String docId);
  Future<void> _saveToDraft(String docId, Map<String, dynamic> draftData);

  Stream<HomepageSettings> streamHomepage() {
    return _getDocRef('homepage')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return HomepageSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return HomepageSettings(
            heroTitle:
                source['heroTitle'] ?? 'Celebrations,\nthoughtfully composed.',
            heroSubtitle:
                source['heroSubtitle'] ??
                'From the first sketch to the final flower, create an experience that feels...',
            heroEyebrow:
                source['heroEyebrow'] ?? 'BESPOKE EVENT DESIGN • AHMEDABAD',
            heroButtons: source['heroButtons'] ?? [],
            heroImages: source['heroImages'] ?? [],
            heroVideo: source['heroVideo'] ?? '',
            heroBadge: source['heroBadge'] ?? 'Ivory Vow',
            statistics: source['statistics'] ?? [],
            benefits: source['benefits'] ?? [],
            about: source['about'] ?? '',
            cta: source['cta'] ?? '',
            whyChooseUs: source['whyChooseUs'] ?? '',
            galleryHeader: source['galleryHeader'] ?? '',
            reviewHeader: source['reviewHeader'] ?? '',
            faqHeader: source['faqHeader'] ?? '',
            sectionVisibility: Map<String, dynamic>.from(
              source['sectionVisibility'] ?? {},
            ),
            sectionOrder: source['sectionOrder'] ?? [],
            faqs: source['faqs'] ?? [],
          );
        });
  }

  Stream<ThemeSettings> streamTheme() {
    return _getDocRef('theme')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ThemeSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return ThemeSettings(
            primaryColor: source['primaryColor'] ?? '#1E2B27',
            secondaryColor: source['secondaryColor'] ?? '#D3AD7B',
            accentColor: source['accentColor'] ?? '#C9A77E',
            darkColors: Map<String, dynamic>.from(source['darkColors'] ?? {}),
            lightColors: Map<String, dynamic>.from(source['lightColors'] ?? {}),
            typography: source['typography'] ?? 'Italiana',
            borderRadius: (source['borderRadius'] ?? 4.0).toDouble(),
            buttonStyle: source['buttonStyle'] ?? 'solid',
            cardStyle: source['cardStyle'] ?? 'flat',
            animationSpeed: (source['animationSpeed'] ?? 1.0).toDouble(),
          );
        });
  }

  Stream<SEOSettings> streamSEO() {
    return _getDocRef('seo')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return SEOSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return SEOSettings(
            defaultTitle: source['defaultTitle'] ?? 'Om Events',
            metaDescription:
                source['metaDescription'] ?? 'Bespoke event decorators.',
            keywords: source['keywords'] ?? '',
            canonicalUrl: source['canonicalUrl'] ?? '',
            openGraph: Map<String, dynamic>.from(source['openGraph'] ?? {}),
            twitterCard: Map<String, dynamic>.from(source['twitterCard'] ?? {}),
            jsonLd: Map<String, dynamic>.from(source['jsonLd'] ?? {}),
            robots: source['robots'] ?? 'index, follow',
          );
        });
  }

  Stream<FooterSettings> streamFooter() {
    return _getDocRef('footer')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return FooterSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return FooterSettings(
            description:
                source['description'] ?? 'Moments pass. Beautiful ones echo.',
            copyright: source['copyright'] ?? '© 2026 Om Events.',
            quickLinks: source['quickLinks'] ?? [],
            legalLinks: source['legalLinks'] ?? [],
            contact: Map<String, dynamic>.from(source['contact'] ?? {}),
            socialLinks: Map<String, dynamic>.from(source['socialLinks'] ?? {}),
          );
        });
  }

  Stream<ContactSettings> streamContact() {
    return _getDocRef('contact')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ContactSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return ContactSettings(
            phone: source['phone'] ?? '919512149944',
            email: source['email'] ?? 'omeventsanddecorators@gmail.com',
            whatsapp: source['whatsapp'] ?? 'Hello Om Events...',
            address: source['address'] ?? 'Gujarat, India',
            googleMaps: source['googleMaps'] ?? '',
            branches: source['branches'] ?? [],
          );
        });
  }

  Stream<AboutSettings> streamAbout() {
    return _getDocRef('about')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return AboutSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return AboutSettings(
            description: source['description'] ?? '',
            mission: source['mission'] ?? '',
            vision: source['vision'] ?? '',
            story: source['story'] ?? '',
          );
        });
  }

  Stream<CtaSettings> streamCta() {
    return _getDocRef('cta')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return CtaSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return CtaSettings(
            buttonText: source['buttonText'] ?? 'Get Started',
            buttonUrl: source['buttonUrl'] ?? '',
          );
        });
  }

  Stream<HomeSectionsSettings> streamHomeSections() {
    return _getDocRef('home_sections')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return HomeSectionsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return HomeSectionsSettings(
            activeSections: source['activeSections'] ?? [],
          );
        });
  }

  Future<void> saveHomepage(HomepageSettings homepage) async {
    await _saveToDraft('homepage', {
      'heroTitle': homepage.heroTitle,
      'heroSubtitle': homepage.heroSubtitle,
      'heroEyebrow': homepage.heroEyebrow,
      'heroButtons': homepage.heroButtons,
      'heroImages': homepage.heroImages,
      'heroVideo': homepage.heroVideo,
      'heroBadge': homepage.heroBadge,
      'statistics': homepage.statistics,
      'benefits': homepage.benefits,
      'faqs': homepage.faqs,
      'about': homepage.about,
      'cta': homepage.cta,
      'whyChooseUs': homepage.whyChooseUs,
      'galleryHeader': homepage.galleryHeader,
      'reviewHeader': homepage.reviewHeader,
      'faqHeader': homepage.faqHeader,
      'sectionVisibility': homepage.sectionVisibility,
      'sectionOrder': homepage.sectionOrder,
    });
  }

  Future<void> saveTheme(ThemeSettings theme) async {
    await _saveToDraft('theme', {
      'primaryColor': theme.primaryColor,
      'secondaryColor': theme.secondaryColor,
      'accentColor': theme.accentColor,
      'darkColors': theme.darkColors,
      'lightColors': theme.lightColors,
      'typography': theme.typography,
      'borderRadius': theme.borderRadius,
      'buttonStyle': theme.buttonStyle,
      'cardStyle': theme.cardStyle,
      'animationSpeed': theme.animationSpeed,
    });
  }

  Future<void> saveSEO(SEOSettings seo) async {
    await _saveToDraft('seo', {
      'defaultTitle': seo.defaultTitle,
      'metaDescription': seo.metaDescription,
      'keywords': seo.keywords,
      'canonicalUrl': seo.canonicalUrl,
      'openGraph': seo.openGraph,
      'twitterCard': seo.twitterCard,
      'jsonLd': seo.jsonLd,
      'robots': seo.robots,
    });
  }

  Future<void> saveFooter(FooterSettings footer) async {
    await _saveToDraft('footer', {
      'description': footer.description,
      'copyright': footer.copyright,
      'quickLinks': footer.quickLinks,
      'legalLinks': footer.legalLinks,
      'contact': footer.contact,
      'socialLinks': footer.socialLinks,
    });
  }

  Future<void> saveContact(ContactSettings contact) async {
    await _saveToDraft('contact', {
      'phone': contact.phone,
      'email': contact.email,
      'whatsapp': contact.whatsapp,
      'address': contact.address,
      'googleMaps': contact.googleMaps,
      'branches': contact.branches,
    });
  }

  Future<void> saveAbout(AboutSettings about) async {
    await _saveToDraft('about', {
      'description': about.description,
      'mission': about.mission,
      'vision': about.vision,
      'story': about.story,
    });
  }

  Future<void> saveCta(CtaSettings cta) async {
    await _saveToDraft('cta', {
      'buttonText': cta.buttonText,
      'buttonUrl': cta.buttonUrl,
    });
  }

  Future<void> saveHomeSections(HomeSectionsSettings sections) async {
    await _saveToDraft('home_sections', {
      'activeSections': sections.activeSections,
    });
  }
}
