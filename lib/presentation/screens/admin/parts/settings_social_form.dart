part of '../system_settings_screen.dart';

extension _SettingsSocialFormExtension on _SystemSettingsScreenState {
  bool _isValidInstagramUrl(String url) {
    if (url.trim().isEmpty) return false;
    final regExp = RegExp(
      r'^(https?:\/\/)?(www\.)?instagram\.com\/[a-zA-Z0-9_\-\.]+\/?$',
      caseSensitive: false,
    );
    return regExp.hasMatch(url);
  }

  Widget _instagramField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.italiana(
            fontSize: 18,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: AppTheme.sansBody(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            fillColor: const Color(0xFF131D1A),
            filled: true,
            hintText: "https://www.instagram.com/your_account/",
            hintStyle: const TextStyle(color: Colors.white24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF254235)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFC9A77E)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Instagram URL is required";
            }
            if (!_isValidInstagramUrl(value)) {
              return "Please enter a valid Instagram URL (e.g., https://www.instagram.com/username/)";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSocialForm() {
    final formKey = GlobalKey<FormState>();
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SOCIAL REDIRECT LINKS",
            style: GoogleFonts.italiana(fontSize: 24),
          ),
          const SizedBox(height: 24),
          _instagramField("Instagram - Kadi", _socialInstagramKadi),
          _instagramField("Instagram - Thangadh", _socialInstagramThangadh),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _saveAndPublish('business', () async {
                  final busCurrent =
                      AppConfigService.to.rxBusinessProfile.value;

                  final updatedSocialLinks = {
                    "instagram_kadi": _socialInstagramKadi.text.trim(),
                    "instagram_thangadh": _socialInstagramThangadh.text.trim(),
                  };

                  await _repository.saveBusiness(
                    BusinessProfile(
                      name: busCurrent.name,
                      companyName: busCurrent.companyName,
                      logo: busCurrent.logo,
                      whiteLogo: busCurrent.whiteLogo,
                      favicon: busCurrent.favicon,
                      gst: busCurrent.gst,
                      pan: busCurrent.pan,
                      ownerName: busCurrent.ownerName,
                      contactNumbers: busCurrent.contactNumbers,
                      email: busCurrent.email,
                      whatsapp: busCurrent.whatsapp,
                      officeBranches: busCurrent.officeBranches,
                      workingHours: busCurrent.workingHours,
                      socialLinks: updatedSocialLinks,
                    ),
                  );
                });
              }
            },
            child: const Text("Save & Publish Live"),
          ),
        ],
      ),
    );
  }
}
