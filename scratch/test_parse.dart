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

  GeneralProfileEntity({
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

  BranchEntity({
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

class ContactDetailsEntity {
  final List<ContactItemEntity> phones;
  final List<ContactItemEntity> whatsapps;
  final List<ContactItemEntity> emails;
  final List<ContactItemEntity> customerCares;
  final List<ContactItemEntity> emergencyContacts;

  ContactDetailsEntity({
    required this.phones,
    required this.whatsapps,
    required this.emails,
    required this.customerCares,
    required this.emergencyContacts,
  });
}

class SocialMediaEntity {
  final String instagramKadi;
  final String instagramThangadh;
  final String website;
  final String googleBusinessProfile;

  SocialMediaEntity({
    required this.instagramKadi,
    required this.instagramThangadh,
    required this.website,
    required this.googleBusinessProfile,
  });
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

  WorkingHoursEntity({
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
}

class BankDetailsEntity {
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final String upiId;
  final String qrCode;

  BankDetailsEntity({
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.upiId,
    required this.qrCode,
  });
}

class LegalDetailsEntity {
  final String gstNumber;
  final String panNumber;
  final String msmeNumber;
  final String termsAndConditions;
  final String privacyPolicy;
  final String refundPolicy;
  final String cancellationPolicy;

  LegalDetailsEntity({
    required this.gstNumber,
    required this.panNumber,
    required this.msmeNumber,
    required this.termsAndConditions,
    required this.privacyPolicy,
    required this.refundPolicy,
    required this.cancellationPolicy,
  });
}

class SEOEntity {
  final String metaTitle;
  final String metaDescription;
  final String keywords;
  final String canonicalUrl;
  final String ogImage;
  final String twitterCardImage;

  SEOEntity({
    required this.metaTitle,
    required this.metaDescription,
    required this.keywords,
    required this.canonicalUrl,
    required this.ogImage,
    required this.twitterCardImage,
  });
}

class MapsEntity {
  final String embedCode;
  final String mapUrl;
  final String coordinates;

  MapsEntity({
    required this.embedCode,
    required this.mapUrl,
    required this.coordinates,
  });
}

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

  BusinessDetailsEntity({
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

  AddressEntity({
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

BusinessDetailsEntity fromJson(Map<String, dynamic> json) {
  // 1. General Profile
  final generalMap = json['general'] as Map<String, dynamic>? ?? json;
  final general = GeneralProfileEntity(
    businessName: generalMap['businessName'] ?? generalMap['name'] ?? '',
    companyName: generalMap['companyName'] ?? '',
    tagline: generalMap['tagline'] ?? '',
    description: generalMap['description'] ?? generalMap['workingHours'] ?? '',
    ownerName: generalMap['ownerName'] ?? '',
    ownerDesignation: generalMap['ownerDesignation'] ?? '',
    logo: generalMap['logo'] ?? '',
    coverImage: generalMap['coverImage'] ?? generalMap['whiteLogo'] ?? '',
    favicon: generalMap['favicon'] ?? '',
    registrationNumber: generalMap['registrationNumber'] ?? '',
    gstNumber: generalMap['gstNumber'] ?? generalMap['gst'] ?? '',
    panNumber: generalMap['panNumber'] ?? generalMap['pan'] ?? '',
    licenseNumber: generalMap['licenseNumber'] ?? '',
    establishedYear: generalMap['establishedYear'] ?? '',
  );

  // 2. Branches
  List<BranchEntity> branches = [];
  final branchesList = json['branches'] as List? ?? json['officeBranches'] as List?;
  if (branchesList != null) {
    branches = branchesList.map((e) {
      final m = Map<String, dynamic>.from(e);
      return BranchEntity(
        id: m['id'] ?? '',
        branchName: m['branchName'] ?? m['name'] ?? '',
        branchManager: m['branchManager'] ?? '',
        phoneNumber: m['phoneNumber'] ?? m['phone'] ?? m['phone1'] ?? '',
        whatsapp: m['whatsapp'] ?? '',
        email: m['email'] ?? '',
        fullAddress: m['fullAddress'] ?? m['address'] ?? '',
        googleMapUrl: m['googleMapUrl'] ?? m['googleMaps'] ?? '',
        latitude: m['latitude'] ?? '',
        longitude: m['longitude'] ?? '',
        workingHours: m['workingHours'] ?? m['businessHours'] ?? '',
        openingDays: m['openingDays'] ?? '',
        displayOrder: m['displayOrder'] ?? 1,
        isActive: m['isActive'] ?? true,
        instagram: m['instagram'] ?? '',
      );
    }).toList();
  }

  // 3. Contacts
  final contactsMap = json['contacts'] as Map<String, dynamic>?;
  List<ContactItemEntity> phones = [];
  List<ContactItemEntity> whatsapps = [];
  List<ContactItemEntity> emails = [];
  // List<ContactItemEntity> customerCares = [];
  // List<ContactItemEntity> emergencyContacts = [];

  if (contactsMap != null) {
    // skipped for test
  } else {
    // Parse legacy fields from root
    final legacyContacts = json['contactNumbers'] as List?;
    if (legacyContacts != null && legacyContacts.isNotEmpty) {
      // ...
    }

    if (phones.isEmpty) {
      final seenValues = <String>{};
      String normalizePhone(String p) {
        final clean = p.replaceAll(RegExp(r'\D'), '');
        if (clean.length == 12 && clean.startsWith('91')) {
          return clean.substring(2);
        }
        return clean;
      }

      int order = 1;
      
      final primaryVal = json['phone']?.toString();
      if (primaryVal != null && primaryVal.isNotEmpty) {
        final primaryNorm = normalizePhone(primaryVal);
        seenValues.add(primaryNorm);

        String primaryLabel = 'Primary';
        for (final branch in branches) {
          if (normalizePhone(branch.phoneNumber) == primaryNorm) {
            primaryLabel = '${branch.branchName} Phone';
            break;
          }
        }

        phones.add(ContactItemEntity(
          id: 'p_${order++}',
          label: primaryLabel,
          value: primaryVal,
          isPrimary: true,
          isActive: true,
          displayOrder: 1,
        ));
      }

      for (final branch in branches) {
        final norm = normalizePhone(branch.phoneNumber);
        if (branch.phoneNumber.isNotEmpty && !seenValues.contains(norm)) {
          seenValues.add(norm);
          phones.add(ContactItemEntity(
            id: 'p_${order++}',
            label: '${branch.branchName} Phone',
            value: branch.phoneNumber,
            isPrimary: false,
            isActive: true,
            displayOrder: order,
          ));
        }
      }
    }

    if (whatsapps.isEmpty) {
      final seenWa = <String>{};
      String normalizePhone(String p) {
        final clean = p.replaceAll(RegExp(r'\D'), '');
        if (clean.length == 12 && clean.startsWith('91')) {
          return clean.substring(2);
        }
        return clean;
      }

      int order = 1;

      final legacyWa = json['whatsapp']?.toString();
      if (legacyWa != null && legacyWa.isNotEmpty) {
        final normWa = normalizePhone(legacyWa);
        seenWa.add(normWa);

        String waLabel = 'WhatsApp';
        for (final branch in branches) {
          if (normalizePhone(branch.whatsapp) == normWa) {
            waLabel = '${branch.branchName} WhatsApp';
            break;
          }
        }

        whatsapps.add(ContactItemEntity(
          id: 'w_${order++}',
          label: waLabel,
          value: legacyWa,
          isPrimary: true,
          isActive: true,
          displayOrder: 1,
        ));
      }

      for (final branch in branches) {
        final norm = normalizePhone(branch.whatsapp);
        if (branch.whatsapp.isNotEmpty && !seenWa.contains(norm)) {
          seenWa.add(norm);
          whatsapps.add(ContactItemEntity(
            id: 'w_${order++}',
            label: '${branch.branchName} WhatsApp',
            value: branch.whatsapp,
            isPrimary: false,
            isActive: true,
            displayOrder: order,
          ));
        }
      }
    }

    final legacyEmail = json['email'];
    if (legacyEmail != null && legacyEmail.toString().isNotEmpty) {
      emails = [
        ContactItemEntity(
          id: 'e1',
          label: 'Email',
          value: legacyEmail.toString(),
          isPrimary: true,
          isActive: true,
          displayOrder: 1,
        ),
      ];
    }
  }

  // 4. Addresses
  List<AddressEntity> addresses = [];
  final addressesList = json['addresses'] as List?;
  if (addressesList != null) {
    // ...
  } else {
    final branchesList = json['officeBranches'] as List?;
    if (branchesList != null && branchesList.isNotEmpty) {
      final firstBranch = Map<String, dynamic>.from(branchesList.first);
      addresses = [
        AddressEntity(
          id: 'addr_1',
          addressTitle: 'Main Office',
          street: firstBranch['address'] ?? '',
          area: '',
          city: firstBranch['city'] ?? '',
          district: '',
          state: firstBranch['state'] ?? '',
          country: firstBranch['country'] ?? 'India',
          pincode: firstBranch['pincode'] ?? '',
          landmark: '',
          googleMapsLink: firstBranch['googleMaps'] ?? '',
          latitude: '',
          longitude: '',
        ),
      ];
    } else {
      addresses = const [];
    }
  }

  // 5. Social Media
  SocialMediaEntity social;
  final socialData = json['social'];
  if (socialData is Map) {
    // ...
    social = SocialMediaEntity(instagramKadi: '', instagramThangadh: '', website: '', googleBusinessProfile: '');
  } else {
    final legacySocial = json['socialLinks'] as Map?;
    String igKadi = (legacySocial?['instagram_kadi'] ?? legacySocial?['instagramKadi'] ?? '').toString();
    String igThangadh = (legacySocial?['instagram_thangadh'] ?? legacySocial?['instagramThangadh'] ?? '').toString();
    final website = (legacySocial?['website'] ?? '').toString();
    final googleBusiness = (legacySocial?['google_business_profile'] ?? legacySocial?['googleBusinessProfile'] ?? '').toString();

    if (igKadi.isEmpty || igThangadh.isEmpty) {
      for (final branch in branches) {
        final lowerName = branch.branchName.toLowerCase();
        final lowerAddress = branch.fullAddress.toLowerCase();
        if (branch.instagram.isNotEmpty) {
          if (lowerName.contains('kadi') || lowerAddress.contains('kadi')) {
            if (igKadi.isEmpty) igKadi = branch.instagram;
          } else if (lowerName.contains('thangadh') || lowerAddress.contains('thangadh')) {
            if (igThangadh.isEmpty) igThangadh = branch.instagram;
          }
        }
      }
    }

    social = SocialMediaEntity(
      instagramKadi: igKadi,
      instagramThangadh: igThangadh,
      website: website,
      googleBusinessProfile: googleBusiness,
    );
  }

  // 6. Working Hours
  WorkingHoursEntity workingHours;
  final workingData = json['workingHours'];
  if (workingData is Map) {
    // ...
    workingHours = WorkingHoursEntity(monday: '', tuesday: '', wednesday: '', thursday: '', friday: '', saturday: '', sunday: '', holidayNotes: '', emergencyHours: '');
  } else {
    final legacyHours = workingData as String?;
    workingHours = WorkingHoursEntity(
      monday: legacyHours ?? '',
      tuesday: legacyHours ?? '',
      wednesday: legacyHours ?? '',
      thursday: legacyHours ?? '',
      friday: legacyHours ?? '',
      saturday: legacyHours ?? '',
      sunday: '',
      holidayNotes: '',
      emergencyHours: '',
    );
  }

  // 7. Bank Details
  final bank = BankDetailsEntity(bankName: '', accountHolder: '', accountNumber: '', ifsc: '', upiId: '', qrCode: '');

  // 8. Legal Details
  final legalData = json['legal'];
  LegalDetailsEntity legal;
  if (legalData is Map) {
    // ...
    legal = LegalDetailsEntity(gstNumber: '', panNumber: '', msmeNumber: '', termsAndConditions: '', privacyPolicy: '', refundPolicy: '', cancellationPolicy: '');
  } else {
    legal = LegalDetailsEntity(
      gstNumber: json['gst'] ?? '',
      panNumber: json['pan'] ?? '',
      msmeNumber: '',
      termsAndConditions: '',
      privacyPolicy: '',
      refundPolicy: '',
      cancellationPolicy: '',
    );
  }

  // 9. SEO
  final seo = SEOEntity(metaTitle: '', metaDescription: '', keywords: '', canonicalUrl: '', ogImage: '', twitterCardImage: '');

  // 10. Maps
  final mapsData = json['maps'];
  MapsEntity maps;
  if (mapsData is Map) {
    // ...
    maps = MapsEntity(embedCode: '', mapUrl: '', coordinates: '');
  } else {
    maps = MapsEntity(
      embedCode: '',
      mapUrl: json['googleMaps'] ?? '',
      coordinates: '',
    );
  }

  return BusinessDetailsEntity(
    general: general,
    contacts: ContactDetailsEntity(
      phones: phones,
      whatsapps: whatsapps,
      emails: emails,
      customerCares: [],
      emergencyContacts: [],
    ),
    branches: branches,
    addresses: addresses,
    social: social,
    workingHours: workingHours,
    bank: bank,
    legal: legal,
    seo: seo,
    maps: maps,
  );
}

void main() {
  final json = {
    'companyName': 'Om Events & Decorators',
    'email': 'omeventsanddecorators@gmail.com',
    'name': 'Om Events',
    'officeBranches': [
      {
        'address': 'near mahadev mandir medha',
        'branchName': 'Kadi Main Office',
        'businessHours': '9:00 AM - 10:00 PM',
        'city': 'kadi',
        'country': 'India',
        'email': 'omeventsanddecorators@gmail.com',
      }
    ]
  };

  try {
    print("Parsing legacy JSON...");
    final entity = fromJson(json);
    print("Parsed successfully!");
    print("Name: ${entity.general.businessName}");
    print("Company Name: ${entity.general.companyName}");
    print("Branches: ${entity.branches.length}");
    if (entity.branches.isNotEmpty) {
      print("First branch name: ${entity.branches.first.branchName}");
      print("First branch address: ${entity.branches.first.fullAddress}");
    }
    print("Phones: ${entity.contacts.phones.length}");
    print("Emails: ${entity.contacts.emails.length}");
    print("Social Kadi: ${entity.social.instagramKadi}");
  } catch (e, stack) {
    print("PARSING ERROR: $e");
    print(stack);
  }
}
