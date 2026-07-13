import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      padding: const EdgeInsets.all(32),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "USER PREFERENCES",
                style: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.5),
              ),
              const SizedBox(height: 6),
              Text(
                "Lounge Profile Settings",
                style: GoogleFonts.italiana(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Main Profile Card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171411), // Ebony/Graphite card
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x1AD4AF37)),
              boxShadow: const [
                BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8)),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar Edit section
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFF2A241F),
                          backgroundImage: profile.profileImageUrl.isNotEmpty == true
                              ? CachedNetworkImageProvider(
                                  profile.profileImageUrl,
                                  maxWidth: 192, // 96 * 2 (radius 48 * 2 for pixel ratio)
                                  maxHeight: 192,
                                )
                              : null,
                          child: profile.profileImageUrl.isEmpty == true
                              ? const Icon(Icons.person_outline, size: 48, color: Color(0xFFD4AF37))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "PLATINUM LOUNGE MEMBER",
                        style: AppTheme.sansBody(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Fields Group 1: Personal Details
                Text(
                  "PERSONAL DETAILS",
                  style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildLuxuryField("Full Name", nameCtrl, Icons.person_outline)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildLuxuryField("Phone Number", phoneCtrl, Icons.phone_android_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLuxuryField("Email Address (Locked)", emailCtrl, Icons.email_outlined, enabled: false),

                const SizedBox(height: 32),

                // Fields Group 2: Event Logistics Address
                Text(
                  "EVENT LOGISTICS ADDRESS",
                  style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
                ),
                const SizedBox(height: 16),
                _buildLuxuryField("Billing / Delivery Address", addressCtrl, Icons.location_on_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildLuxuryField("City", cityCtrl, Icons.business_outlined)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildLuxuryField("State", stateCtrl, Icons.map_outlined)),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: _buildLuxuryField("Pincode", pincodeCtrl, Icons.pin_drop_outlined, isNumber: true)),
                  ],
                ),

                const SizedBox(height: 40),

                // Submit Button
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt_outlined, size: 16),
                    label: const Text("SAVE PROFILE CHANGES"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF091210),
                      minimumSize: const Size(260, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      elevation: 4,
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
                      Get.snackbar(
                        "Profile Updated",
                        "Your security and bio settings are now saved in Firestore.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF171411),
                        colorText: const Color(0xFFD4AF37),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryField(String label, TextEditingController ctrl, IconData icon, {bool enabled = true, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: enabled ? Colors.white : Colors.white30, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? const Color(0xFFD4AF37) : Colors.white24, size: 18),
            filled: true,
            fillColor: Colors.black26,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
      ],
    );
  }
}
