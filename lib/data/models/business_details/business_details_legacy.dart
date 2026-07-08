part of '../business_details_model.dart';

extension BusinessDetailsFromJson on BusinessDetailsModel {
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
}
