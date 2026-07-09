import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/auth_controller.dart';

/// Card component to update administrative user credentials inside ProfileScreen.
class ProfilePasswordCard extends StatefulWidget {
  /// Validation key for credential updates.
  final GlobalKey<FormState> passwordFormKey;

  /// Input controller for current password.
  final TextEditingController currentPassCtrl;

  /// Input controller for new password.
  final TextEditingController newPassCtrl;

  /// Input controller for confirm password.
  final TextEditingController confirmPassCtrl;

  /// Authentication controller.
  final AuthController authController;

  /// Callback action to trigger password updates.
  final VoidCallback changePassword;

  /// Creates a [ProfilePasswordCard] widget instance.
  const ProfilePasswordCard({
    super.key,
    required this.passwordFormKey,
    required this.currentPassCtrl,
    required this.newPassCtrl,
    required this.confirmPassCtrl,
    required this.authController,
    required this.changePassword,
  });

  @override
  State<ProfilePasswordCard> createState() => _ProfilePasswordCardState();
}

class _ProfilePasswordCardState extends State<ProfilePasswordCard> {
  bool _showCurrentPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    widget.newPassCtrl.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    widget.newPassCtrl.removeListener(_updatePasswordStrength);
    super.dispose();
  }

  void _updatePasswordStrength() {
    final pass = widget.newPassCtrl.text;
    if (pass.isEmpty) {
      if (mounted) {
        setState(() {
          _passwordStrength = '';
          _passwordStrengthColor = Colors.transparent;
        });
      }
      return;
    }
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[a-z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    if (RegExp(r'[!@#\$%^&*()_+\-=]').hasMatch(pass)) score++;

    final labels = ['', 'Very Weak', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      Colors.transparent,
      Colors.red,
      Colors.orange,
      Colors.amber,
      const Color(0xFF3BA776),
      const Color(0xFF2ACA8A),
    ];
    if (mounted) {
      setState(() {
        _passwordStrength = score > 0 ? labels[score] : '';
        _passwordStrengthColor = colors[score];
      });
    }
  }

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

  Widget _passField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: _label(size: 9)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.lock_outline,
              size: 18,
              color: Color(0xFF4A7060),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: const Color(0xFF4A7060),
              ),
              onPressed: onToggle,
            ),
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Form(
        key: widget.passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('SECURITY', Icons.lock_outline_rounded),
            const SizedBox(height: 8),
            Text(
              'Update your password. Enter your current password to confirm.',
              style: _muted(),
            ),
            const SizedBox(height: 24),
            _passField(
              label: 'Current Password',
              controller: widget.currentPassCtrl,
              isVisible: _showCurrentPass,
              onToggle:
                  () => setState(() => _showCurrentPass = !_showCurrentPass),
              validator:
                  (v) =>
                      v == null || v.isEmpty
                          ? 'Enter your current password'
                          : null,
            ),
            const SizedBox(height: 16),
            _passField(
              label: 'New Password',
              controller: widget.newPassCtrl,
              isVisible: _showNewPass,
              onToggle: () => setState(() => _showNewPass = !_showNewPass),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a new password';
                if (v.length < 8) return 'Minimum 8 characters required';
                if (!RegExp(r'[A-Z]').hasMatch(v)) {
                  return 'Must include uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(v)) {
                  return 'Must include lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(v)) {
                  return 'Must include a number';
                }
                if (!RegExp(r'[!@#\$%^&*()_+\-=]').hasMatch(v)) {
                  return 'Must include special character';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            if (_passwordStrength.isNotEmpty) ...[
              Row(
                children: List.generate(5, (i) {
                  final filledCount =
                      [
                        'Very Weak',
                        'Weak',
                        'Fair',
                        'Good',
                        'Strong',
                      ].indexOf(_passwordStrength) +
                      1;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      decoration: BoxDecoration(
                        color:
                            i < filledCount
                                ? _passwordStrengthColor
                                : const Color(0xFF1E3028),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                'Strength: $_passwordStrength',
                style: _label(color: _passwordStrengthColor, size: 11),
              ),
            ],
            const SizedBox(height: 16),
            _passField(
              label: 'Confirm New Password',
              controller: widget.confirmPassCtrl,
              isVisible: _showConfirmPass,
              onToggle:
                  () => setState(() => _showConfirmPass = !_showConfirmPass),
              validator:
                  (v) =>
                      v != widget.newPassCtrl.text
                          ? 'Passwords do not match'
                          : null,
            ),
            const SizedBox(height: 24),
            Obx(
              () => ElevatedButton(
                onPressed:
                    widget.authController.isPasswordChanging.value
                        ? null
                        : widget.changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162822),
                  foregroundColor: const Color(0xFFF0F0EE),
                  side: const BorderSide(color: Color(0xFF254235)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child:
                    widget.authController.isPasswordChanging.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0xFFC8A26A),
                            strokeWidth: 2,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_reset_rounded,
                              size: 18,
                              color: Color(0xFFC8A26A),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Update Password',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
