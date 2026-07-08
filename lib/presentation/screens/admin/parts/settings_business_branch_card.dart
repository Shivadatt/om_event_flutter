part of '../system_settings_screen.dart';

extension _SettingsBusinessBranchCardExtension on _SystemSettingsScreenState {
  Widget _buildBranchCard({
    required String title,
    required TextEditingController nameCtrl,
    required TextEditingController addressCtrl,
    required TextEditingController cityCtrl,
    required TextEditingController stateCtrl,
    required TextEditingController countryCtrl,
    required TextEditingController pinCtrl,
    required TextEditingController mapCtrl,
    required TextEditingController latCtrl,
    required TextEditingController lngCtrl,
    required TextEditingController phone1Ctrl,
    required TextEditingController phone2Ctrl,
    required TextEditingController whatsappCtrl,
    required TextEditingController emailCtrl,
    required TextEditingController instaCtrl,
    required TextEditingController hoursCtrl,
    required bool isPrimary,
    required ValueChanged<bool> onPrimaryChanged,
  }) {
    return Card(
      color: const Color(0xFF131D1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC9A77E), width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 24),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: const Icon(Icons.location_on, color: Color(0xFFC9A77E)),
          title: Text(
            title,
            style: GoogleFonts.italiana(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFC9A77E),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text(
                      "Set as Primary Branch",
                      style: AppTheme.sansBody(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    value: isPrimary,
                    activeColor: const Color(0xFFC9A77E),
                    onChanged: onPrimaryChanged,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _field("Branch Name *", nameCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Business Hours", hoursCtrl)),
                    ],
                  ),
                  _field("Office Address *", addressCtrl),
                  Row(
                    children: [
                      Expanded(child: _field("City *", cityCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("State *", stateCtrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field("Country *", countryCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Pincode", pinCtrl)),
                    ],
                  ),
                  _field("Google Maps URL", mapCtrl),
                  Row(
                    children: [
                      Expanded(child: _field("Latitude", latCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Longitude", lngCtrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field("Primary Contact *", phone1Ctrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Secondary Contact", phone2Ctrl)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: _field("WhatsApp Number", whatsappCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("Email Address", emailCtrl)),
                    ],
                  ),
                  _field("Instagram URL", instaCtrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
