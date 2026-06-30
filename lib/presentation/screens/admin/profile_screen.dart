// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../../domain/entities/admin_role.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final AuthController _authController = Get.find<AuthController>();

  // Profile form controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _designationCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  // Password form controllers
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  // Form keys
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();

  // State
  bool _showCurrentPass = false;
  bool _showNewPass = false;
  bool _showConfirmPass = false;
  bool _hasChanges = false;
  bool _isUploadingPhoto = false;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.transparent;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ─── LIFECYCLE ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadAdminData();
    _newPassCtrl.addListener(_updatePasswordStrength);
  }

  void _loadAdminData() {
    final admin = _authController.rxAdminRole.value;
    if (admin != null) {
      _nameCtrl.text = admin.name;
      _phoneCtrl.text = admin.phone;
      _designationCtrl.text = admin.designation;
      _bioCtrl.text = admin.bio;
      _addressCtrl.text = admin.address;
    }
    for (final c in [_nameCtrl, _phoneCtrl, _designationCtrl, _bioCtrl, _addressCtrl]) {
      c.addListener(() {
        if (mounted) setState(() => _hasChanges = true);
      });
    }
  }

  void _updatePasswordStrength() {
    final pass = _newPassCtrl.text;
    if (pass.isEmpty) {
      setState(() { _passwordStrength = ''; _passwordStrengthColor = Colors.transparent; });
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
      Colors.transparent, Colors.red, Colors.orange,
      Colors.amber, const Color(0xFF3BA776), const Color(0xFF2ACA8A),
    ];
    setState(() {
      _passwordStrength = score > 0 ? labels[score] : '';
      _passwordStrengthColor = colors[score];
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in [_nameCtrl, _phoneCtrl, _designationCtrl, _bioCtrl, _addressCtrl,
        _currentPassCtrl, _newPassCtrl, _confirmPassCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── ACTIONS ─────────────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    final success = await _authController.updateProfileFields(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      designation: _designationCtrl.text,
      bio: _bioCtrl.text,
      address: _addressCtrl.text,
    );
    if (success && mounted) {
      setState(() => _hasChanges = false);
      Get.snackbar('Profile Saved', 'Your profile has been updated.',
          backgroundColor: const Color(0xFF0D2B1F), colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _changePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    final success = await _authController.changePassword(
      currentPassword: _currentPassCtrl.text,
      newPassword: _newPassCtrl.text,
    );
    if (success && mounted) {
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF162822),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile Photo', style: _serifStyle(size: 18)),
              const SizedBox(height: 4),
              Text('Manage your profile image', style: _muted(size: 12)),
              const SizedBox(height: 20),
              ListTile(
                leading: _iconBox(Icons.cloud_upload_outlined, const Color(0xFFC8A26A)),
                title: Text('Upload New Photo', style: _body()),
                subtitle: Text('JPG, PNG, WebP — max 2 MB', style: _muted(size: 11)),
                onTap: () { Navigator.pop(ctx); Get.snackbar('Info', 'File upload requires native file picker integration.'); },
              ),
              ListTile(
                leading: _iconBox(Icons.delete_outline, Colors.redAccent),
                title: Text('Remove Photo', style: _body()),
                subtitle: Text('Revert to default avatar', style: _muted(size: 11)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _removePhoto();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removePhoto() async {
    final admin = _authController.rxAdminRole.value;
    if (admin == null) return;
    try {
      setState(() => _isUploadingPhoto = true);
      await _authController.updateProfilePhotoUrl('');
      Get.snackbar('Photo Removed', 'Profile photo has been removed.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Unknown';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  int _calcCompletion(AdminRole admin) {
    int s = 0;
    if (admin.name.isNotEmpty) s++;
    if (admin.email.isNotEmpty) s++;
    if (admin.phone.isNotEmpty) s++;
    if (admin.designation.isNotEmpty) s++;
    if (admin.bio.isNotEmpty) s++;
    if (admin.address.isNotEmpty) s++;
    if (admin.photoUrl.isNotEmpty) s++;
    return ((s / 7) * 100).round();
  }

  // ─── TEXT STYLES ─────────────────────────────────────────────────────────────

  TextStyle _label({Color color = const Color(0xFFC8A26A), double size = 11, double spacing = 0.5}) {
    return GoogleFonts.dmSans(fontSize: size, fontWeight: FontWeight.w600, color: color, letterSpacing: spacing);
  }

  TextStyle _muted({double size = 12}) {
    return GoogleFonts.dmSans(fontSize: size, color: const Color(0xFF7A8F85));
  }

  TextStyle _body({double size = 13}) {
    return GoogleFonts.dmSans(fontSize: size, color: const Color(0xFFF0F0EE), fontWeight: FontWeight.w500);
  }

  TextStyle _serifStyle({double size = 22}) {
    return AppTheme.serifHeader(fontSize: size, fontWeight: FontWeight.bold, color: const Color(0xFFF0F0EE));
  }

  // ─── COMPONENT HELPERS ───────────────────────────────────────────────────────

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111E1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3028), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFC8A26A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFFC8A26A)),
        ),
        const SizedBox(width: 12),
        Text(title, style: _label(size: 12, spacing: 1.5)),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4A7060)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _label(size: 10, color: const Color(0xFF7A8F85))),
              const SizedBox(height: 2),
              Text(value, style: _body(size: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _readonlyTile({required String label, required String value, required IconData icon, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1512),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF141F1C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF3A5048)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _muted(size: 11)),
                const SizedBox(height: 4),
                Text(value, style: _body(size: 13).copyWith(color: valueColor ?? const Color(0xFF6A7A72)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 12, color: Color(0xFF2A3A34)),
        ],
      ),
    );
  }

  Widget _formField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    int maxLines = 1,
    int? maxLength,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.dmSans(color: enabled ? const Color(0xFFF0F0EE) : const Color(0xFF6A7A72), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF4A7060)),
        labelStyle: GoogleFonts.dmSans(color: const Color(0xFF7A8F85), fontSize: 13),
        hintStyle: GoogleFonts.dmSans(color: const Color(0xFF3A4E47), fontSize: 13),
        counterStyle: GoogleFonts.dmSans(color: const Color(0xFF4A7060), fontSize: 10),
        filled: true,
        fillColor: enabled ? const Color(0xFF0D1915) : const Color(0xFF0A1512),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3028))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC8A26A), width: 1.5)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF141F1C))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _passField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: GoogleFonts.dmSans(color: const Color(0xFFF0F0EE), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF4A7060)),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF4A7060)),
          onPressed: onToggle,
        ),
        labelStyle: GoogleFonts.dmSans(color: const Color(0xFF7A8F85), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF0D1915),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E3028))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFC8A26A), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final admin = _authController.rxAdminRole.value;
      final isSuperAdmin = admin?.roleType == 'super_admin';

      return Scaffold(
        backgroundColor: const Color(0xFF0B1714),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHeader(admin),
              Expanded(
                child: admin == null
                    ? _buildSkeleton()
                    : _buildBody(admin, isSuperAdmin),
              ),
            ],
          ),
        ),
        bottomNavigationBar: (isSuperAdmin && _hasChanges)
            ? _buildStickyBar()
            : null,
      );
    });
  }

  Widget _buildHeader(AdminRole? admin) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1D19),
        border: Border(bottom: BorderSide(color: Color(0xFF1E3028), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF162822),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF254235)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFFC8A26A)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Profile', style: _serifStyle(size: 22)),
                const SizedBox(height: 2),
                Text('Manage your administrator account', style: _muted()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2218),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1B4A2C)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(color: Color(0xFF3BA776), shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('Online', style: _label(color: const Color(0xFF3BA776), size: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminRole admin, bool isSuperAdmin) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final isWide = c.maxWidth > 900;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      _buildHeroCard(admin, isSuperAdmin),
                      const SizedBox(height: 20),
                      _buildSecurityCard(admin),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildEditCard(admin, isSuperAdmin),
                      const SizedBox(height: 20),
                      if (isSuperAdmin) _buildPasswordCard(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _buildHeroCard(admin, isSuperAdmin),
              const SizedBox(height: 20),
              _buildEditCard(admin, isSuperAdmin),
              const SizedBox(height: 20),
              if (isSuperAdmin) _buildPasswordCard(),
              const SizedBox(height: 20),
              _buildSecurityCard(admin),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(AdminRole admin, bool isSuperAdmin) {
    final completion = _calcCompletion(admin);
    final photoUrl = admin.photoUrl;

    return _card(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC8A26A), width: 2.5),
                  boxShadow: [BoxShadow(color: const Color(0xFFC8A26A).withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 4)],
                ),
                child: ClipOval(
                  child: _isUploadingPhoto
                      ? Container(
                          color: const Color(0xFF0D1915),
                          child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFC8A26A)), strokeWidth: 2.5)),
                        )
                      : photoUrl.isNotEmpty
                          ? Image.network(photoUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarFallback(admin.name))
                          : _avatarFallback(admin.name),
                ),
              ),
              if (isSuperAdmin)
                Positioned(
                  bottom: 4, right: 4,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _showPhotoOptions,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8A26A),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0B1714), width: 2.5),
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF0B1714)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            admin.name.isNotEmpty ? admin.name : 'Administrator',
            style: _serifStyle(size: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          if (admin.designation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(admin.designation, style: _muted(size: 13), textAlign: TextAlign.center),
            ),
          _roleBadge(admin),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF1E3028), height: 1),
          const SizedBox(height: 20),
          _infoRow(Icons.email_outlined, 'Email', admin.email),
          if (admin.phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.phone_outlined, 'Phone', admin.phone),
          ],
          const SizedBox(height: 12),
          _infoRow(Icons.calendar_today_outlined, 'Member Since', _formatDate(admin.createdAt)),
          if (admin.lastLogin != null) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.access_time_rounded, 'Last Login', _formatDate(admin.lastLogin)),
          ],
          const SizedBox(height: 24),
          _completionMeter(completion),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: const Color(0xFF0D1915),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: AppTheme.serifHeader(fontSize: 44, fontWeight: FontWeight.bold, color: const Color(0xFFC8A26A)),
        ),
      ),
    );
  }

  Widget _roleBadge(AdminRole admin) {
    final isSuper = admin.roleType == 'super_admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSuper ? const Color(0xFFC8A26A).withValues(alpha: 0.12) : const Color(0xFF254235).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSuper ? const Color(0xFFC8A26A).withValues(alpha: 0.35) : const Color(0xFF254235),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSuper ? Icons.verified_rounded : Icons.admin_panel_settings_outlined,
              size: 13, color: isSuper ? const Color(0xFFC8A26A) : const Color(0xFF7A9B8A)),
          const SizedBox(width: 6),
          Text(admin.roleType.replaceAll('_', ' ').toUpperCase(),
              style: _label(color: isSuper ? const Color(0xFFC8A26A) : const Color(0xFF7A9B8A), size: 10, spacing: 1.2)),
        ],
      ),
    );
  }

  Widget _completionMeter(int completion) {
    final meterColor = completion >= 80 ? const Color(0xFF3BA776)
        : completion >= 50 ? const Color(0xFFC8A26A) : Colors.redAccent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PROFILE COMPLETION', style: _label()),
            Text('$completion%', style: _label(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: completion / 100,
            backgroundColor: const Color(0xFF1E3028),
            valueColor: AlwaysStoppedAnimation<Color>(meterColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          completion >= 80 ? 'Great! Your profile is almost complete.' : 'Fill more details to complete your profile.',
          style: _muted(size: 11),
        ),
      ],
    );
  }

  Widget _buildEditCard(AdminRole admin, bool isSuperAdmin) {
    return _card(
      child: Form(
        key: _profileFormKey,
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
                      Expanded(child: _formField(
                        label: 'Display Name', icon: Icons.person_outline, controller: _nameCtrl,
                        enabled: isSuperAdmin,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _formField(
                        label: 'Phone Number', icon: Icons.phone_outlined, controller: _phoneCtrl,
                        enabled: isSuperAdmin, keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          return RegExp(r'^[6-9]\d{9}$').hasMatch(v.replaceAll(RegExp(r'[\s\-+]'), ''))
                              ? null : 'Enter a valid Indian mobile number';
                        },
                      )),
                    ],
                  );
                }
                return Column(children: [
                  _formField(label: 'Display Name', icon: Icons.person_outline, controller: _nameCtrl, enabled: isSuperAdmin,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                  const SizedBox(height: 16),
                  _formField(label: 'Phone Number', icon: Icons.phone_outlined, controller: _phoneCtrl, enabled: isSuperAdmin),
                ]);
              },
            ),
            const SizedBox(height: 16),
            _formField(
              label: 'Designation', icon: Icons.work_outline_rounded, controller: _designationCtrl,
              enabled: isSuperAdmin, hint: 'e.g. Lead Administrator',
            ),
            const SizedBox(height: 16),
            _formField(
              label: 'Bio', icon: Icons.notes_outlined, controller: _bioCtrl,
              enabled: isSuperAdmin, maxLines: 4, maxLength: 500,
              hint: 'Write a short bio about yourself...',
            ),
            const SizedBox(height: 16),
            _formField(
              label: 'Address', icon: Icons.location_on_outlined, controller: _addressCtrl,
              enabled: isSuperAdmin, maxLines: 2, hint: 'Your office or studio address',
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF1E3028)),
            const SizedBox(height: 20),
            Text('READ-ONLY FIELDS', style: _label(color: const Color(0xFF4A7060))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _readonlyTile(label: 'Email Address', value: admin.email, icon: Icons.email_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _readonlyTile(label: 'Role Type', value: admin.roleType.replaceAll('_', ' ').toUpperCase(), icon: Icons.shield_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            _readonlyTile(
              label: 'Account Status', value: admin.isActive ? 'Active & Verified' : 'Deactivated',
              icon: Icons.check_circle_outline_rounded,
              valueColor: admin.isActive ? const Color(0xFF3BA776) : Colors.redAccent,
            ),
            if (!isSuperAdmin) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Color(0xFF4A7060)),
                  const SizedBox(width: 8),
                  Text('Only Super Admins can edit profile information.', style: _muted(size: 11)),
                ],
              ),
            ],
            if (isSuperAdmin) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () { _loadAdminData(); setState(() => _hasChanges = false); },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF254235)),
                      foregroundColor: const Color(0xFFA4A9A7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset'),
                  )),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: Obx(() => ElevatedButton(
                    onPressed: _authController.isProfileSaving.value ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8A26A), foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _authController.isProfileSaving.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text('Save Changes', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14)),
                  ))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordCard() {
    return _card(
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('SECURITY', Icons.lock_outline_rounded),
            const SizedBox(height: 8),
            Text('Update your password. Enter your current password to confirm.', style: _muted()),
            const SizedBox(height: 24),
            _passField(
              label: 'Current Password', controller: _currentPassCtrl,
              isVisible: _showCurrentPass, onToggle: () => setState(() => _showCurrentPass = !_showCurrentPass),
              validator: (v) => v == null || v.isEmpty ? 'Enter your current password' : null,
            ),
            const SizedBox(height: 16),
            _passField(
              label: 'New Password', controller: _newPassCtrl,
              isVisible: _showNewPass, onToggle: () => setState(() => _showNewPass = !_showNewPass),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a new password';
                if (v.length < 8) return 'Minimum 8 characters required';
                if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Must include uppercase letter';
                if (!RegExp(r'[a-z]').hasMatch(v)) return 'Must include lowercase letter';
                if (!RegExp(r'[0-9]').hasMatch(v)) return 'Must include a number';
                if (!RegExp(r'[!@#\$%^&*()_+\-=]').hasMatch(v)) return 'Must include special character';
                return null;
              },
            ),
            const SizedBox(height: 8),
            if (_passwordStrength.isNotEmpty) ...[
              Row(
                children: List.generate(5, (i) {
                  final filledCount = ['Very Weak','Weak','Fair','Good','Strong'].indexOf(_passwordStrength) + 1;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i < filledCount ? _passwordStrengthColor : const Color(0xFF1E3028),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text('Strength: $_passwordStrength', style: _label(color: _passwordStrengthColor, size: 11)),
            ],
            const SizedBox(height: 16),
            _passField(
              label: 'Confirm New Password', controller: _confirmPassCtrl,
              isVisible: _showConfirmPass, onToggle: () => setState(() => _showConfirmPass = !_showConfirmPass),
              validator: (v) => v != _newPassCtrl.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: _authController.isPasswordChanging.value ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162822), foregroundColor: const Color(0xFFF0F0EE),
                side: const BorderSide(color: Color(0xFF254235)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _authController.isPasswordChanging.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFC8A26A), strokeWidth: 2))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.lock_reset_rounded, size: 18, color: Color(0xFFC8A26A)),
                      const SizedBox(width: 10),
                      Text('Update Password', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(AdminRole admin) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ACCOUNT DETAILS', Icons.info_outline_rounded),
          const SizedBox(height: 20),
          _secRow('UID', '${admin.uid.substring(0, 12)}...'),
          const Divider(color: Color(0xFF1A2E25), height: 1),
          _secRow('Role Type', admin.roleType.replaceAll('_', ' ').toUpperCase()),
          const Divider(color: Color(0xFF1A2E25), height: 1),
          _secRow('Status', admin.isActive ? 'Active' : 'Disabled',
              valueColor: admin.isActive ? const Color(0xFF3BA776) : Colors.redAccent),
          const Divider(color: Color(0xFF1A2E25), height: 1),
          _secRow('Created', _formatDate(admin.createdAt)),
          if (admin.lastLogin != null) ...[
            const Divider(color: Color(0xFF1A2E25), height: 1),
            _secRow('Last Login', _formatDate(admin.lastLogin)),
          ],
          const SizedBox(height: 20),
          Text('PERMISSIONS', style: _label()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              if (admin.roleType == 'super_admin')
                _permChip('All Permissions', isSuper: true)
              else
                ...admin.permissions.entries.where((e) => e.value).map((e) => _permChip(e.key)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _secRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: _muted()),
          Text(value, style: _body(size: 12).copyWith(color: valueColor)),
        ],
      ),
    );
  }

  Widget _permChip(String label, {bool isSuper = false}) {
    final text = label.replaceAll('can_', '').replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSuper ? const Color(0xFFC8A26A).withValues(alpha: 0.1) : const Color(0xFF0D2218),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isSuper ? const Color(0xFFC8A26A).withValues(alpha: 0.3) : const Color(0xFF1B3828)),
      ),
      child: Text(text, style: _label(color: isSuper ? const Color(0xFFC8A26A) : const Color(0xFF5A9070), size: 10)),
    );
  }

  Widget _buildStickyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1D19),
        border: Border(top: BorderSide(color: Color(0xFF1E3028))),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFFC8A26A)),
          const SizedBox(width: 8),
          Expanded(child: Text('You have unsaved changes', style: _muted())),
          OutlinedButton(
            onPressed: () { _loadAdminData(); setState(() => _hasChanges = false); },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF254235)),
              foregroundColor: const Color(0xFFA4A9A7),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Discard'),
          ),
          const SizedBox(width: 12),
          Obx(() => ElevatedButton(
            onPressed: _authController.isProfileSaving.value ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8A26A), foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _authController.isProfileSaving.value
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : Text('Save Changes', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13)),
          )),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _card(
            child: Column(
              children: List.generate(4, (j) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(height: j == 0 ? 80.0 : 24.0,
                    decoration: BoxDecoration(color: const Color(0xFF162822), borderRadius: BorderRadius.circular(j == 0 ? 40 : 6))),
              )),
            ),
          ),
        )),
      ),
    );
  }
}
