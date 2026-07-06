import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/settings_entities.dart';
import '../../domain/entities/contact_number_entity.dart';
import '../models/contact_number_model.dart';
import '../mappers/contact_number_mapper.dart';
import '../../domain/repositories/settings_repository.dart';

import '../../core/services/realtime_manager.dart';

class SupabaseSettingsRepository implements SettingsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  static Stream<List<Map<String, dynamic>>>? _cachedSharedStream;

  static Stream<List<Map<String, dynamic>>> getSharedStream(SupabaseClient client) {
    if (_cachedSharedStream != null) {
      print('Realtime channel reused');
      return _cachedSharedStream!;
    }

    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    StreamSubscription? sub;

    void startListening() {
      if (sub != null) return;
      print('Realtime channel created');
      sub = client
          .from('settings')
          .stream(primaryKey: ['id'])
          .listen(
            (data) {
              print('Subscribed to settings');
              controller.add(data);
            },
            onError: (err) {
              print('Subscription failed: $err');
              controller.addError(err);
            },
            onDone: () => controller.close(),
          );
    }

    if (RealtimeManager.instance.isReady) {
      startListening();
    } else {
      print('Realtime skipped: Auth headers not ready');
      RealtimeManager.instance.isReadyNotifier.addListener(() {
        if (RealtimeManager.instance.isReady) {
          startListening();
        }
      });
    }

    _cachedSharedStream = controller.stream;
    return _cachedSharedStream!;
  }

  Stream<Map<String, dynamic>> _streamDoc(String docId) {
    return getSharedStream(_client).map((rows) {
      final match = rows.where((row) => row['id'] == docId);
      return match.isNotEmpty ? match.first : {};
    });
  }

  // Streams
  @override
  Stream<BusinessProfile> streamBusiness() {
    return _streamDoc('business')
        .map((data) {
          if (data.isEmpty) return BusinessProfile.defaultVal();
          // data is already Map
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
    return _streamDoc('homepage')
        .map((data) {
          if (data.isEmpty) return HomepageSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('theme')
        .map((data) {
          if (data.isEmpty) return ThemeSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('seo')
        .map((data) {
          if (data.isEmpty) return SEOSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('footer')
        .map((data) {
          if (data.isEmpty) return FooterSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('contact')
        .map((data) {
          if (data.isEmpty) return ContactSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('pricing')
        .map((data) {
          if (data.isEmpty) return PricingSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('booking')
        .map((data) {
          if (data.isEmpty) return BookingSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('notifications')
        .map((data) {
          if (data.isEmpty) return NotificationsSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('pdf')
        .map((data) {
          if (data.isEmpty) return PDFSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('statistics')
        .map((data) {
          if (data.isEmpty) return StatisticsSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('feature_flags')
        .map((data) {
          if (data.isEmpty) return FeatureFlagsSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('maintenance')
        .map((data) {
          if (data.isEmpty) return MaintenanceSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('app')
        .map((data) {
          if (data.isEmpty) return AppSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('about')
        .map((data) {
          if (data.isEmpty) return AboutSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('email_templates')
        .map((data) {
          if (data.isEmpty) return EmailTemplatesSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return EmailTemplatesSettings(templates: source['templates'] ?? {});
        });
  }

  @override
  Stream<SmsTemplatesSettings> streamSmsTemplates() {
    return _streamDoc('sms_templates')
        .map((data) {
          if (data.isEmpty) return SmsTemplatesSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return SmsTemplatesSettings(templates: source['templates'] ?? {});
        });
  }

  @override
  Stream<InvoiceSettings> streamInvoice() {
    return _streamDoc('invoice')
        .map((data) {
          if (data.isEmpty) return InvoiceSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return InvoiceSettings(
            taxNumber: source['taxNumber'] ?? '',
            invoiceNote: source['invoiceNote'] ?? '',
          );
        });
  }

  @override
  Stream<AnalyticsSettings> streamAnalytics() {
    return _streamDoc('analytics')
        .map((data) {
          if (data.isEmpty) return AnalyticsSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return AnalyticsSettings(
            measurementId: source['measurementId'] ?? '',
            enableTracking: source['enableTracking'] ?? false,
          );
        });
  }

  @override
  Stream<DashboardSettings> streamDashboard() {
    return _streamDoc('dashboard')
        .map((data) {
          if (data.isEmpty) return DashboardSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return DashboardSettings(
            welcomeMessage: source['welcomeMessage'] ?? 'Welcome back, Admin',
            activeWidgets: source['activeWidgets'] ?? [],
          );
        });
  }

  @override
  Stream<WorkingHoursSettings> streamWorkingHours() {
    return _streamDoc('working_hours')
        .map((data) {
          if (data.isEmpty) return WorkingHoursSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return WorkingHoursSettings(
            weekdayHours: source['weekdayHours'] ?? [],
            holidays: source['holidays'] ?? [],
          );
        });
  }

  @override
  Stream<PoliciesSettings> streamPolicies() {
    return _streamDoc('policies')
        .map((data) {
          if (data.isEmpty) return PoliciesSettings.defaultVal();
          // data is already Map
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
    return _streamDoc('validation')
        .map((data) {
          if (data.isEmpty) return ValidationSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return ValidationSettings(
            validationRules: source['validationRules'] ?? {},
          );
        });
  }

  @override
  Stream<MessagesSettings> streamMessages() {
    return _streamDoc('messages')
        .map((data) {
          if (data.isEmpty) return MessagesSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return MessagesSettings(
            customMessages: source['customMessages'] ?? {},
          );
        });
  }

  @override
  Stream<HomeSectionsSettings> streamHomeSections() {
    return _streamDoc('home_sections')
        .map((data) {
          if (data.isEmpty) return HomeSectionsSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return HomeSectionsSettings(
            activeSections: source['activeSections'] ?? [],
          );
        });
  }

  @override
  Stream<CtaSettings> streamCta() {
    return _streamDoc('cta')
        .map((data) {
          if (data.isEmpty) return CtaSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return CtaSettings(
            buttonText: source['buttonText'] ?? 'Get Started',
            buttonUrl: source['buttonUrl'] ?? '',
          );
        });
  }

  @override
  Stream<GallerySettings> streamGallerySettings() {
    return _streamDoc('gallery_settings')
        .map((data) {
          if (data.isEmpty) return GallerySettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return GallerySettings(
            enableGrid: source['enableGrid'] ?? true,
            columns: source['columns'] ?? 3,
          );
        });
  }

  @override
  Stream<VideoSettings> streamVideoSettings() {
    return _streamDoc('video_settings')
        .map((data) {
          if (data.isEmpty) return VideoSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return VideoSettings(videosList: source['videosList'] ?? []);
        });
  }

  @override
  Stream<ReviewSettings> streamReviewSettings() {
    return _streamDoc('review_settings')
        .map((data) {
          if (data.isEmpty) return ReviewSettings.defaultVal();
          // data is already Map
          final source = data['published'] ?? data['draft'] ?? {};
          return ReviewSettings(
            enableSorting: source['enableSorting'] ?? true,
            minimumStars: (source['minimumStars'] ?? 4.0).toDouble(),
          );
        });
  }

  @override
  Stream<FaqSettings> streamFaqSettings() {
    return _streamDoc('faq_settings')
        .map((data) {
          if (data.isEmpty) return FaqSettings.defaultVal();
          // data is already Map
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
    final snap = await _client.from('settings').select('meta').eq('id', docId).maybeSingle();
    final currentMeta = snap != null ? (snap['meta'] as Map<String, dynamic>? ?? {}) : {};

    final payload = {
      'id': docId,
      'key': docId,
      'draft': draftData,
      'published': draftData,
      'meta': {
        'version': currentMeta['version'] ?? 1,
        'updated_at': DateTime.now().toIso8601String(),
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    };
    await _client.from('settings').upsert(payload);
  }

  // Publish / Rollback
  @override
  Future<void> publishSettings(String docId) async {
    final snap = await _client.from('settings').select().eq('id', docId).maybeSingle();
    if (snap == null) return;

    final draft = snap['draft'];
    final meta = snap['meta'] as Map<String, dynamic>? ?? {};

    final currentVersion = (meta['version'] ?? 1) as int;
    final newVersion = currentVersion + 1;
    final now = DateTime.now().toIso8601String();

    await _client.from('settings_history').insert({
      'setting_id': docId,
      'version': currentVersion,
      'published': snap['published'] ?? draft,
      'meta': meta,
    });

    await _client.from('settings').update({
      'published': draft,
      'meta': {
        ...meta,
        'version': newVersion,
        'updated_at': now,
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    }).eq('id', docId);

    await _client.from('activity_logs').insert({
      'user_id': FirebaseAuth.instance.currentUser?.uid,
      'action': 'Publish',
      'entity_type': 'settings',
      'entity_id': docId,
      'ip_address': 'CMS Web Console',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getVersionHistory(String docId) async {
    final response = await _client
        .from('settings_history')
        .select()
        .eq('setting_id', docId)
        .order('version', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> rollbackToVersion(String docId, int version) async {
    final historyDoc = await _client
        .from('settings_history')
        .select()
        .eq('setting_id', docId)
        .eq('version', version)
        .maybeSingle();
    if (historyDoc == null) return;

    final publishedVal = historyDoc['published'];
    final meta = historyDoc['meta'] as Map<String, dynamic>? ?? {};
    final now = DateTime.now().toIso8601String();

    await _client.from('settings').upsert({
      'id': docId,
      'key': docId,
      'draft': publishedVal,
      'published': publishedVal,
      'meta': {
        ...meta,
        'updated_at': now,
        'updated_by': FirebaseAuth.instance.currentUser?.email ?? 'admin',
      },
    });
  }
}
