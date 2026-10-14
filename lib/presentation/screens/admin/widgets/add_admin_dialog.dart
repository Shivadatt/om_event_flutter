import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../domain/entities/admin_role.dart';
import '../../../controllers/admin_controller.dart';
import '../../../controllers/auth_controller.dart';

/// Dialog to add a new administrator role configuration matching Option 4 luxury theme.
class AddAdminDialog extends StatefulWidget {
  /// The controller used to save the created role.
  final AdminController controller;

  /// Creates a [AddAdminDialog] instance.
  const AddAdminDialog({super.key, required this.controller});

  @override
  State<AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<AddAdminDialog> {
  final _uidCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _selectedRoleType = 'demo_admin';

  static const Color _goldColor = Color(0xFFD4AF37);
  static const Color _bgCard = Color(0xFF0F1B16);
  static const Color _inputBg = Color(0xFF070E0B);

  final Map<String, bool> _defaultPermissions = {
    'can_manage_categories': true,
    'can_manage_items': true,
    'can_manage_customers': true,
    'can_manage_users': false,
    'can_manage_reviews': true,
    'can_manage_quotes': true,
    'can_manage_leads': true,
    'can_manage_settings': false,
    'can_create': true,
    'can_edit': true,
    'can_delete': false,
  };

  @override
  void dispose() {
    _uidCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: _goldColor.withValues(alpha: 0.85),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: _goldColor.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
                    color: Colors.white,
                  ),
                  cursorColor: _goldColor,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white30,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _goldColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _goldColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _goldColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: _goldColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ADD ADMIN PROFILE",
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Grant administration credentials and privileges",
                          style: GoogleFonts.dmSans(
                            fontSize: 10.5,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: Colors.white54),
                    onPressed: () => Get.back(),
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildField(
                controller: _uidCtrl,
                label: "Firebase User UID",
                hint: "e.g. 5xX8yZ... (Auth UID)",
                icon: Icons.fingerprint_rounded,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _nameCtrl,
                label: "Full Name",
                hint: "e.g. Demo Admin",
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _emailCtrl,
                label: "Email Address",
                hint: "admin@gmail.com",
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 12),

              // Role Dropdown
              Text(
                "ROLE TYPE",
                style: GoogleFonts.dmSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: _goldColor.withValues(alpha: 0.85),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRoleType,
                    isExpanded: true,
                    dropdownColor: _bgCard,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: _goldColor, size: 20),
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      color: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text("Super Admin (Full Access)"),
                      ),
                      DropdownMenuItem(
                        value: 'demo_admin',
                        child: Text("Demo Admin (Restricted)"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedRoleType = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.dmSans(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldColor,
                      foregroundColor: const Color(0xFF0B140E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Create Profile",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      if (_uidCtrl.text.isEmpty ||
                          _nameCtrl.text.isEmpty ||
                          _emailCtrl.text.isEmpty) {
                        Get.snackbar(
                          "Validation Error",
                          "All fields are required.",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF2A1010),
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final newAdmin = AdminRole(
                        uid: _uidCtrl.text.trim(),
                        name: _nameCtrl.text.trim(),
                        email: _emailCtrl.text.trim(),
                        role: 'admin',
                        isActive: true,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        createdBy: Get.find<AuthController>()
                                .rxAdminRole
                                .value
                                ?.uid ??
                            'system',
                        roleType: _selectedRoleType,
                        permissions: _defaultPermissions,
                      );

                      Get.back();
                      widget.controller.saveAdminRole(newAdmin, isEdit: false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

