part of '../settings_repository_impl.dart';

mixin SettingsBusiness {
  DocumentReference<Map<String, dynamic>> _getDocRef(String docId);

  Stream<BusinessProfile> streamBusiness() {
    return _getDocRef('business_info')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return BusinessProfile.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? data;

          String firstNonEmpty(List<dynamic> candidates) {
            for (final c in candidates) {
              if (c != null) {
                final s = c.toString().trim();
                if (s.isNotEmpty) return s;
              }
            }
            return '';
          }

          final List<dynamic> rawBranches = source['branches'] ?? source['officeBranches'] ?? data['branches'] ?? [];
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

          // Resolve branch Instagram by identifier
          String kadiBranchIg = '';
          String thangadhBranchIg = '';
          for (final b in officeBranches) {
            final idLower = b.id.toLowerCase();
            final nameLower = b.branchName.toLowerCase();
            final addrLower = b.address.toLowerCase();
            if (b.instagram.trim().isNotEmpty) {
              if (idLower.contains('kadi') || nameLower.contains('kadi') || addrLower.contains('kadi') ||
                  idLower.contains('medha') || nameLower.contains('medha') || addrLower.contains('medha')) {
                if (kadiBranchIg.isEmpty) kadiBranchIg = b.instagram.trim();
              } else if (idLower.contains('thangadh') || nameLower.contains('thangadh') || addrLower.contains('thangadh') ||
                  idLower.contains('surajdeval') || nameLower.contains('surajdeval') || addrLower.contains('surajdeval')) {
                if (thangadhBranchIg.isEmpty) thangadhBranchIg = b.instagram.trim();
              }
            }
          }

          final Map<dynamic, dynamic> rawSocialMap = source['socialLinks'] is Map 
              ? Map<dynamic, dynamic>.from(source['socialLinks']) 
              : (source['social'] is Map ? Map<dynamic, dynamic>.from(source['social']) : <dynamic, dynamic>{});
          final Map<dynamic, dynamic> rootSocialMap = data['socialLinks'] is Map 
              ? Map<dynamic, dynamic>.from(data['socialLinks']) 
              : (data['social'] is Map ? Map<dynamic, dynamic>.from(data['social']) : <dynamic, dynamic>{});

          final socialKadi = firstNonEmpty([
            kadiBranchIg,
            source['instagram_kadi'],
            source['instagramKadi'],
            rawSocialMap['instagram_kadi'],
            rawSocialMap['instagramKadi'],
            data['instagram_kadi'],
            data['instagramKadi'],
            rootSocialMap['instagram_kadi'],
          ]);

          final socialThangadh = firstNonEmpty([
            thangadhBranchIg,
            source['instagram_thangadh'],
            source['instagramThangadh'],
            rawSocialMap['instagram_thangadh'],
            rawSocialMap['instagramThangadh'],
            data['instagram_thangadh'],
            data['instagramThangadh'],
            rootSocialMap['instagram_thangadh'],
            source['instagram'],
            source['instagram_url'],
            data['instagram'],
            data['instagram_url'],
          ]);

          final socialWebsite = firstNonEmpty([
            source['website'],
            rawSocialMap['website'],
            data['website'],
            rootSocialMap['website'],
            source['official_website'],
            data['official_website'],
            (source['seo'] is Map) ? source['seo']['canonicalUrl'] : null,
          ]);

          final socialGoogleBiz = firstNonEmpty([
            source['google_business_profile'],
            source['google_business'],
            source['googleBusinessProfile'],
            rawSocialMap['google_business_profile'],
            rawSocialMap['googleBusinessProfile'],
            rawSocialMap['google_business'],
            data['google_business_profile'],
            data['google_business'],
            rootSocialMap['google_business_profile'],
          ]);

          final socialLinks = Map<String, String>.from(
            rawSocialMap.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
          if (socialKadi.isNotEmpty) socialLinks['instagram_kadi'] = socialKadi;
          if (socialThangadh.isNotEmpty) socialLinks['instagram_thangadh'] = socialThangadh;
          if (socialWebsite.isNotEmpty) socialLinks['website'] = socialWebsite;
          if (socialGoogleBiz.isNotEmpty) socialLinks['google_business_profile'] = socialGoogleBiz;

          final List<dynamic> rawContacts = source['contactNumbers'] ?? [];
          List<ContactNumberEntity> contactNumbers = [];
          if (rawContacts.isNotEmpty) {
            contactNumbers = rawContacts
                .map((c) => ContactNumberModel.fromJson(Map<String, dynamic>.from(c)))
                .map(ContactNumberMapper.toEntity)
                .toList();
          }
          
          final primaryPhone = source['primary_phone']?.toString() ?? source['phone']?.toString();
          final secondaryPhone = source['secondary_phone']?.toString();

          if (primaryPhone != null && primaryPhone.trim().isNotEmpty) {
            final exists = contactNumbers.any((c) => c.number.replaceAll(RegExp(r'\D'), '') == primaryPhone.replaceAll(RegExp(r'\D'), ''));
            if (!exists) {
              contactNumbers.insert(
                0,
                ContactNumberEntity(
                  id: 'primary',
                  label: 'Primary',
                  number: primaryPhone,
                  isPrimary: true,
                  isActive: true,
                  displayOrder: 1,
                ),
              );
            }
          }
          if (secondaryPhone != null && secondaryPhone.trim().isNotEmpty) {
            final exists = contactNumbers.any((c) => c.number.replaceAll(RegExp(r'\D'), '') == secondaryPhone.replaceAll(RegExp(r'\D'), ''));
            if (!exists) {
              contactNumbers.add(
                ContactNumberEntity(
                  id: 'secondary',
                  label: 'Secondary',
                  number: secondaryPhone,
                  isPrimary: false,
                  isActive: true,
                  displayOrder: contactNumbers.length + 1,
                ),
              );
            }
          }

          return BusinessProfile(
            name: source['business_name'] ?? source['name'] ?? 'Om Events',
            companyName: source['business_name'] ?? source['companyName'] ?? 'Om Events & Decorators',
            logo: source['logo'] ?? '',
            whiteLogo: source['whiteLogo'] ?? '',
            favicon: source['favicon'] ?? '',
            gst: source['gst_number'] ?? source['gst'] ?? '',
            pan: source['pan_number'] ?? source['pan'] ?? '',
            ownerName: source['ownerName'] ?? 'Shivadatt',
            contactNumbers: contactNumbers,
            email: source['support_email'] ?? source['email'] ?? '',
            whatsapp: source['whatsapp_number'] ?? source['whatsapp'] ?? '',
            officeBranches: officeBranches,
            workingHours: source['workingHours'] ?? '9:00 AM - 10:00 PM',
            socialLinks:
                socialLinks.isNotEmpty
                    ? socialLinks
                    : BusinessProfile.defaultVal().socialLinks,
          );
        });
  }

  Future<void> saveBusiness(BusinessProfile profile) async {
    await _saveToDraft('business_info', {
      'business_name': profile.name,
      'companyName': profile.companyName,
      'logo': profile.logo,
      'whiteLogo': profile.whiteLogo,
      'favicon': profile.favicon,
      'gst_number': profile.gst,
      'pan_number': profile.pan,
      'ownerName': profile.ownerName,
      'contactNumbers': profile.contactNumbers
          .map(ContactNumberMapper.toModel)
          .map((m) => m.toJson())
          .toList(),
      'support_email': profile.email,
      'whatsapp_number': profile.whatsapp,
      'branches': profile.officeBranches.map((b) => b.toMap()).toList(),
      'workingHours': profile.workingHours,
      'socialLinks': profile.socialLinks,
      // For backward compatibility also write to root flat fields
      'instagram_kadi': profile.socialLinks['instagram_kadi'] ?? '',
      'instagram_thangadh': profile.socialLinks['instagram_thangadh'] ?? '',
      'website': profile.socialLinks['website'] ?? '',
      'google_business': profile.socialLinks['google_business_profile'] ?? '',
      'primary_phone': profile.contactNumbers.firstWhere((c) => c.isPrimary, orElse: () => profile.contactNumbers.first).number,
      'secondary_phone': profile.contactNumbers.firstWhere((c) => !c.isPrimary, orElse: () => const ContactNumberEntity(id: '', label: '', number: '', isPrimary: false, isActive: false, displayOrder: 0)).number,
    });
  }

  Future<void> _saveToDraft(String docId, Map<String, dynamic> draftData);
}
