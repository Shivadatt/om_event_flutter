part of '../business_details_model.dart';

class GeneralProfileModel {
  static GeneralProfileEntity fromJson(Map<String, dynamic> json) {
    return GeneralProfileEntity(
      businessName: json['businessName'] ?? '',
      companyName: json['companyName'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerDesignation: json['ownerDesignation'] ?? '',
      logo: json['logo'] ?? '',
      coverImage: json['coverImage'] ?? '',
      favicon: json['favicon'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      establishedYear: json['establishedYear'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(GeneralProfileEntity entity) {
    return {
      'businessName': entity.businessName,
      'companyName': entity.companyName,
      'tagline': entity.tagline,
      'description': entity.description,
      'ownerName': entity.ownerName,
      'ownerDesignation': entity.ownerDesignation,
      'logo': entity.logo,
      'coverImage': entity.coverImage,
      'favicon': entity.favicon,
      'registrationNumber': entity.registrationNumber,
      'gstNumber': entity.gstNumber,
      'panNumber': entity.panNumber,
      'licenseNumber': entity.licenseNumber,
      'establishedYear': entity.establishedYear,
    };
  }
}

class ContactItemModel {
  static ContactItemEntity fromJson(Map<String, dynamic> json) {
    return ContactItemEntity(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      isActive: json['isActive'] ?? true,
      displayOrder: json['displayOrder'] ?? 1,
    );
  }

  static Map<String, dynamic> toJson(ContactItemEntity entity) {
    return {
      'id': entity.id,
      'label': entity.label,
      'value': entity.value,
      'isPrimary': entity.isPrimary,
      'isActive': entity.isActive,
      'displayOrder': entity.displayOrder,
    };
  }
}

class ContactDetailsModel {
  static ContactDetailsEntity fromJson(Map<String, dynamic> json) {
    return ContactDetailsEntity(
      phones: (json['phones'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      whatsapps: (json['whatsapps'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      emails: (json['emails'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      customerCares: (json['customerCares'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      emergencyContacts: (json['emergencyContacts'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  static Map<String, dynamic> toJson(ContactDetailsEntity entity) {
    return {
      'phones': entity.phones.map(ContactItemModel.toJson).toList(),
      'whatsapps': entity.whatsapps.map(ContactItemModel.toJson).toList(),
      'emails': entity.emails.map(ContactItemModel.toJson).toList(),
      'customerCares': entity.customerCares.map(ContactItemModel.toJson).toList(),
      'emergencyContacts': entity.emergencyContacts.map(ContactItemModel.toJson).toList(),
    };
  }
}

class SocialMediaModel {
  static SocialMediaEntity fromJson(Map<String, dynamic> json) {
    return SocialMediaEntity(
      instagramKadi: json['instagramKadi'] ?? '',
      instagramThangadh: json['instagramThangadh'] ?? '',
      website: json['website'] ?? '',
      googleBusinessProfile: json['googleBusinessProfile'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(SocialMediaEntity entity) {
    return {
      'instagramKadi': entity.instagramKadi,
      'instagramThangadh': entity.instagramThangadh,
      'website': entity.website,
      'googleBusinessProfile': entity.googleBusinessProfile,
    };
  }
}

class WorkingHoursModel {
  static WorkingHoursEntity fromJson(Map<String, dynamic> json) {
    return WorkingHoursEntity(
      monday: json['monday'] ?? '',
      tuesday: json['tuesday'] ?? '',
      wednesday: json['wednesday'] ?? '',
      thursday: json['thursday'] ?? '',
      friday: json['friday'] ?? '',
      saturday: json['saturday'] ?? '',
      sunday: json['sunday'] ?? '',
      holidayNotes: json['holidayNotes'] ?? '',
      emergencyHours: json['emergencyHours'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(WorkingHoursEntity entity) {
    return {
      'monday': entity.monday,
      'tuesday': entity.tuesday,
      'wednesday': entity.wednesday,
      'thursday': entity.thursday,
      'friday': entity.friday,
      'saturday': entity.saturday,
      'sunday': entity.sunday,
      'holidayNotes': entity.holidayNotes,
      'emergencyHours': entity.emergencyHours,
    };
  }
}

class BankDetailsModel {
  static BankDetailsEntity fromJson(Map<String, dynamic> json) {
    return BankDetailsEntity(
      bankName: json['bankName'] ?? '',
      accountHolder: json['accountHolder'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      ifsc: json['ifsc'] ?? '',
      upiId: json['upiId'] ?? '',
      qrCode: json['qrCode'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(BankDetailsEntity entity) {
    return {
      'bankName': entity.bankName,
      'accountHolder': entity.accountHolder,
      'accountNumber': entity.accountNumber,
      'ifsc': entity.ifsc,
      'upiId': entity.upiId,
      'qrCode': entity.qrCode,
    };
  }
}

class LegalDetailsModel {
  static LegalDetailsEntity fromJson(Map<String, dynamic> json) {
    return LegalDetailsEntity(
      gstNumber: json['gstNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      msmeNumber: json['msmeNumber'] ?? '',
      termsAndConditions: json['termsAndConditions'] ?? '',
      privacyPolicy: json['privacyPolicy'] ?? '',
      refundPolicy: json['refundPolicy'] ?? '',
      cancellationPolicy: json['cancellationPolicy'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(LegalDetailsEntity entity) {
    return {
      'gstNumber': entity.gstNumber,
      'panNumber': entity.panNumber,
      'msmeNumber': entity.msmeNumber,
      'termsAndConditions': entity.termsAndConditions,
      'privacyPolicy': entity.privacyPolicy,
      'refundPolicy': entity.refundPolicy,
      'cancellationPolicy': entity.cancellationPolicy,
    };
  }
}

class SEOModel {
  static SEOEntity fromJson(Map<String, dynamic> json) {
    return SEOEntity(
      metaTitle: json['metaTitle'] ?? '',
      metaDescription: json['metaDescription'] ?? '',
      keywords: json['keywords'] ?? '',
      canonicalUrl: json['canonicalUrl'] ?? '',
      ogImage: json['ogImage'] ?? '',
      twitterCardImage: json['twitterCardImage'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(SEOEntity entity) {
    return {
      'metaTitle': entity.metaTitle,
      'metaDescription': entity.metaDescription,
      'keywords': entity.keywords,
      'canonicalUrl': entity.canonicalUrl,
      'ogImage': entity.ogImage,
      'twitterCardImage': entity.twitterCardImage,
    };
  }
}

class MapsModel {
  static MapsEntity fromJson(Map<String, dynamic> json) {
    return MapsEntity(
      embedCode: json['embedCode'] ?? '',
      mapUrl: json['mapUrl'] ?? '',
      coordinates: json['coordinates'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(MapsEntity entity) {
    return {
      'embedCode': entity.embedCode,
      'mapUrl': entity.mapUrl,
      'coordinates': entity.coordinates,
    };
  }
}
