import '../../domain/entities/business_details_entity.dart';

part 'business_details/branch_model.dart';
part 'business_details/address_model.dart';
part 'business_details/bank_legal_model.dart';
part 'business_details/business_details_legacy.dart';

class BusinessDetailsModel {
  static BusinessDetailsEntity fromJson(Map<String, dynamic> json) {
    return BusinessDetailsFromJson.fromJson(json);
  }

  static Map<String, dynamic> toJson(BusinessDetailsEntity entity) {
    final primaryEmail = entity.contacts.emails.firstWhere(
      (e) => e.isPrimary && e.isActive,
      orElse: () => entity.contacts.emails.firstWhere(
        (e) => e.isActive,
        orElse: () => const ContactItemEntity(
          id: '',
          label: '',
          value: 'omeventsanddecorators@gmail.com',
          isPrimary: false,
          isActive: false,
          displayOrder: 0,
        ),
      ),
    ).value;

    final primaryWa = entity.contacts.whatsapps.firstWhere(
      (w) => w.isPrimary && w.isActive,
      orElse: () => entity.contacts.whatsapps.firstWhere(
        (w) => w.isActive,
        orElse: () => const ContactItemEntity(
          id: '',
          label: '',
          value: '9512149944',
          isPrimary: false,
          isActive: false,
          displayOrder: 0,
        ),
      ),
    ).value;

    // Convert branches to old officeBranches format
    final officeBranches = entity.branches.map((b) {
      return {
        'id': b.id,
        'name': b.branchName,
        'address': b.fullAddress,
        'city': _getCityFromAddress(b.fullAddress),
        'state': 'Gujarat',
        'country': 'India',
        'pincode': '',
        'phone': b.phoneNumber,
        'email': b.email,
        'googleMaps': b.googleMapUrl,
        'latitude': b.latitude,
        'longitude': b.longitude,
        'workingHours': b.workingHours,
        'openingDays': b.openingDays,
        'isPrimary': b.displayOrder == 1,
        'isActive': b.isActive,
        'instagram': b.instagram,
      };
    }).toList();

    // Convert phones to old contactNumbers format
    final contactNumbers = entity.contacts.phones.map((p) {
      return {
        'id': p.id,
        'label': p.label,
        'number': p.value,
        'isPrimary': p.isPrimary,
        'isActive': p.isActive,
        'displayOrder': p.displayOrder,
      };
    }).toList();

    return {
      // Unified format
      'general': GeneralProfileModel.toJson(entity.general),
      'contacts': ContactDetailsModel.toJson(entity.contacts),
      'branches': entity.branches.map(BranchModel.toJson).toList(),
      'addresses': entity.addresses.map(AddressModel.toJson).toList(),
      'social': SocialMediaModel.toJson(entity.social),
      'workingHours': WorkingHoursModel.toJson(entity.workingHours),
      'bank': BankDetailsModel.toJson(entity.bank),
      'legal': LegalDetailsModel.toJson(entity.legal),
      'seo': SEOModel.toJson(entity.seo),
      'maps': MapsModel.toJson(entity.maps),

      // Legacy format (dual write for complete backward compatibility)
      'name': entity.general.businessName,
      'companyName': entity.general.companyName,
      'logo': entity.general.logo,
      'whiteLogo': entity.general.coverImage,
      'favicon': entity.general.favicon,
      'gst': entity.legal.gstNumber,
      'pan': entity.legal.panNumber,
      'ownerName': entity.general.ownerName,
      'email': primaryEmail,
      'whatsapp': primaryWa,
      'officeBranches': officeBranches,
      'contactNumbers': contactNumbers,
      'socialLinks': {
        'instagram_kadi': entity.social.instagramKadi,
        'instagram_thangadh': entity.social.instagramThangadh,
        'website': entity.social.website,
        'google_business_profile': entity.social.googleBusinessProfile,
      },
    };
  }

  static String _getCityFromAddress(String fullAddress) {
    final parts = fullAddress.split(',');
    if (parts.length >= 2) {
      return parts[parts.length - 2].trim();
    }
    return 'Office';
  }
}
