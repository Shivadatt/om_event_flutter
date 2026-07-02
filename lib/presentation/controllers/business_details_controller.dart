import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/business_details_entity.dart';
import '../../domain/repositories/business_details_repository.dart';
import '../../core/services/business_details_service.dart';

class BusinessDetailsController extends GetxController {
  final BusinessDetailsRepository _repository = Get.find<BusinessDetailsRepository>();

  final isSaving = false.obs;

  // Tab Index
  final selectedIndex = 0.obs;

  // 1. General Profile Controllers
  final busNameCtrl = TextEditingController();
  final compNameCtrl = TextEditingController();
  final taglineCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final ownerNameCtrl = TextEditingController();
  final ownerDesignationCtrl = TextEditingController();
  final logoCtrl = TextEditingController();
  final coverImageCtrl = TextEditingController();
  final faviconCtrl = TextEditingController();
  final regNumCtrl = TextEditingController();
  final gstNumCtrl = TextEditingController();
  final panNumCtrl = TextEditingController();
  final licenseNumCtrl = TextEditingController();
  final estYearCtrl = TextEditingController();

  // 2. Contact Details Lists
  final phones = <ContactItemEntity>[].obs;
  final whatsapps = <ContactItemEntity>[].obs;
  final emails = <ContactItemEntity>[].obs;
  final customerCares = <ContactItemEntity>[].obs;
  final emergencyContacts = <ContactItemEntity>[].obs;

  // 3. Branches List
  final branches = <BranchEntity>[].obs;

  // 4. Addresses List
  final addresses = <AddressEntity>[].obs;

  // 5. Social Media Controllers
  final socialInstaKadiCtrl = TextEditingController();
  final socialInstaThangadhCtrl = TextEditingController();
  final socialWebCtrl = TextEditingController();
  final socialGoogleBusinessCtrl = TextEditingController();

  // 6. Working Hours Controllers
  final workMondayCtrl = TextEditingController();
  final workTuesdayCtrl = TextEditingController();
  final workWednesdayCtrl = TextEditingController();
  final workThursdayCtrl = TextEditingController();
  final workFridayCtrl = TextEditingController();
  final workSaturdayCtrl = TextEditingController();
  final workSundayCtrl = TextEditingController();
  final workHolidayNotesCtrl = TextEditingController();
  final workEmergencyHoursCtrl = TextEditingController();

  // 7. Bank Details Controllers
  final bankNameCtrl = TextEditingController();
  final bankHolderCtrl = TextEditingController();
  final bankAccCtrl = TextEditingController();
  final bankIfscCtrl = TextEditingController();
  final bankUpiCtrl = TextEditingController();
  final bankQrCodeCtrl = TextEditingController();

  // 8. Legal Details Controllers
  final legalGstCtrl = TextEditingController();
  final legalPanCtrl = TextEditingController();
  final legalMsmeCtrl = TextEditingController();
  final legalTermsCtrl = TextEditingController();
  final legalPrivacyCtrl = TextEditingController();
  final legalRefundCtrl = TextEditingController();
  final legalCancellationCtrl = TextEditingController();

  // 9. SEO Controllers
  final seoTitleCtrl = TextEditingController();
  final seoDescCtrl = TextEditingController();
  final seoKeywordsCtrl = TextEditingController();
  final seoCanonicalCtrl = TextEditingController();
  final seoOgImageCtrl = TextEditingController();
  final seoTwitterImageCtrl = TextEditingController();

  // 10. Maps Controllers
  final mapsEmbedCtrl = TextEditingController();
  final mapsUrlCtrl = TextEditingController();
  final mapsCoordsCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Populate form fields initially from cache/stream
    populateControllers(BusinessDetailsService.to.rxDetails.value);
    // Listen to streaming changes to keep form in sync if updated elsewhere
    once(BusinessDetailsService.to.rxDetails, (details) => populateControllers(details));
  }

  void populateControllers(BusinessDetailsEntity details) {
    busNameCtrl.text = details.general.businessName;
    compNameCtrl.text = details.general.companyName;
    taglineCtrl.text = details.general.tagline;
    descCtrl.text = details.general.description;
    ownerNameCtrl.text = details.general.ownerName;
    ownerDesignationCtrl.text = details.general.ownerDesignation;
    logoCtrl.text = details.general.logo;
    coverImageCtrl.text = details.general.coverImage;
    faviconCtrl.text = details.general.favicon;
    regNumCtrl.text = details.general.registrationNumber;
    gstNumCtrl.text = details.general.gstNumber;
    panNumCtrl.text = details.general.panNumber;
    licenseNumCtrl.text = details.general.licenseNumber;
    estYearCtrl.text = details.general.establishedYear;

    phones.value = List.from(details.contacts.phones)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    whatsapps.value = List.from(details.contacts.whatsapps)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    emails.value = List.from(details.contacts.emails)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    customerCares.value = List.from(details.contacts.customerCares)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    emergencyContacts.value = List.from(details.contacts.emergencyContacts)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    branches.value = List.from(details.branches)..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    addresses.value = List.from(details.addresses);

    socialInstaKadiCtrl.text = details.social.instagramKadi;
    socialInstaThangadhCtrl.text = details.social.instagramThangadh;
    socialWebCtrl.text = details.social.website;
    socialGoogleBusinessCtrl.text = details.social.googleBusinessProfile;

    workMondayCtrl.text = details.workingHours.monday;
    workTuesdayCtrl.text = details.workingHours.tuesday;
    workWednesdayCtrl.text = details.workingHours.wednesday;
    workThursdayCtrl.text = details.workingHours.thursday;
    workFridayCtrl.text = details.workingHours.friday;
    workSaturdayCtrl.text = details.workingHours.saturday;
    workSundayCtrl.text = details.workingHours.sunday;
    workHolidayNotesCtrl.text = details.workingHours.holidayNotes;
    workEmergencyHoursCtrl.text = details.workingHours.emergencyHours;

    bankNameCtrl.text = details.bank.bankName;
    bankHolderCtrl.text = details.bank.accountHolder;
    bankAccCtrl.text = details.bank.accountNumber;
    bankIfscCtrl.text = details.bank.ifsc;
    bankUpiCtrl.text = details.bank.upiId;
    bankQrCodeCtrl.text = details.bank.qrCode;

    legalGstCtrl.text = details.legal.gstNumber;
    legalPanCtrl.text = details.legal.panNumber;
    legalMsmeCtrl.text = details.legal.msmeNumber;
    legalTermsCtrl.text = details.legal.termsAndConditions;
    legalPrivacyCtrl.text = details.legal.privacyPolicy;
    legalRefundCtrl.text = details.legal.refundPolicy;
    legalCancellationCtrl.text = details.legal.cancellationPolicy;

    seoTitleCtrl.text = details.seo.metaTitle;
    seoDescCtrl.text = details.seo.metaDescription;
    seoKeywordsCtrl.text = details.seo.keywords;
    seoCanonicalCtrl.text = details.seo.canonicalUrl;
    seoOgImageCtrl.text = details.seo.ogImage;
    seoTwitterImageCtrl.text = details.seo.twitterCardImage;

    mapsEmbedCtrl.text = details.maps.embedCode;
    mapsUrlCtrl.text = details.maps.mapUrl;
    mapsCoordsCtrl.text = details.maps.coordinates;
  }

  Future<void> saveCentralizedDetails() async {
    // Validations
    if (busNameCtrl.text.isEmpty) {
      Get.snackbar("Validation Error", "Business Name is required", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (phones.isEmpty) {
      Get.snackbar("Validation Error", "At least one contact phone is required", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (!phones.any((p) => p.isPrimary && p.isActive)) {
      Get.snackbar("Validation Error", "One active phone must be marked as Primary", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isSaving.value = true;
      final updated = BusinessDetailsEntity(
        general: GeneralProfileEntity(
          businessName: busNameCtrl.text.trim(),
          companyName: compNameCtrl.text.trim(),
          tagline: taglineCtrl.text.trim(),
          description: descCtrl.text.trim(),
          ownerName: ownerNameCtrl.text.trim(),
          ownerDesignation: ownerDesignationCtrl.text.trim(),
          logo: logoCtrl.text.trim(),
          coverImage: coverImageCtrl.text.trim(),
          favicon: faviconCtrl.text.trim(),
          registrationNumber: regNumCtrl.text.trim(),
          gstNumber: gstNumCtrl.text.trim(),
          panNumber: panNumCtrl.text.trim(),
          licenseNumber: licenseNumCtrl.text.trim(),
          establishedYear: estYearCtrl.text.trim(),
        ),
        contacts: ContactDetailsEntity(
          phones: phones,
          whatsapps: whatsapps,
          emails: emails,
          customerCares: customerCares,
          emergencyContacts: emergencyContacts,
        ),
        branches: branches,
        addresses: addresses,
        social: SocialMediaEntity(
          instagramKadi: socialInstaKadiCtrl.text.trim(),
          instagramThangadh: socialInstaThangadhCtrl.text.trim(),
          website: socialWebCtrl.text.trim(),
          googleBusinessProfile: socialGoogleBusinessCtrl.text.trim(),
        ),
        workingHours: WorkingHoursEntity(
          monday: workMondayCtrl.text.trim(),
          tuesday: workTuesdayCtrl.text.trim(),
          wednesday: workWednesdayCtrl.text.trim(),
          thursday: workThursdayCtrl.text.trim(),
          friday: workFridayCtrl.text.trim(),
          saturday: workSaturdayCtrl.text.trim(),
          sunday: workSundayCtrl.text.trim(),
          holidayNotes: workHolidayNotesCtrl.text.trim(),
          emergencyHours: workEmergencyHoursCtrl.text.trim(),
        ),
        bank: BankDetailsEntity(
          bankName: bankNameCtrl.text.trim(),
          accountHolder: bankHolderCtrl.text.trim(),
          accountNumber: bankAccCtrl.text.trim(),
          ifsc: bankIfscCtrl.text.trim(),
          upiId: bankUpiCtrl.text.trim(),
          qrCode: bankQrCodeCtrl.text.trim(),
        ),
        legal: LegalDetailsEntity(
          gstNumber: legalGstCtrl.text.trim(),
          panNumber: legalPanCtrl.text.trim(),
          msmeNumber: legalMsmeCtrl.text.trim(),
          termsAndConditions: legalTermsCtrl.text.trim(),
          privacyPolicy: legalPrivacyCtrl.text.trim(),
          refundPolicy: legalRefundCtrl.text.trim(),
          cancellationPolicy: legalCancellationCtrl.text.trim(),
        ),
        seo: SEOEntity(
          metaTitle: seoTitleCtrl.text.trim(),
          metaDescription: seoDescCtrl.text.trim(),
          keywords: seoKeywordsCtrl.text.trim(),
          canonicalUrl: seoCanonicalCtrl.text.trim(),
          ogImage: seoOgImageCtrl.text.trim(),
          twitterCardImage: seoTwitterImageCtrl.text.trim(),
        ),
        maps: MapsEntity(
          embedCode: mapsEmbedCtrl.text.trim(),
          mapUrl: mapsUrlCtrl.text.trim(),
          coordinates: mapsCoordsCtrl.text.trim(),
        ),
      );

      await _repository.saveBusinessDetails(updated);
      Get.snackbar("CMS Success", "Centralized Business Details saved successfully!", backgroundColor: const Color(0xFF131D1A), colorText: const Color(0xFFC9A77E));
    } catch (e) {
      Get.snackbar("Save Error", "Failed to save: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    busNameCtrl.dispose();
    compNameCtrl.dispose();
    taglineCtrl.dispose();
    descCtrl.dispose();
    ownerNameCtrl.dispose();
    ownerDesignationCtrl.dispose();
    logoCtrl.dispose();
    coverImageCtrl.dispose();
    faviconCtrl.dispose();
    regNumCtrl.dispose();
    gstNumCtrl.dispose();
    panNumCtrl.dispose();
    licenseNumCtrl.dispose();
    estYearCtrl.dispose();
    socialInstaKadiCtrl.dispose();
    socialInstaThangadhCtrl.dispose();
    socialWebCtrl.dispose();
    socialGoogleBusinessCtrl.dispose();
    workMondayCtrl.dispose();
    workTuesdayCtrl.dispose();
    workWednesdayCtrl.dispose();
    workThursdayCtrl.dispose();
    workFridayCtrl.dispose();
    workSaturdayCtrl.dispose();
    workSundayCtrl.dispose();
    workHolidayNotesCtrl.dispose();
    workEmergencyHoursCtrl.dispose();
    bankNameCtrl.dispose();
    bankHolderCtrl.dispose();
    bankAccCtrl.dispose();
    bankIfscCtrl.dispose();
    bankUpiCtrl.dispose();
    bankQrCodeCtrl.dispose();
    legalGstCtrl.dispose();
    legalPanCtrl.dispose();
    legalMsmeCtrl.dispose();
    legalTermsCtrl.dispose();
    legalPrivacyCtrl.dispose();
    legalRefundCtrl.dispose();
    legalCancellationCtrl.dispose();
    seoTitleCtrl.dispose();
    seoDescCtrl.dispose();
    seoKeywordsCtrl.dispose();
    seoCanonicalCtrl.dispose();
    seoOgImageCtrl.dispose();
    seoTwitterImageCtrl.dispose();
    mapsEmbedCtrl.dispose();
    mapsUrlCtrl.dispose();
    mapsCoordsCtrl.dispose();
    super.onClose();
  }
}
