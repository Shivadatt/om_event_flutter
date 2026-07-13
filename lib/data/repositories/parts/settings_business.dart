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

          final List<dynamic> rawBranches = source['branches'] ?? source['officeBranches'] ?? [];
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

          final rawSocial = source['socialLinks'] ?? {
            'instagram_kadi': source['instagram_kadi'] ?? source['instagram'] ?? '',
            'instagram_thangadh': source['instagram_thangadh'] ?? source['instagram'] ?? '',
            'website': source['website'] ?? '',
            'google_business_profile': source['google_business'] ?? '',
          };
          final socialLinks = Map<String, String>.from(
            rawSocial.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );

          final List<dynamic> rawContacts = source['contactNumbers'] ?? [];
          List<ContactNumberEntity> contactNumbers = [];
          if (rawContacts.isNotEmpty) {
            contactNumbers = rawContacts
                .map((c) => ContactNumberModel.fromJson(Map<String, dynamic>.from(c)))
                .map(ContactNumberMapper.toEntity)
                .toList();
          } else {
            final primaryPhone = source['primary_phone']?.toString() ?? source['phone']?.toString();
            final secondaryPhone = source['secondary_phone']?.toString();

            if (primaryPhone != null && primaryPhone.isNotEmpty) {
              contactNumbers.add(
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
            if (secondaryPhone != null && secondaryPhone.isNotEmpty) {
              contactNumbers.add(
                ContactNumberEntity(
                  id: 'secondary',
                  label: 'Secondary',
                  number: secondaryPhone,
                  isPrimary: false,
                  isActive: true,
                  displayOrder: 2,
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
