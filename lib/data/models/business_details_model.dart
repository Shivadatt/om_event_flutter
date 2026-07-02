import '../../domain/entities/business_details_entity.dart';

class BusinessDetailsModel {
  static BusinessDetailsEntity fromJson(Map<String, dynamic> json) {
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
    List<ContactItemEntity> customerCares = [];
    List<ContactItemEntity> emergencyContacts = [];

    if (contactsMap != null) {
      phones = (contactsMap['phones'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      whatsapps = (contactsMap['whatsapps'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emails = (contactsMap['emails'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      customerCares = (contactsMap['customerCares'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      emergencyContacts = (contactsMap['emergencyContacts'] as List? ?? [])
          .map((e) => ContactItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      // Parse legacy fields from root
      final legacyContacts = json['contactNumbers'] as List?;
      if (legacyContacts != null && legacyContacts.isNotEmpty) {
        phones = legacyContacts.map((c) {
          final m = Map<String, dynamic>.from(c);
          return ContactItemEntity(
            id: m['id'] ?? '',
            label: m['label'] ?? 'Phone',
            value: m['number'] ?? m['value'] ?? '',
            isPrimary: m['isPrimary'] ?? false,
            isActive: m['isActive'] ?? true,
            displayOrder: m['displayOrder'] ?? 1,
          );
        }).toList();
      }

      // If phones is still empty, dynamically extract from root phone and branches!
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

      // If whatsapps is still empty, dynamically extract from root whatsapp and branches!
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
      addresses = addressesList
          .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
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
      social = SocialMediaModel.fromJson(Map<String, dynamic>.from(socialData));
    } else {
      final legacySocial = json['socialLinks'] as Map?;
      String igKadi = (legacySocial?['instagram_kadi'] ?? legacySocial?['instagramKadi'] ?? '').toString();
      String igThangadh = (legacySocial?['instagram_thangadh'] ?? legacySocial?['instagramThangadh'] ?? '').toString();
      final website = (legacySocial?['website'] ?? '').toString();
      final googleBusiness = (legacySocial?['google_business_profile'] ?? legacySocial?['googleBusinessProfile'] ?? '').toString();

      // Dynamically extract Instagram links from branches if they are empty in socialLinks
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
      workingHours = WorkingHoursModel.fromJson(Map<String, dynamic>.from(workingData));
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
    final bank = BankDetailsModel.fromJson(Map<String, dynamic>.from(json['bank'] ?? {}));

    // 8. Legal Details
    final legalData = json['legal'];
    LegalDetailsEntity legal;
    if (legalData is Map) {
      legal = LegalDetailsModel.fromJson(Map<String, dynamic>.from(legalData));
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
    final seo = SEOModel.fromJson(Map<String, dynamic>.from(json['seo'] ?? {}));

    // 10. Maps
    final mapsData = json['maps'];
    MapsEntity maps;
    if (mapsData is Map) {
      maps = MapsModel.fromJson(Map<String, dynamic>.from(mapsData));
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
        customerCares: customerCares,
        emergencyContacts: emergencyContacts,
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

  static Map<String, dynamic> toJson(BusinessDetailsEntity entity) {
    final primaryEmail = entity.contacts.emails.firstWhere(
      (e) => e.isPrimary && e.isActive,
      orElse: () => entity.contacts.emails.firstWhere(
        (e) => e.isActive,
        orElse: () => const ContactItemEntity(id: '', label: '', value: 'omeventsanddecorators@gmail.com', isPrimary: false, isActive: false, displayOrder: 0),
      ),
    ).value;

    final primaryWa = entity.contacts.whatsapps.firstWhere(
      (w) => w.isPrimary && w.isActive,
      orElse: () => entity.contacts.whatsapps.firstWhere(
        (w) => w.isActive,
        orElse: () => const ContactItemEntity(id: '', label: '', value: '9512149944', isPrimary: false, isActive: false, displayOrder: 0),
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

class BranchModel {
  static BranchEntity fromJson(Map<String, dynamic> json) {
    return BranchEntity(
      id: json['id'] ?? '',
      branchName: json['branchName'] ?? '',
      branchManager: json['branchManager'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      email: json['email'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      googleMapUrl: json['googleMapUrl'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      workingHours: json['workingHours'] ?? '',
      openingDays: json['openingDays'] ?? '',
      displayOrder: json['displayOrder'] ?? 1,
      isActive: json['isActive'] ?? true,
      instagram: json['instagram'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(BranchEntity entity) {
    return {
      'id': entity.id,
      'branchName': entity.branchName,
      'branchManager': entity.branchManager,
      'phoneNumber': entity.phoneNumber,
      'whatsapp': entity.whatsapp,
      'email': entity.email,
      'fullAddress': entity.fullAddress,
      'googleMapUrl': entity.googleMapUrl,
      'latitude': entity.latitude,
      'longitude': entity.longitude,
      'workingHours': entity.workingHours,
      'openingDays': entity.openingDays,
      'displayOrder': entity.displayOrder,
      'isActive': entity.isActive,
      'instagram': entity.instagram,
    };
  }
}

class AddressModel {
  static AddressEntity fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'] ?? '',
      addressTitle: json['addressTitle'] ?? '',
      street: json['street'] ?? '',
      area: json['area'] ?? '',
      city: json['city'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
      landmark: json['landmark'] ?? '',
      googleMapsLink: json['googleMapsLink'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(AddressEntity entity) {
    return {
      'id': entity.id,
      'addressTitle': entity.addressTitle,
      'street': entity.street,
      'area': entity.area,
      'city': entity.city,
      'district': entity.district,
      'state': entity.state,
      'country': entity.country,
      'pincode': entity.pincode,
      'landmark': entity.landmark,
      'googleMapsLink': entity.googleMapsLink,
      'latitude': entity.latitude,
      'longitude': entity.longitude,
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
