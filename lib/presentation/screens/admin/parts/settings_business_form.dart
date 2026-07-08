part of '../system_settings_screen.dart';

extension _SettingsBusinessFormExtension on _SystemSettingsScreenState {
  Widget _buildBusinessForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BUSINESS PROFILE", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Business Name *", _busName),
        _field("Company Name", _busCompany),
        _buildBusinessContactNumbers(),
        _field("General Support Email", _busEmail),
        const SizedBox(height: 32),
        Text(
          "OFFICE BRANCHES",
          style: GoogleFonts.italiana(
            fontSize: 20,
            color: const Color(0xFFC9A77E),
          ),
        ),
        const SizedBox(height: 16),
        _buildBranchCard(
          title:
              "Branch 1: ${_b1Name.text.isNotEmpty ? _b1Name.text : 'Main Office'}",
          nameCtrl: _b1Name,
          addressCtrl: _b1Address,
          cityCtrl: _b1City,
          stateCtrl: _b1State,
          countryCtrl: _b1Country,
          pinCtrl: _b1Pincode,
          mapCtrl: _b1MapUrl,
          latCtrl: _b1Lat,
          lngCtrl: _b1Lng,
          phone1Ctrl: _b1Phone1,
          phone2Ctrl: _b1Phone2,
          whatsappCtrl: _b1Whatsapp,
          emailCtrl: _b1Email,
          instaCtrl: _b1Instagram,
          hoursCtrl: _b1Hours,
          isPrimary: _b1IsPrimary,
          onPrimaryChanged: (val) {
            updateState(() {
              _b1IsPrimary = val;
              if (val) _b2IsPrimary = false;
            });
          },
        ),
        _buildBranchCard(
          title:
              "Branch 2: ${_b2Name.text.isNotEmpty ? _b2Name.text : 'Secondary Office'}",
          nameCtrl: _b2Name,
          addressCtrl: _b2Address,
          cityCtrl: _b2City,
          stateCtrl: _b2State,
          countryCtrl: _b2Country,
          pinCtrl: _b2Pincode,
          mapCtrl: _b2MapUrl,
          latCtrl: _b2Lat,
          lngCtrl: _b2Lng,
          phone1Ctrl: _b2Phone1,
          phone2Ctrl: _b2Phone2,
          whatsappCtrl: _b2Whatsapp,
          emailCtrl: _b2Email,
          instaCtrl: _b2Instagram,
          hoursCtrl: _b2Hours,
          isPrimary: _b2IsPrimary,
          onPrimaryChanged: (val) {
            updateState(() {
              _b2IsPrimary = val;
              if (val) _b1IsPrimary = false;
            });
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('business', () async {
                if (!_validateBranchInputs()) return;

                final updatedBranches = [
                  OfficeBranch(
                    id: "branch_1",
                    branchName: _b1Name.text,
                    address: _b1Address.text,
                    city: _b1City.text,
                    state: _b1State.text,
                    country: _b1Country.text,
                    pincode: _b1Pincode.text,
                    googleMapUrl: _b1MapUrl.text,
                    latitude: _b1Lat.text,
                    longitude: _b1Lng.text,
                    phone1: _b1Phone1.text,
                    phone2: _b1Phone2.text,
                    whatsapp: _b1Whatsapp.text,
                    email: _b1Email.text,
                    instagram: _b1Instagram.text,
                    businessHours: _b1Hours.text,
                    isPrimary: _b1IsPrimary,
                  ),
                  OfficeBranch(
                    id: "branch_2",
                    branchName: _b2Name.text,
                    address: _b2Address.text,
                    city: _b2City.text,
                    state: _b2State.text,
                    country: _b2Country.text,
                    pincode: _b2Pincode.text,
                    googleMapUrl: _b2MapUrl.text,
                    latitude: _b2Lat.text,
                    longitude: _b2Lng.text,
                    phone1: _b2Phone1.text,
                    phone2: _b2Phone2.text,
                    whatsapp: _b2Whatsapp.text,
                    email: _b2Email.text,
                    instagram: _b2Instagram.text,
                    businessHours: _b2Hours.text,
                    isPrimary: _b2IsPrimary,
                  ),
                ];

                if (_contactNumbers.isEmpty) {
                  Get.snackbar(
                    "Error",
                    "Add at least one business contact number",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                if (!_contactNumbers.any((c) => c.isPrimary && c.isActive)) {
                  Get.snackbar(
                    "Error",
                    "One active contact number must be marked as Primary",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                await _repository.saveBusiness(
                  BusinessProfile(
                    name: _busName.text,
                    companyName: _busCompany.text,
                    contactNumbers: _contactNumbers,
                    email: _busEmail.text,
                    officeBranches: updatedBranches,
                    socialLinks: {
                      'instagram_kadi': _socialInstagramKadi.text,
                      'instagram_thangadh': _socialInstagramThangadh.text,
                    },
                    logo: "",
                    whiteLogo: "",
                    favicon: "",
                    gst: "",
                    pan: "",
                    ownerName: "",
                    whatsapp: "",
                    workingHours: "",
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }
}
