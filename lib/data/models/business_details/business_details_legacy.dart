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
      int idx = 0;
      branches = branchesList.map((e) {
        final m = Map<String, dynamic>.from(e);
        final item = BranchModel.fromJson(m, idx);
        idx++;
        return item;
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

    // Ensure root primary_phone, secondary_phone, and support_email are also merged if present
    String normalizePhone(String p) {
      final clean = p.replaceAll(RegExp(r'\D'), '');
      if (clean.length == 12 && clean.startsWith('91')) {
        return clean.substring(2);
      }
      return clean;
    }

    final rootPrimaryPhone = json['primary_phone']?.toString() ?? json['phone']?.toString();
    if (rootPrimaryPhone != null && rootPrimaryPhone.trim().isNotEmpty) {
      final norm = normalizePhone(rootPrimaryPhone);
      if (!phones.any((p) => normalizePhone(p.value) == norm)) {
        phones.insert(0, ContactItemEntity(
          id: 'p_root_primary',
          label: 'Primary Phone',
          value: rootPrimaryPhone.trim(),
          isPrimary: true,
          isActive: true,
          displayOrder: 1,
        ));
      }
    }

    final rootSecondaryPhone = json['secondary_phone']?.toString();
    if (rootSecondaryPhone != null && rootSecondaryPhone.trim().isNotEmpty) {
      final norm = normalizePhone(rootSecondaryPhone);
      if (!phones.any((p) => normalizePhone(p.value) == norm)) {
        phones.add(ContactItemEntity(
          id: 'p_root_secondary',
          label: 'Secondary Phone',
          value: rootSecondaryPhone.trim(),
          isPrimary: false,
          isActive: true,
          displayOrder: phones.length + 1,
        ));
      }
    }

    final rootSupportEmail = json['support_email']?.toString() ?? json['email']?.toString();
    if (rootSupportEmail != null && rootSupportEmail.trim().isNotEmpty) {
      final emailLower = rootSupportEmail.trim().toLowerCase();
      if (!emails.any((e) => e.value.trim().toLowerCase() == emailLower)) {
        emails.insert(0, ContactItemEntity(
          id: 'e_root_support',
          label: 'Support Email',
          value: rootSupportEmail.trim(),
          isPrimary: true,
          isActive: true,
          displayOrder: 1,
        ));
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
      social = SocialMediaEntity.defaultVal();
    }
    
    String firstNonEmpty(List<dynamic> candidates) {
      for (final c in candidates) {
        if (c != null) {
          final s = c.toString().trim();
          if (s.isNotEmpty) return s;
        }
      }
      return '';
    }

    final legacySocial = json['socialLinks'] is Map ? json['socialLinks'] as Map : json;

    // 1. Resolve Branch Instagram links by actual branch identity
    String kadiBranchIg = '';
    String thangadhBranchIg = '';
    for (final branch in branches) {
      final idLower = branch.id.toLowerCase();
      final nameLower = branch.branchName.toLowerCase();
      final addrLower = branch.fullAddress.toLowerCase();
      if (branch.instagram.trim().isNotEmpty) {
        if (idLower.contains('kadi') || nameLower.contains('kadi') || addrLower.contains('kadi') ||
            idLower.contains('medha') || nameLower.contains('medha') || addrLower.contains('medha')) {
          if (kadiBranchIg.isEmpty) kadiBranchIg = branch.instagram.trim();
        } else if (idLower.contains('thangadh') || nameLower.contains('thangadh') || addrLower.contains('thangadh') ||
            idLower.contains('surajdeval') || nameLower.contains('surajdeval') || addrLower.contains('surajdeval')) {
          if (thangadhBranchIg.isEmpty) thangadhBranchIg = branch.instagram.trim();
        }
      }
    }

    // 2. Resolve Instagram (Kadi): Branch -> Social Entity -> SocialLinks -> Root
    final igKadi = firstNonEmpty([
      kadiBranchIg,
      social.instagramKadi,
      legacySocial['instagram_kadi'],
      legacySocial['instagramKadi'],
      json['instagram_kadi'],
      json['instagramKadi'],
    ]);

    // 3. Resolve Instagram (Thangadh): Branch -> Social Entity -> SocialLinks -> Root -> Legacy Instagram
    final igThangadh = firstNonEmpty([
      thangadhBranchIg,
      social.instagramThangadh,
      legacySocial['instagram_thangadh'],
      legacySocial['instagramThangadh'],
      json['instagram_thangadh'],
      json['instagramThangadh'],
      json['instagram'],
      json['instagram_url'],
    ]);

    // 4. Resolve Official Website: Social Entity -> SocialLinks -> Root -> SEO Canonical
    final website = firstNonEmpty([
      social.website,
      legacySocial['website'],
      json['website'],
      json['official_website'],
      json['business_website'],
      json['url'],
      (json['seo'] is Map) ? json['seo']['canonicalUrl'] : null,
    ]);

    // 5. Resolve Google Business Profile: Social Entity -> SocialLinks -> Root Google Business
    final googleBusiness = firstNonEmpty([
      social.googleBusinessProfile,
      legacySocial['google_business_profile'],
      legacySocial['googleBusinessProfile'],
      legacySocial['google_business'],
      json['google_business_profile'],
      json['google_business'],
      json['googleBusinessProfile'],
    ]);

    social = SocialMediaEntity(
      instagramKadi: igKadi,
      instagramThangadh: igThangadh,
      website: website,
      googleBusinessProfile: googleBusiness,
      instagram: firstNonEmpty([social.instagram, legacySocial['instagram'], json['instagram']]),
      facebook: firstNonEmpty([social.facebook, legacySocial['facebook'], json['facebook']]),
      youtube: firstNonEmpty([social.youtube, legacySocial['youtube'], json['youtube']]),
      pinterest: firstNonEmpty([social.pinterest, legacySocial['pinterest'], json['pinterest']]),
    );

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
