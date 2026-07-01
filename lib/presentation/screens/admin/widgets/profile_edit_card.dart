import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/auth_controller.dart';

/// Card component to edit user profile details inside ProfileScreen.
class ProfileEditCard extends StatelessWidget {
  /// The active admin role profile.
  final AdminRole admin;

  /// Whether the logged-in administrator is a super admin.
  final bool isSuperAdmin;

  /// Input controller for Name.
  final TextEditingController nameCtrl;

  /// Input controller for Phone.
  final TextEditingController phoneCtrl;

  /// Input controller for Designation.
  final TextEditingController designationCtrl;

  /// Input controller for Bio.
  final TextEditingController bioCtrl;

  /// Input controller for Address.
  final TextEditingController addressCtrl;

  /// Validation key for profile update form.
  final GlobalKey<FormState> profileFormKey;

  /// Authentication controller handler.
  final AuthController authController;

  /// Callback action to save updated details.
  final VoidCallback saveProfile;

  /// Callback action to discard changes and reset fields.
  final VoidCallback onReset;

  /// Creates a [ProfileEditCard] widget instance.
  const ProfileEditCard({
    super.key,
    required this.admin,
    required this.isSuperAdmin,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.designationCtrl,
    required this.bioCtrl,
    required this.addressCtrl,
    required this.profileFormKey,
    required this.authController,
    required this.saveProfile,
    required this.onReset,
  });

  TextStyle _label({
    Color color = const Color(0xFFA4A9A7),
    double size = 9,
    double spacing = 1.5,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: spacing,
    );
  }

  TextStyle _muted({double size = 12}) {
    return GoogleFonts.dmSans(fontSize: size, color: const Color(0xFFA4A9A7));
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFC8A26A)),
        const SizedBox(width: 10),
        Text(title, style: _label(color: const Color(0xFFC8A26A), size: 10)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162822),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF254235)),
      ),
      child: child,
    );
  }

  Widget _formField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: _label(size: 9)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _muted(size: 13),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF4A7060)),
            filled: true,
            fillColor: const Color(0xFF0D1915),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            counterText: "",
          ),
        ),
      ],
    );
  }

  Widget _readonlyTile({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1915),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A7060)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: _label(color: const Color(0xFF4A7060), size: 8),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: valueColor ?? Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Form(
        key: profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('PROFILE INFORMATION', Icons.person_outline_rounded),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (ctx, c) {
                if (c.maxWidth > 500) {
                  return Row(
                    children: [
                      Expanded(
                        child: _formField(
                          label: 'Display Name',
                          icon: Icons.person_outline,
                          controller: nameCtrl,
                          enabled: isSuperAdmin,
                          validator:
                              (v) =>
                                  v == null || v.trim().isEmpty
                                      ? 'Name is required'
                                      : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _formField(
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          controller: phoneCtrl,
                          enabled: isSuperAdmin,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            return RegExp(
                                  r'^[6-9]\d{9}$',
                                ).hasMatch(v.replaceAll(RegExp(r'[\s\-+]'), ''))
                                ? null
                                : 'Enter a valid Indian mobile number';
                          },
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _formField(
                      label: 'Display Name',
                      icon: Icons.person_outline,
                      controller: nameCtrl,
                      enabled: isSuperAdmin,
                      validator:
                          (v) =>
                              v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    _formField(
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      controller: phoneCtrl,
                      enabled: isSuperAdmin,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _formField(
              label: 'Designation',
              icon: Icons.work_outline_rounded,
              controller: designationCtrl,
              enabled: isSuperAdmin,
              hint: 'e.g. Lead Administrator',
            ),
            const SizedBox(height: 16),
            _formField(
              label: 'Bio',
              icon: Icons.notes_outlined,
              controller: bioCtrl,
              enabled: isSuperAdmin,
              maxLines: 4,
              maxLength: 500,
              hint: 'Write a short bio about yourself...',
            ),
            const SizedBox(height: 16),
            _formField(
              label: 'Address',
              icon: Icons.location_on_outlined,
              controller: addressCtrl,
              enabled: isSuperAdmin,
              maxLines: 2,
              hint: 'Your office or studio address',
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF1E3028)),
            const SizedBox(height: 20),
            Text(
              'READ-ONLY FIELDS',
              style: _label(color: const Color(0xFF4A7060)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _readonlyTile(
                    label: 'Email Address',
                    value: admin.email,
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _readonlyTile(
                    label: 'Role Type',
                    value: admin.roleType.replaceAll('_', ' ').toUpperCase(),
                    icon: Icons.shield_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _readonlyTile(
              label: 'Account Status',
              value: admin.isActive ? 'Active & Verified' : 'Deactivated',
              icon: Icons.check_circle_outline_rounded,
              valueColor:
                  admin.isActive ? const Color(0xFF3BA776) : Colors.redAccent,
            ),
            if (!isSuperAdmin) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: Color(0xFF4A7060),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Only Super Admins can edit profile information.',
                    style: _muted(size: 11),
                  ),
                ],
              ),
            ],
            if (isSuperAdmin) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReset,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF254235)),
                        foregroundColor: const Color(0xFFA4A9A7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed:
                            authController.isProfileSaving.value
                                ? null
                                : saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8A26A),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            authController.isProfileSaving.value
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Save Changes',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
