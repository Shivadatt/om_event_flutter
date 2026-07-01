// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../controllers/auth_controller.dart';
import '../../../domain/entities/admin_role.dart';
import 'widgets/profile_edit_card.dart';
import 'widgets/profile_password_card.dart';
import 'widgets/profile_security_card.dart';
import 'widgets/profile_sticky_bar.dart';
import 'widgets/profile_skeleton.dart';
import 'widgets/profile_photo_sheet.dart';
import 'widgets/profile_hero_card.dart';

/// Main administrator profile settings screen.
class ProfileScreen extends StatefulWidget {
  /// Creates a [ProfileScreen] instance.
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
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
  bool _hasChanges = false;
  bool _isUploadingPhoto = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadAdminData();
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
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _designationCtrl,
      _bioCtrl,
      _addressCtrl,
    ]) {
      c.addListener(() {
        if (mounted) setState(() => _hasChanges = true);
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _designationCtrl,
      _bioCtrl,
      _addressCtrl,
      _currentPassCtrl,
      _newPassCtrl,
      _confirmPassCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

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
      Get.snackbar(
        'Profile Saved',
        'Your profile has been updated.',
        backgroundColor: const Color(0xFF0D2B1F),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
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
      builder:
          (ctx) => ProfilePhotoSheet(
            hasAvatar:
                _authController.rxAdminRole.value?.photoUrl.isNotEmpty ?? false,
            onPick: (isGallery) {
              if (isGallery) {
                Get.snackbar(
                  'Info',
                  'File upload requires native file picker integration.',
                );
              } else {
                Get.snackbar(
                  'Info',
                  'Camera captures require native device camera integrations.',
                );
              }
            },
            onRemove: _removePhoto,
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
              _buildHeader(),
              Expanded(
                child:
                    admin == null
                        ? const ProfileSkeleton()
                        : _buildBody(admin, isSuperAdmin),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            (isSuperAdmin && _hasChanges)
                ? ProfileStickyBar(
                  authController: _authController,
                  saveProfile: _saveProfile,
                  onDiscard: () {
                    _loadAdminData();
                    setState(() => _hasChanges = false);
                  },
                )
                : null,
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1D19),
        border: Border(bottom: BorderSide(color: Color(0xFF1E3028), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          InkWell(
            onTap: () => NavigationHelper.safeBack(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF162822),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF254235)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Color(0xFFC8A26A),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: AppTheme.serifHeader(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0F0EE),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your administrator account',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: const Color(0xFF7A8F85),
                  ),
                ),
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
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3BA776),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Online',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3BA776),
                    letterSpacing: 0.5,
                  ),
                ),
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
                      ProfileHeroCard(
                        admin: admin,
                        isSuperAdmin: isSuperAdmin,
                        isUploadingPhoto: _isUploadingPhoto,
                        onShowPhotoOptions: _showPhotoOptions,
                      ),
                      const SizedBox(height: 20),
                      ProfileSecurityCard(admin: admin),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      ProfileEditCard(
                        admin: admin,
                        isSuperAdmin: isSuperAdmin,
                        nameCtrl: _nameCtrl,
                        phoneCtrl: _phoneCtrl,
                        designationCtrl: _designationCtrl,
                        bioCtrl: _bioCtrl,
                        addressCtrl: _addressCtrl,
                        profileFormKey: _profileFormKey,
                        authController: _authController,
                        saveProfile: _saveProfile,
                        onReset: () {
                          _loadAdminData();
                          setState(() => _hasChanges = false);
                        },
                      ),
                      const SizedBox(height: 20),
                      if (isSuperAdmin)
                        ProfilePasswordCard(
                          passwordFormKey: _passwordFormKey,
                          currentPassCtrl: _currentPassCtrl,
                          newPassCtrl: _newPassCtrl,
                          confirmPassCtrl: _confirmPassCtrl,
                          authController: _authController,
                          changePassword: _changePassword,
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              ProfileHeroCard(
                admin: admin,
                isSuperAdmin: isSuperAdmin,
                isUploadingPhoto: _isUploadingPhoto,
                onShowPhotoOptions: _showPhotoOptions,
              ),
              const SizedBox(height: 20),
              ProfileEditCard(
                admin: admin,
                isSuperAdmin: isSuperAdmin,
                nameCtrl: _nameCtrl,
                phoneCtrl: _phoneCtrl,
                designationCtrl: _designationCtrl,
                bioCtrl: _bioCtrl,
                addressCtrl: _addressCtrl,
                profileFormKey: _profileFormKey,
                authController: _authController,
                saveProfile: _saveProfile,
                onReset: () {
                  _loadAdminData();
                  setState(() => _hasChanges = false);
                },
              ),
              const SizedBox(height: 20),
              if (isSuperAdmin)
                ProfilePasswordCard(
                  passwordFormKey: _passwordFormKey,
                  currentPassCtrl: _currentPassCtrl,
                  newPassCtrl: _newPassCtrl,
                  confirmPassCtrl: _confirmPassCtrl,
                  authController: _authController,
                  changePassword: _changePassword,
                ),
              const SizedBox(height: 20),
              ProfileSecurityCard(admin: admin),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
