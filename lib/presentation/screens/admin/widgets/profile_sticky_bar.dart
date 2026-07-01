import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';

/// Sticky bottom warning bar to prompt administrators to save or discard profile changes.
class ProfileStickyBar extends StatelessWidget {
  /// Authentication controller.
  final AuthController authController;

  /// Callback action to save changes.
  final VoidCallback saveProfile;

  /// Callback action to discard changes.
  final VoidCallback onDiscard;

  /// Creates a [ProfileStickyBar] widget instance.
  const ProfileStickyBar({
    super.key,
    required this.authController,
    required this.saveProfile,
    required this.onDiscard,
  });

  TextStyle _muted({double size = 12}) {
    return GoogleFonts.dmSans(fontSize: size, color: const Color(0xFFA4A9A7));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1D19),
        border: Border(top: BorderSide(color: Color(0xFF1E3028))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_note_rounded,
            size: 16,
            color: Color(0xFFC8A26A),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('You have unsaved changes', style: _muted())),
          OutlinedButton(
            onPressed: onDiscard,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF254235)),
              foregroundColor: const Color(0xFFA4A9A7),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Discard'),
          ),
          const SizedBox(width: 12),
          Obx(
            () => ElevatedButton(
              onPressed:
                  authController.isProfileSaving.value ? null : saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC8A26A),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child:
                  authController.isProfileSaving.value
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        'Save Changes',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
