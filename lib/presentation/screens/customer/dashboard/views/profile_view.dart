import 'package:flutter/material.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// User bio details profile edit panel.
class ProfileView extends StatefulWidget {
  final CustomerDashboardController controller;

  const ProfileView({
    super.key,
    required this.controller,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController pincodeCtrl;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.rxProfile.value!;
    nameCtrl = TextEditingController(text: profile.fullName);
    phoneCtrl = TextEditingController(text: profile.phone);
    emailCtrl = TextEditingController(text: profile.email);
    addressCtrl = TextEditingController(text: profile.address);
    cityCtrl = TextEditingController(text: profile.city);
    stateCtrl = TextEditingController(text: profile.state);
    pincodeCtrl = TextEditingController(text: profile.pincode);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.controller.rxProfile.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Profile Settings", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 24),
          _buildProfileField("Full Name", nameCtrl),
          const SizedBox(height: 16),
          _buildProfileField("Phone Number", phoneCtrl),
          const SizedBox(height: 16),
          _buildProfileField("Email Address", emailCtrl, enabled: false),
          const SizedBox(height: 16),
          _buildProfileField("Address", addressCtrl),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildProfileField("City", cityCtrl)),
              const SizedBox(width: 16),
              Expanded(child: _buildProfileField("State", stateCtrl)),
            ],
          ),
          const SizedBox(height: 16),
          _buildProfileField("Pincode", pincodeCtrl),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9A77E),
              foregroundColor: const Color(0xFF091210),
              minimumSize: const Size(200, 50),
            ),
            onPressed: () {
              widget.controller.updateProfile(
                fullName: nameCtrl.text,
                phone: phoneCtrl.text,
                email: emailCtrl.text,
                gender: profile.gender,
                address: addressCtrl.text,
                city: cityCtrl.text,
                state: stateCtrl.text,
                pincode: pincodeCtrl.text,
                branch: profile.branch,
                profileImageUrl: profile.profileImageUrl,
              );
            },
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFC9A77E)),
        filled: true,
        fillColor: Colors.black12,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFC9A77E))),
      ),
    );
  }
}
