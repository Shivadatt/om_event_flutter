part of '../settings_repository_impl.dart';

mixin SettingsBusiness {
  DocumentReference<Map<String, dynamic>> _getDocRef(String docId);

  Stream<BusinessProfile> streamBusiness() {
    return _getDocRef('business')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return BusinessProfile.defaultVal();
          final data = doc.data()!;
          final source = data['published'] ?? data['draft'] ?? {};

          final List<dynamic> rawBranches = source['officeBranches'] ?? [];
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

          final rawSocial = source['socialLinks'] ?? {};
          final socialLinks = Map<String, String>.from(
            rawSocial.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );

          final List<dynamic> rawContacts = source['contactNumbers'] ?? [];
          List<ContactNumberEntity> contactNumbers;
          if (rawContacts.isNotEmpty) {
            contactNumbers = rawContacts
                .map((c) => ContactNumberModel.fromJson(Map<String, dynamic>.from(c)))
                .map(ContactNumberMapper.toEntity)
                .toList();
          } else {
            final oldPhone = source['phone']?.toString();
            if (oldPhone != null && oldPhone.isNotEmpty) {
              contactNumbers = [
                ContactNumberEntity(
                  id: '1',
                  label: 'Primary',
                  number: oldPhone,
                  isPrimary: true,
                  isActive: true,
                  displayOrder: 1,
                ),
              ];
            } else {
              contactNumbers = [];
            }
          }

          return BusinessProfile(
            name: source['name'] ?? 'Om Events',
            companyName: source['companyName'] ?? 'Om Events & Decorators',
            logo: source['logo'] ?? '',
            whiteLogo: source['whiteLogo'] ?? '',
            favicon: source['favicon'] ?? '',
            gst: source['gst'] ?? '',
            pan: source['pan'] ?? '',
            ownerName: source['ownerName'] ?? '',
            contactNumbers: contactNumbers,
            email: source['email'] ?? '',
            whatsapp: source['whatsapp'] ?? '',
            officeBranches: officeBranches,
            workingHours: source['workingHours'] ?? '9:00 AM - 8:00 PM',
            socialLinks:
                socialLinks.isNotEmpty
                    ? socialLinks
                    : BusinessProfile.defaultVal().socialLinks,
          );
        });
  }

  Future<void> saveBusiness(BusinessProfile profile) async {
    await _saveToDraft('business', {
      'name': profile.name,
      'companyName': profile.companyName,
      'logo': profile.logo,
      'whiteLogo': profile.whiteLogo,
      'favicon': profile.favicon,
      'gst': profile.gst,
      'pan': profile.pan,
      'ownerName': profile.ownerName,
      'contactNumbers': profile.contactNumbers
          .map(ContactNumberMapper.toModel)
          .map((m) => m.toJson())
          .toList(),
      'email': profile.email,
      'whatsapp': profile.whatsapp,
      'officeBranches': profile.officeBranches.map((b) => b.toMap()).toList(),
      'workingHours': profile.workingHours,
      'socialLinks': profile.socialLinks,
    });
  }

  Future<void> _saveToDraft(String docId, Map<String, dynamic> draftData);
}
