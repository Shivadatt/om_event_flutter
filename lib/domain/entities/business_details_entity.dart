class BusinessDetailsEntity {
  final GeneralProfileEntity general;
  final ContactDetailsEntity contacts;
  final List<BranchEntity> branches;
  final List<AddressEntity> addresses;
  final SocialMediaEntity social;
  final WorkingHoursEntity workingHours;
  final BankDetailsEntity bank;
  final LegalDetailsEntity legal;
  final SEOEntity seo;
  final MapsEntity maps;

  const BusinessDetailsEntity({
    required this.general,
    required this.contacts,
    required this.branches,
    required this.addresses,
    required this.social,
    required this.workingHours,
    required this.bank,
    required this.legal,
    required this.seo,
    required this.maps,
  });

  factory BusinessDetailsEntity.defaultVal() {
    return BusinessDetailsEntity(
      general: GeneralProfileEntity.defaultVal(),
      contacts: ContactDetailsEntity.defaultVal(),
      branches: const [],
      addresses: const [],
      social: SocialMediaEntity.defaultVal(),
      workingHours: WorkingHoursEntity.defaultVal(),
      bank: BankDetailsEntity.defaultVal(),
      legal: LegalDetailsEntity.defaultVal(),
      seo: SEOEntity.defaultVal(),
      maps: MapsEntity.defaultVal(),
    );
  }
}

class GeneralProfileEntity {
  final String businessName;
  final String companyName;
  final String tagline;
  final String description;
  final String ownerName;
  final String ownerDesignation;
  final String logo;
  final String coverImage;
  final String favicon;
  final String registrationNumber;
  final String gstNumber;
  final String panNumber;
  final String licenseNumber;
  final String establishedYear;

  const GeneralProfileEntity({
    required this.businessName,
    required this.companyName,
    required this.tagline,
    required this.description,
    required this.ownerName,
    required this.ownerDesignation,
    required this.logo,
    required this.coverImage,
    required this.favicon,
    required this.registrationNumber,
    required this.gstNumber,
    required this.panNumber,
    required this.licenseNumber,
    required this.establishedYear,
  });

  factory GeneralProfileEntity.defaultVal() {
    return const GeneralProfileEntity(
      businessName: '',
      companyName: '',
      tagline: '',
      description: '',
      ownerName: '',
      ownerDesignation: '',
      logo: '',
      coverImage: '',
      favicon: '',
      registrationNumber: '',
      gstNumber: '',
      panNumber: '',
      licenseNumber: '',
      establishedYear: '',
    );
  }
}

class ContactDetailsEntity {
  final List<ContactItemEntity> phones;
  final List<ContactItemEntity> whatsapps;
  final List<ContactItemEntity> emails;
  final List<ContactItemEntity> customerCares;
  final List<ContactItemEntity> emergencyContacts;

  const ContactDetailsEntity({
    required this.phones,
    required this.whatsapps,
    required this.emails,
    required this.customerCares,
    required this.emergencyContacts,
  });

  factory ContactDetailsEntity.defaultVal() {
    return const ContactDetailsEntity(
      phones: [],
      whatsapps: [],
      emails: [],
      customerCares: [],
      emergencyContacts: [],
    );
  }
}

class ContactItemEntity {
  final String id;
  final String label;
  final String value;
  final bool isPrimary;
  final bool isActive;
  final int displayOrder;

  const ContactItemEntity({
    required this.id,
    required this.label,
    required this.value,
    required this.isPrimary,
    required this.isActive,
    required this.displayOrder,
  });
}

class BranchEntity {
  final String id;
  final String branchName;
  final String branchManager;
  final String phoneNumber;
  final String whatsapp;
  final String email;
  final String fullAddress;
  final String googleMapUrl;
  final String latitude;
  final String longitude;
  final String workingHours;
  final String openingDays;
  final int displayOrder;
  final bool isActive;
  final String instagram;

  const BranchEntity({
    required this.id,
    required this.branchName,
    required this.branchManager,
    required this.phoneNumber,
    required this.whatsapp,
    required this.email,
    required this.fullAddress,
    required this.googleMapUrl,
    required this.latitude,
    required this.longitude,
    required this.workingHours,
    required this.openingDays,
    required this.displayOrder,
    required this.isActive,
    required this.instagram,
  });
}

class AddressEntity {
  final String id;
  final String addressTitle;
  final String street;
  final String area;
  final String city;
  final String district;
  final String state;
  final String country;
  final String pincode;
  final String landmark;
  final String googleMapsLink;
  final String latitude;
  final String longitude;

  const AddressEntity({
    required this.id,
    required this.addressTitle,
    required this.street,
    required this.area,
    required this.city,
    required this.district,
    required this.state,
    required this.country,
    required this.pincode,
    required this.landmark,
    required this.googleMapsLink,
    required this.latitude,
    required this.longitude,
  });
}

class SocialMediaEntity {
  final String instagramKadi;
  final String instagramThangadh;
  final String website;
  final String googleBusinessProfile;

  const SocialMediaEntity({
    required this.instagramKadi,
    required this.instagramThangadh,
    required this.website,
    required this.googleBusinessProfile,
  });

  factory SocialMediaEntity.defaultVal() {
    return const SocialMediaEntity(
      instagramKadi: '',
      instagramThangadh: '',
      website: '',
      googleBusinessProfile: '',
    );
  }
}

class WorkingHoursEntity {
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  final String sunday;
  final String holidayNotes;
  final String emergencyHours;

  const WorkingHoursEntity({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.holidayNotes,
    required this.emergencyHours,
  });

  factory WorkingHoursEntity.defaultVal() {
    return const WorkingHoursEntity(
      monday: '',
      tuesday: '',
      wednesday: '',
      thursday: '',
      friday: '',
      saturday: '',
      sunday: '',
      holidayNotes: '',
      emergencyHours: '',
    );
  }
}

class BankDetailsEntity {
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String upiId;
  final String qrCode;

  const BankDetailsEntity({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.upiId,
    required this.qrCode,
  });

  factory BankDetailsEntity.defaultVal() {
    return const BankDetailsEntity(
      bankName: '',
      accountHolder: '',
      accountNumber: '',
      ifsc: '',
      upiId: '',
      qrCode: '',
    );
  }
}

class LegalDetailsEntity {
  final String gstNumber;
  final String panNumber;
  final String msmeNumber;
  final String termsAndConditions;
  final String privacyPolicy;
  final String refundPolicy;
  final String cancellationPolicy;

  const LegalDetailsEntity({
    required this.gstNumber,
    required this.panNumber,
    required this.msmeNumber,
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.refundPolicy,
    required this.cancellationPolicy,
  });

  factory LegalDetailsEntity.defaultVal() {
    return const LegalDetailsEntity(
      gstNumber: '',
      panNumber: '',
      msmeNumber: '',
      termsAndConditions: '',
      privacyPolicy: '',
      refundPolicy: '',
      cancellationPolicy: '',
    );
  }
}

class SEOEntity {
  final String metaTitle;
  final String metaDescription;
  final String keywords;
  final String canonicalUrl;
  final String ogImage;
  final String twitterCardImage;

  const SEOEntity({
    required this.metaTitle,
    required this.metaDescription,
    required this.keywords,
    required this.canonicalUrl,
    required this.ogImage,
    required this.twitterCardImage,
  });

  factory SEOEntity.defaultVal() {
    return const SEOEntity(
      metaTitle: '',
      metaDescription: '',
      keywords: '',
      canonicalUrl: '',
      ogImage: '',
      twitterCardImage: '',
    );
  }
}

class MapsEntity {
  final String embedCode;
  final String mapUrl;
  final String coordinates;

  const MapsEntity({
    required this.embedCode,
    required this.mapUrl,
    required this.coordinates,
  });

  factory MapsEntity.defaultVal() {
    return const MapsEntity(
      embedCode: '',
      mapUrl: '',
      coordinates: '',
    );
  }
}
