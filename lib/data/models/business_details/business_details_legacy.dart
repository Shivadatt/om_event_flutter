part of '../business_details_model.dart';

extension BusinessDetailsFromJson on BusinessDetailsModel {
  static BusinessDetailsEntity fromJson(Map<String, dynamic> json) {
    // 1. General Profile
    final generalMap = json['general'] as Map<String, dynamic>? ?? json;
    final general = GeneralProfileEntity(
      businessName: generalMap['businessName'] ?? generalMap['name'] ?? generalMap['business_name'] ?? '',
      companyName: generalMap['companyName'] ?? generalMap['business_name'] ?? '',
      tagline: generalMap['tagline'] ?? generalMap['business_tagline'] ?? '',
      description: generalMap['description'] ?? generalMap['workingHours'] ?? generalMap['company_description'] ?? '',
      ownerName: generalMap['ownerName'] ?? '',
      ownerDesignation: generalMap['ownerDesignation'] ?? '',
      logo: generalMap['logo'] ?? '',
      coverImage: generalMap['coverImage'] ?? generalMap['whiteLogo'] ?? '',
      favicon: generalMap['favicon'] ?? '',
      registrationNumber: generalMap['registrationNumber'] ?? '',
      gstNumber: generalMap['gstNumber'] ?? generalMap['gst'] ?? generalMap['gst_number'] ?? '',
      panNumber: generalMap['panNumber'] ?? generalMap['pan'] ?? generalMap['pan_number'] ?? '',
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
          whatsapp: m['whatsapp'] ?? m['whatsapp_number'] ?? '',
          email: m['email'] ?? '',
          fullAddress: m['fullAddress'] ?? m['address'] ?? m['address_line'] ?? '',
          googleMapUrl: m['googleMapUrl'] ?? m['googleMaps'] ?? '',
          latitude: m['latitude'] ?? '',
          longitude: m['longitude'] ?? '',
          workingHours: m['workingHours'] ?? m['businessHours'] ?? '',
          openingDays: m['openingDays'] ?? '',
          displayOrder: m['displayOrder'] ?? m['display_order'] ?? 1,
          isActive: m['isActive'] ?? m['is_active'] ?? true,
          instagram: m['instagram'] ?? m['instagram_url'] ?? '',
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

      final seenValues = <String>{};
      String normalizePhone(String p) {
        final clean = p.replaceAll(RegExp(r'\D'), '');
        if (clean.length == 12 && clean.startsWith('91')) {
          return clean.substring(2);
        }
        return clean;
      }

      if (phones.isEmpty) {
        int order = 1;
        
        final primaryVal = json['phone']?.toString() ?? json['primary_phone']?.toString();
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

        final secondaryVal = json['secondary_phone']?.toString();
        if (secondaryVal != null && secondaryVal.isNotEmpty) {
          final secNorm = normalizePhone(secondaryVal);
          if (!seenValues.contains(secNorm)) {
            seenValues.add(secNorm);
            phones.add(ContactItemEntity(
              id: 'p_${order++}',
              label: 'Secondary',
              value: secondaryVal,
              isPrimary: false,
              isActive: true,
              displayOrder: order,
            ));
          }
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
        int order = 1;

        final legacyWa = json['whatsapp']?.toString() ?? json['whatsapp_number']?.toString();
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
          final bWa = branch.whatsapp.isNotEmpty ? branch.whatsapp : branch.phoneNumber;
          final norm = normalizePhone(bWa);
          if (bWa.isNotEmpty && !seenWa.contains(norm)) {
            seenWa.add(norm);
            whatsapps.add(ContactItemEntity(
              id: 'w_${order++}',
              label: '${branch.branchName} WhatsApp',
              value: bWa,
              isPrimary: false,
              isActive: true,
              displayOrder: order,
            ));
          }
        }
      }

      final legacyEmail = json['email'] ?? json['support_email'];
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
      final legacySocial = json['socialLinks'] as Map? ?? json;
      String igKadi = (legacySocial['instagram_kadi'] ?? legacySocial['instagramKadi'] ?? '').toString();
      String igThangadh = (legacySocial['instagram_thangadh'] ?? legacySocial['instagramThangadh'] ?? '').toString();
      final website = (legacySocial['website'] ?? '').toString();
      final googleBusiness = (legacySocial['google_business_profile'] ?? legacySocial['googleBusinessProfile'] ?? legacySocial['google_business'] ?? '').toString();

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
