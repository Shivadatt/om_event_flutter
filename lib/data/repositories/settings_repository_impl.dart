import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:om_event/core/constants/app_collections.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/entities/contact_number_entity.dart';
import '../models/contact_number_model.dart';
import '../mappers/contact_number_mapper.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Streams
  @override
  Stream<BusinessProfile> streamBusiness() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('business')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return BusinessProfile.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};

          final List<dynamic> rawBranches = source['officeBranches'] ?? [];
          final officeBranches =
              rawBranches.isNotEmpty
                  ? rawBranches
                      .map(
                        (b) => OfficeBranch.fromMap(
                          b['id'] ?? '',
                          Map<dynamic, dynamic>.from(b),
                        ),
                      )
                      .toList()
                  : BusinessProfile.defaultVal().officeBranches;

          final rawSocial = source['socialLinks'] ?? {};
          final socialLinks = Map<String, String>.from(
            rawSocial.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );

          final List<dynamic> rawContacts = source['contactNumbers'] ?? [];
          List<ContactNumberEntity> contactNumbers;
          if (rawContacts.isNotEmpty) {
            contactNumbers = rawContacts
                .map((c) => ContactNumberModel.fromJson(Map<String, dynamic>.from(c)))
                .map(ContactNumberMapper.toEntity)
                .toList();
          } else {
            final oldPhone = source['phone']?.toString();
            if (oldPhone != null && oldPhone.isNotEmpty) {
              contactNumbers = [
                ContactNumberEntity(
                  id: '1',
                  label: 'Primary',
                  number: oldPhone,
                  isPrimary: true,
                  isActive: true,
                  displayOrder: 1,
                ),
              ];
            } else {
              contactNumbers = [];
            }
          }

          return BusinessProfile(
            name: source['name'] ?? 'Om Events',
            companyName: source['companyName'] ?? 'Om Events & Decorators',
            logo: source['logo'] ?? '',
            whiteLogo: source['whiteLogo'] ?? '',
            favicon: source['favicon'] ?? '',
            gst: source['gst'] ?? '',
            pan: source['pan'] ?? '',
            ownerName: source['ownerName'] ?? '',
            contactNumbers: contactNumbers,
            email: source['email'] ?? '',
            whatsapp: source['whatsapp'] ?? '',
            officeBranches: officeBranches,
            workingHours: source['workingHours'] ?? '9:00 AM - 8:00 PM',
            socialLinks:
                socialLinks.isNotEmpty
                    ? socialLinks
                    : BusinessProfile.defaultVal().socialLinks,
          );
        });
  }

  @override
  Stream<HomepageSettings> streamHomepage() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('homepage')
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

  @override
  Stream<ThemeSettings> streamTheme() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('theme')
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

  @override
  Stream<SEOSettings> streamSEO() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('seo')
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

  @override
  Stream<FooterSettings> streamFooter() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('footer')
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

  @override
  Stream<ContactSettings> streamContact() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('contact')
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

  @override
  Stream<PricingSettings> streamPricing() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('pricing')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return PricingSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return PricingSettings(
            gst: (source['gst'] ?? 18.0).toDouble(),
            deliveryCharge: (source['deliveryCharge'] ?? 500.0).toDouble(),
            travelCharge: (source['travelCharge'] ?? 0.0).toDouble(),
            discount: (source['discount'] ?? 0.0).toDouble(),
            coupons: source['coupons'] ?? [],
            advanceAmount: (source['advanceAmount'] ?? 0.0).toDouble(),
          );
        });
  }

  @override
  Stream<BookingSettings> streamBooking() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('booking')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return BookingSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return BookingSettings(
            bookingRules: source['bookingRules'] ?? [],
            advanceDays: source['advanceDays'] ?? 7,
            workingHours: source['workingHours'] ?? '9:00 AM - 8:00 PM',
            cancellationRules: source['cancellationRules'] ?? [],
            refundRules: source['refundRules'] ?? [],
          );
        });
  }

  @override
  Stream<NotificationsSettings> streamNotifications() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('notifications')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return NotificationsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return NotificationsSettings(
            pushTemplates: Map<String, dynamic>.from(
              source['pushTemplates'] ?? {},
            ),
            smsTemplates: Map<String, dynamic>.from(
              source['smsTemplates'] ?? {},
            ),
            emailTemplates: Map<String, dynamic>.from(
              source['emailTemplates'] ?? {},
            ),
          );
        });
  }

  @override
  Stream<PDFSettings> streamPDF() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('pdf')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return PDFSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return PDFSettings(
            invoiceHeader: source['invoiceHeader'] ?? '',
            invoiceFooter: source['invoiceFooter'] ?? '',
            terms: source['terms'] ?? '',
            bankDetails: Map<String, dynamic>.from(source['bankDetails'] ?? {}),
            upi: source['upi'] ?? '',
            signature: source['signature'] ?? '',
          );
        });
  }

  @override
  Stream<StatisticsSettings> streamStatistics() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('statistics')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return StatisticsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return StatisticsSettings(
            completedEvents: source['completedEvents'] ?? 0,
            happyClients: source['happyClients'] ?? 0,
            cities: source['cities'] ?? 0,
            years: source['years'] ?? 0,
          );
        });
  }

  @override
  Stream<FeatureFlagsSettings> streamFeatureFlags() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('feature_flags')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return FeatureFlagsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return FeatureFlagsSettings(
            enableReviews: source['enableReviews'] ?? true,
            enableGallery: source['enableGallery'] ?? true,
            enableBooking: source['enableBooking'] ?? true,
            enablePayments: source['enablePayments'] ?? false,
            enableCart: source['enableCart'] ?? true,
            enableQuotes: source['enableQuotes'] ?? true,
            enableAnalytics: source['enableAnalytics'] ?? false,
          );
        });
  }

  @override
  Stream<MaintenanceSettings> streamMaintenance() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('maintenance')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return MaintenanceSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return MaintenanceSettings(
            maintenanceMode: source['maintenanceMode'] ?? false,
            message: source['message'] ?? '',
            eta: source['eta'] ?? '',
          );
        });
  }

  @override
  Stream<AppSettings> streamApp() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('app')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return AppSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return AppSettings(
            version: source['version'] ?? '1.0.0',
            forceUpdate: source['forceUpdate'] ?? false,
            buildNumber: source['buildNumber'] ?? 1,
          );
        });
  }

  // Implementation of 16 Additional Streams
  @override
  Stream<AboutSettings> streamAbout() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('about')
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

  @override
  Stream<EmailTemplatesSettings> streamEmailTemplates() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('email_templates')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return EmailTemplatesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return EmailTemplatesSettings(templates: source['templates'] ?? {});
        });
  }

  @override
  Stream<SmsTemplatesSettings> streamSmsTemplates() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('sms_templates')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return SmsTemplatesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return SmsTemplatesSettings(templates: source['templates'] ?? {});
        });
  }

  @override
  Stream<InvoiceSettings> streamInvoice() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('invoice')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return InvoiceSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return InvoiceSettings(
            taxNumber: source['taxNumber'] ?? '',
            invoiceNote: source['invoiceNote'] ?? '',
          );
        });
  }

  @override
  Stream<AnalyticsSettings> streamAnalytics() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('analytics')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return AnalyticsSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return AnalyticsSettings(
            measurementId: source['measurementId'] ?? '',
            enableTracking: source['enableTracking'] ?? false,
          );
        });
  }

  @override
  Stream<DashboardSettings> streamDashboard() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('dashboard')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return DashboardSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return DashboardSettings(
            welcomeMessage: source['welcomeMessage'] ?? 'Welcome back, Admin',
            activeWidgets: source['activeWidgets'] ?? [],
          );
        });
  }

  @override
  Stream<WorkingHoursSettings> streamWorkingHours() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('working_hours')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return WorkingHoursSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return WorkingHoursSettings(
            weekdayHours: source['weekdayHours'] ?? [],
            holidays: source['holidays'] ?? [],
          );
        });
  }

  @override
  Stream<PoliciesSettings> streamPolicies() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('policies')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return PoliciesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return PoliciesSettings(
            privacyPolicy: source['privacyPolicy'] ?? '',
            termsOfService: source['termsOfService'] ?? '',
            refundPolicy: source['refundPolicy'] ?? '',
          );
        });
  }

  @override
  Stream<ValidationSettings> streamValidation() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('validation')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ValidationSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return ValidationSettings(
            validationRules: source['validationRules'] ?? {},
          );
        });
  }

  @override
  Stream<MessagesSettings> streamMessages() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('messages')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return MessagesSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return MessagesSettings(
            customMessages: source['customMessages'] ?? {},
          );
        });
  }

  @override
  Stream<HomeSectionsSettings> streamHomeSections() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('home_sections')
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

  @override
  Stream<CtaSettings> streamCta() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('cta')
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

  @override
  Stream<GallerySettings> streamGallerySettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('gallery_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return GallerySettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return GallerySettings(
            enableGrid: source['enableGrid'] ?? true,
            columns: source['columns'] ?? 3,
          );
        });
  }

  @override
  Stream<VideoSettings> streamVideoSettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('video_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return VideoSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return VideoSettings(videosList: source['videosList'] ?? []);
        });
  }

  @override
  Stream<ReviewSettings> streamReviewSettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('review_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return ReviewSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return ReviewSettings(
            enableSorting: source['enableSorting'] ?? true,
            minimumStars: (source['minimumStars'] ?? 4.0).toDouble(),
          );
        });
  }

  @override
  Stream<FaqSettings> streamFaqSettings() {
    return _firestore
        .collection(AppCollections.settings)
        .doc('faq_settings')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return FaqSettings.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};
          return FaqSettings(
            title: source['title'] ?? 'FAQ',
            enableAccordion: source['enableAccordion'] ?? true,
          );
        });
  }

  // Save Operations
  @override
  Future<void> saveBusiness(BusinessProfile profile) async {
    await _saveToDraft('business', {
      'name': profile.name,
      'companyName': profile.companyName,
      'logo': profile.logo,
      'whiteLogo': profile.whiteLogo,
      'favicon': profile.favicon,
      'gst': profile.gst,
      'pan': profile.pan,
      'ownerName': profile.ownerName,
      'contactNumbers': profile.contactNumbers
          .map(ContactNumberMapper.toModel)
          .map((m) => m.toJson())
          .toList(),
      'email': profile.email,
      'whatsapp': profile.whatsapp,
      'officeBranches': profile.officeBranches.map((b) => b.toMap()).toList(),
      'workingHours': profile.workingHours,
      'socialLinks': profile.socialLinks,
    });
  }

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<void> savePricing(PricingSettings pricing) async {
    await _saveToDraft('pricing', {
      'gst': pricing.gst,
      'deliveryCharge': pricing.deliveryCharge,
      'travelCharge': pricing.travelCharge,
      'discount': pricing.discount,
      'coupons': pricing.coupons,
      'advanceAmount': pricing.advanceAmount,
    });
  }

  @override
  Future<void> saveBooking(BookingSettings booking) async {
    await _saveToDraft('booking', {
      'bookingRules': booking.bookingRules,
      'advanceDays': booking.advanceDays,
      'workingHours': booking.workingHours,
      'cancellationRules': booking.cancellationRules,
      'refundRules': booking.refundRules,
    });
  }

  @override
  Future<void> saveNotifications(NotificationsSettings notifications) async {
    await _saveToDraft('notifications', {
      'pushTemplates': notifications.pushTemplates,
      'smsTemplates': notifications.smsTemplates,
      'emailTemplates': notifications.emailTemplates,
    });
  }

  @override
  Future<void> savePDF(PDFSettings pdf) async {
    await _saveToDraft('pdf', {
      'invoiceHeader': pdf.invoiceHeader,
      'invoiceFooter': pdf.invoiceFooter,
      'terms': pdf.terms,
      'bankDetails': pdf.bankDetails,
      'upi': pdf.upi,
      'signature': pdf.signature,
    });
  }

  @override
  Future<void> saveStatistics(StatisticsSettings stats) async {
    await _saveToDraft('statistics', {
      'completedEvents': stats.completedEvents,
      'happyClients': stats.happyClients,
      'cities': stats.cities,
      'years': stats.years,
    });
  }

  @override
  Future<void> saveFeatureFlags(FeatureFlagsSettings flags) async {
    await _saveToDraft('feature_flags', {
      'enableReviews': flags.enableReviews,
      'enableGallery': flags.enableGallery,
      'enableBooking': flags.enableBooking,
      'enablePayments': flags.enablePayments,
      'enableCart': flags.enableCart,
      'enableQuotes': flags.enableQuotes,
      'enableAnalytics': flags.enableAnalytics,
    });
  }

  @override
  Future<void> saveMaintenance(MaintenanceSettings maintenance) async {
    await _saveToDraft('maintenance', {
      'maintenanceMode': maintenance.maintenanceMode,
      'message': maintenance.message,
      'eta': maintenance.eta,
    });
  }

  @override
  Future<void> saveApp(AppSettings app) async {
    await _saveToDraft('app', {
      'version': app.version,
      'forceUpdate': app.forceUpdate,
      'buildNumber': app.buildNumber,
    });
  }

  // Implement 16 Additional Saves
  @override
  Future<void> saveAbout(AboutSettings about) async {
    await _saveToDraft('about', {
      'description': about.description,
      'mission': about.mission,
      'vision': about.vision,
      'story': about.story,
    });
  }

  @override
  Future<void> saveEmailTemplates(EmailTemplatesSettings templates) async {
    await _saveToDraft('email_templates', {'templates': templates.templates});
  }

  @override
  Future<void> saveSmsTemplates(SmsTemplatesSettings templates) async {
    await _saveToDraft('sms_templates', {'templates': templates.templates});
  }

  @override
  Future<void> saveInvoice(InvoiceSettings invoice) async {
    await _saveToDraft('invoice', {
      'taxNumber': invoice.taxNumber,
      'invoiceNote': invoice.invoiceNote,
    });
  }

  @override
  Future<void> saveAnalytics(AnalyticsSettings analytics) async {
    await _saveToDraft('analytics', {
      'measurementId': analytics.measurementId,
      'enableTracking': analytics.enableTracking,
    });
  }

  @override
  Future<void> saveDashboard(DashboardSettings dashboard) async {
    await _saveToDraft('dashboard', {
      'welcomeMessage': dashboard.welcomeMessage,
      'activeWidgets': dashboard.activeWidgets,
    });
  }

  @override
  Future<void> saveWorkingHours(WorkingHoursSettings hours) async {
    await _saveToDraft('working_hours', {
      'weekdayHours': hours.weekdayHours,
      'holidays': hours.holidays,
    });
  }

  @override
  Future<void> savePolicies(PoliciesSettings policies) async {
    await _saveToDraft('policies', {
      'privacyPolicy': policies.privacyPolicy,
      'termsOfService': policies.termsOfService,
      'refundPolicy': policies.refundPolicy,
    });
  }

  @override
  Future<void> saveValidation(ValidationSettings validation) async {
    await _saveToDraft('validation', {
      'validationRules': validation.validationRules,
    });
  }

  @override
  Future<void> saveMessages(MessagesSettings messages) async {
    await _saveToDraft('messages', {'customMessages': messages.customMessages});
  }

  @override
  Future<void> saveHomeSections(HomeSectionsSettings sections) async {
    await _saveToDraft('home_sections', {
      'activeSections': sections.activeSections,
    });
  }

  @override
  Future<void> saveCta(CtaSettings cta) async {
    await _saveToDraft('cta', {
      'buttonText': cta.buttonText,
      'buttonUrl': cta.buttonUrl,
    });
  }

  @override
  Future<void> saveGallerySettings(GallerySettings settings) async {
    await _saveToDraft('gallery_settings', {
      'enableGrid': settings.enableGrid,
      'columns': settings.columns,
    });
  }

  @override
  Future<void> saveVideoSettings(VideoSettings settings) async {
    await _saveToDraft('video_settings', {'videosList': settings.videosList});
  }

  @override
  Future<void> saveReviewSettings(ReviewSettings settings) async {
    await _saveToDraft('review_settings', {
      'enableSorting': settings.enableSorting,
      'minimumStars': settings.minimumStars,
    });
  }

  @override
  Future<void> saveFaqSettings(FaqSettings settings) async {
    await _saveToDraft('faq_settings', {
      'title': settings.title,
      'enableAccordion': settings.enableAccordion,
    });
  }

  Future<void> _saveToDraft(
    String docId,
    Map<String, dynamic> draftData,
  ) async {
    final docRef = _firestore.collection(AppCollections.settings).doc(docId);
    final snap = await docRef.get();
    final currentMeta =
        snap.exists
            ? (snap.data()?['meta'] as Map<String, dynamic>? ?? {})
            : {};

    await docRef.set({
      'draft': draftData,
      'published': draftData,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    }, SetOptions(merge: true));
  }

  // Publish / Rollback
  @override
  Future<void> publishSettings(String docId) async {
    final docRef = _firestore.collection(AppCollections.settings).doc(docId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final draft = data['draft'];
    final meta = data['meta'] as Map<String, dynamic>? ?? {};

    final currentVersion = (meta['version'] ?? 1) as int;
    final newVersion = currentVersion + 1;
    final now = DateTime.now().toIso8601String();

    await docRef.collection('history').doc(currentVersion.toString()).set({
      'published': data['published'] ?? draft,
      'meta': meta,
    });

    await docRef.update({
      'published': draft,
      'meta': {
        ...meta,
        'version': newVersion,
        'updatedAt': now,
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    });

    await _firestore.collection(AppCollections.activityLogs).add({
      'who_updated': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      'action': 'Publish',
      'what_changed': docId,
      'old_value': 'v$currentVersion',
      'new_value': 'v$newVersion',
      'date': now,
      'device': 'CMS Web Console',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVersionHistory(String docId) async {
    final snap =
        await _firestore
            .collection(AppCollections.settings)
            .doc(docId)
            .collection('history')
            .orderBy('meta.version', descending: true)
            .get();
    return snap.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<void> rollbackToVersion(String docId, int version) async {
    final docRef = _firestore.collection(AppCollections.settings).doc(docId);
    final historyDoc =
        await docRef.collection('history').doc(version.toString()).get();
    if (!historyDoc.exists) return;

    final historyData = historyDoc.data()!;
    final publishedVal = historyData['published'];
    final meta = historyData['meta'] as Map<String, dynamic>? ?? {};

    final now = DateTime.now().toIso8601String();

    await docRef.set({
      'draft': publishedVal,
      'published': publishedVal,
      'meta': {
        ...meta,
        'updatedAt': now,
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    });
  }
}
