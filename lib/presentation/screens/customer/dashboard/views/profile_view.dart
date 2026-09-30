import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../core/constants/app_branches.dart';
import '../../../../controllers/customer_dashboard_controller.dart';
import '../../../../../domain/entities/customer_profile.dart';

/// User bio details and event logistics address profile settings panel.
/// Full-Screen Modern Card Style with complete Supabase Storage profile picture integration:
/// - Single-layer input fields with golden borders and direct text placement.
/// - Interactive profile avatar with local preview, format/size validation, and camera badge.
/// - Uploads to Supabase Storage in the canonical 'profile' bucket upon "Save Profile Changes".
/// - Stores the resulting Supabase public URL into the canonical Firebase customer profile document.
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

  late FocusNode nameFocus;
  late FocusNode phoneFocus;
  late FocusNode addressFocus;
  late FocusNode cityFocus;
  late FocusNode stateFocus;
  late FocusNode pincodeFocus;

  Worker? _profileWorker;

  // Profile image local selection state (deferred upload)
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploadingPhoto = false;

  // Extended profile fields
  DateTime? _selectedDob;
  String _selectedGender = '';
  String _selectedBranch = '';

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.rxProfile.value;
    nameCtrl = TextEditingController(text: profile?.fullName ?? '');
    phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    emailCtrl = TextEditingController(text: profile?.email ?? '');
    addressCtrl = TextEditingController(text: profile?.address ?? '');
    cityCtrl = TextEditingController(text: profile?.city ?? '');
    stateCtrl = TextEditingController(text: profile?.state ?? '');
    pincodeCtrl = TextEditingController(text: profile?.pincode ?? '');
    _selectedDob = profile?.dateOfBirth;
    _selectedGender = profile?.gender ?? '';
    _selectedBranch = (profile?.branch != null && AppBranches.isValidBranch(profile!.branch))
        ? profile.branch
        : '';

    nameFocus = FocusNode();
    phoneFocus = FocusNode();
    addressFocus = FocusNode();
    cityFocus = FocusNode();
    stateFocus = FocusNode();
    pincodeFocus = FocusNode();

    // Synchronize text fields when profile data loads or updates asynchronously
    _profileWorker = ever(widget.controller.rxProfile, (latestProfile) {
      if (latestProfile != null && mounted) {
        if (!nameFocus.hasFocus && (nameCtrl.text.isEmpty || nameCtrl.text != latestProfile.fullName)) {
          nameCtrl.text = latestProfile.fullName;
        }
        if (!phoneFocus.hasFocus && (phoneCtrl.text.isEmpty || phoneCtrl.text != latestProfile.phone)) {
          phoneCtrl.text = latestProfile.phone;
        }
        if (emailCtrl.text.isEmpty || emailCtrl.text != latestProfile.email) {
          emailCtrl.text = latestProfile.email;
        }
        if (!addressFocus.hasFocus && (addressCtrl.text.isEmpty || addressCtrl.text != latestProfile.address)) {
          addressCtrl.text = latestProfile.address;
        }
        if (!cityFocus.hasFocus && (cityCtrl.text.isEmpty || cityCtrl.text != latestProfile.city)) {
          cityCtrl.text = latestProfile.city;
        }
        if (!stateFocus.hasFocus && (stateCtrl.text.isEmpty || stateCtrl.text != latestProfile.state)) {
          stateCtrl.text = latestProfile.state;
        }
        if (!pincodeFocus.hasFocus && (pincodeCtrl.text.isEmpty || pincodeCtrl.text != latestProfile.pincode)) {
          pincodeCtrl.text = latestProfile.pincode;
        }
        if (_selectedDob == null && latestProfile.dateOfBirth != null) {
          setState(() => _selectedDob = latestProfile.dateOfBirth);
        }
        if (_selectedGender.isEmpty && latestProfile.gender.isNotEmpty) {
          setState(() => _selectedGender = latestProfile.gender);
        }
        if (_selectedBranch.isEmpty && latestProfile.branch.isNotEmpty && AppBranches.isValidBranch(latestProfile.branch)) {
          setState(() => _selectedBranch = latestProfile.branch);
        }
      }
    });
  }

  @override
  void dispose() {
    _profileWorker?.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();

    nameFocus.dispose();
    phoneFocus.dispose();
    addressFocus.dispose();
    cityFocus.dispose();
    stateFocus.dispose();
    pincodeFocus.dispose();

    super.dispose();
  }

  /// Picks a new profile image, validates format/size, and sets local preview (no instant upload).
  Future<void> _pickProfileImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) {
          Get.snackbar("Error", "Could not read selected image file.");
          return;
        }

        // Validate file size (max 5 MB)
        if (file.size > 5 * 1024 * 1024) {
          Get.snackbar(
            "File Too Large",
            "Profile picture must be under 5 MB. Selected file is ${(file.size / (1024 * 1024)).toStringAsFixed(1)} MB.",
            backgroundColor: const Color(0xFF2D1515),
            colorText: const Color(0xFFE8CC8A),
          );
          return;
        }

        // Validate extension
        final ext = (file.extension ?? file.name.split('.').last).toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
          Get.snackbar(
            "Unsupported Format",
            "Please select a JPG, PNG, or WEBP image.",
            backgroundColor: const Color(0xFF2D1515),
            colorText: const Color(0xFFE8CC8A),
          );
          return;
        }

        setState(() {
          _selectedImageBytes = file.bytes;
          _selectedImageName = file.name;
        });

        Get.snackbar(
          "Photo Selected",
          "Click 'Save Profile Changes' below to upload and save your new avatar.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF101713),
          colorText: const Color(0xFFD4AF37),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Image Selection Error",
        "Could not select image: ${e.toString()}",
        backgroundColor: const Color(0xFF2D1515),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isDesktop = width >= 860;
        final bool isMobile = width < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 28,
            vertical: isMobile ? 14 : 20,
          ),
          physics: const BouncingScrollPhysics(),
          child: Obx(() {
            final profile = widget.controller.rxProfile.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── 1. Header Section: Title + Right-aligned Membership Badge ───
                _buildHeader(isMobile: isMobile, profile: profile),

                const SizedBox(height: 18),

                // ─── 2. Main Content: Two Full-Width Equal Columns ───
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildPersonalDetailsCard(profile),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildLogisticsAddressCard(),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildPersonalDetailsCard(profile),
                      const SizedBox(height: 16),
                      _buildLogisticsAddressCard(),
                    ],
                  ),

                const SizedBox(height: 16),

                // ─── 3. Full-Width Save Changes Button ───
                _buildSaveButton(profile),

                const SizedBox(height: 16),

                // ─── 4. Full-Width Footer Benefit Cards ───
                _buildBenefitCards(width: width),
              ],
            );
          }),
        );
      },
    );
  }

  // ─── Header: Titles & Membership Badge ──────────────────────────────
  Widget _buildHeader({required bool isMobile, CustomerProfile? profile}) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "USER PREFERENCES",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Lounge Profile Settings",
          style: GoogleFonts.italiana(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Keep your details updated to enjoy a smoother, personalised event experience.",
          style: AppTheme.sansBody(
            fontSize: isMobile ? 10.5 : 11.5,
            color: const Color(0xFF8B9D95),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );

    final membershipBadge = _buildMembershipBadge();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 12),
          membershipBadge,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        membershipBadge,
      ],
    );
  }

  // ─── Top-Right Membership Badge ──────────────────────────────────────
  Widget _buildMembershipBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular badge with crown
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE5C365),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: _CrownIcon(
                size: 16,
                color: Color(0xFF091210),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "PLATINUM LOUNGE MEMBER",
                style: AppTheme.sansBody(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8CC8A),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Exclusive member benefits unlocked",
                style: AppTheme.sansBody(
                  fontSize: 9,
                  color: const Color(0xFF8B9D95),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Card 1: Personal Details ───────────────────────────────────────
  Widget _buildPersonalDetailsCard(CustomerProfile? profile) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with interactive profile avatar badge
          Row(
            children: [
              Tooltip(
                message: "Click to change profile picture",
                child: GestureDetector(
                  onTap: _isUploadingPhoto ? null : _pickProfileImage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF14201A),
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImageBytes != null
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                    width: 44,
                                    height: 44,
                                  )
                                : (profile?.profileImageUrl.isNotEmpty == true
                                    ? CachedNetworkImage(
                                        imageUrl: profile!.profileImageUrl,
                                        fit: BoxFit.cover,
                                        width: 44,
                                        height: 44,
                                        placeholder: (_, __) => const Center(
                                          child: SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFD4AF37),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: Color(0xFFE8CC8A),
                                            size: 24,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFFE5C365),
                                        child: const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: Color(0xFF091210),
                                            size: 24,
                                          ),
                                        ),
                                      )),
                          ),
                        ),

                        // Camera/Edit badge indicator at bottom-right
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0A120E),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 1.0,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 10,
                                color: Color(0xFFE8CC8A),
                              ),
                            ),
                          ),
                        ),

                        // Uploading spinner overlay
                        if (_isUploadingPhoto)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.65),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Personal Details",
                          style: AppTheme.sansBody(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (_selectedImageBytes != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0x35D4AF37),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              "PHOTO SELECTED",
                              style: AppTheme.sansBody(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE8CC8A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _selectedImageBytes != null
                          ? "New photo previewed. Click 'Save Profile Changes' below."
                          : "Your basic account information & avatar",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: _selectedImageBytes != null
                            ? const Color(0xFFE8CC8A)
                            : const Color(0xFF8B9D95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Full Name
          _buildCompactLuxuryField(
            label: "Full Name",
            ctrl: nameCtrl,
            focusNode: nameFocus,
            icon: Icons.person_outline_rounded,
            hintText: "Enter full name",
            showEditIcon: true,
          ),
          const SizedBox(height: 11),

          // Phone Number
          _buildCompactLuxuryField(
            label: "Phone Number",
            ctrl: phoneCtrl,
            focusNode: phoneFocus,
            icon: Icons.phone_outlined,
            hintText: "Enter phone number",
            isNumber: true,
            showEditIcon: true,
          ),
          const SizedBox(height: 11),

          // Email Address (Locked)
          _buildCompactLuxuryField(
            label: "Email Address (Locked)",
            ctrl: emailCtrl,
            icon: Icons.lock_outline_rounded,
            hintText: "Enter email address",
            enabled: false,
          ),
          const SizedBox(height: 11),

          // Date of Birth & Gender side-by-side
          Row(
            children: [
              Expanded(
                child: _buildCompactLuxuryDatePicker(
                  label: "Date of Birth",
                  selectedDate: _selectedDob,
                  onDateSelected: (date) {
                    setState(() => _selectedDob = date);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactLuxuryDropdown(
                  label: "Gender",
                  value: _selectedGender,
                  hintText: "Select gender",
                  icon: Icons.person_search_outlined,
                  items: const ['Male', 'Female', 'Other', 'Prefer not to say'],
                  onChanged: (val) {
                    setState(() => _selectedGender = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Card 2: Event Logistics Address ─────────────────────────────────
  Widget _buildLogisticsAddressCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with gold filled storefront badge
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE5C365),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFF091210),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Event Logistics Address",
                      style: AppTheme.sansBody(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      "Where we deliver & coordinate your setup",
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: const Color(0xFF8B9D95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Billing / Delivery Address (full card width)
          _buildCompactLuxuryField(
            label: "Billing / Delivery Address",
            ctrl: addressCtrl,
            focusNode: addressFocus,
            icon: Icons.location_on_outlined,
            hintText: "Enter full address",
          ),
          const SizedBox(height: 11),

          // City & State side-by-side
          Row(
            children: [
              Expanded(
                child: _buildCompactLuxuryField(
                  label: "City",
                  ctrl: cityCtrl,
                  focusNode: cityFocus,
                  icon: Icons.location_city_outlined,
                  hintText: "City",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactLuxuryField(
                  label: "State",
                  ctrl: stateCtrl,
                  focusNode: stateFocus,
                  icon: Icons.map_outlined,
                  hintText: "State",
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // Pincode & Branch side-by-side
          Row(
            children: [
              Expanded(
                child: _buildCompactLuxuryField(
                  label: "Pincode",
                  ctrl: pincodeCtrl,
                  focusNode: pincodeFocus,
                  icon: Icons.pin_drop_outlined,
                  hintText: "Pincode",
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactLuxuryDropdown(
                  label: "Branch",
                  value: _selectedBranch,
                  hintText: "Select branch",
                  icon: Icons.store_mall_directory_outlined,
                  items: AppBranches.canonicalBranches,
                  allowCustomValue: false,
                  onChanged: (val) {
                    setState(() => _selectedBranch = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Single-Layer Compact Luxury Field Component ────────────────────
  // Exactly ONE visible golden-bordered container.
  // The text sits directly on the main field background with no nested boxes.
  Widget _buildCompactLuxuryField({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    FocusNode? focusNode,
    String? hintText,
    bool enabled = true,
    bool isNumber = false,
    bool showEditIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: enabled ? const Color(0xFF9EABA4) : const Color(0xFF63746D),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        // ── Single Main Field Container (Only One Visible Border) ──
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0A120E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFD4AF37).withValues(alpha: 0.25)
                  : Colors.white12,
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Leading Gold Icon
              Icon(
                icon,
                size: 16,
                color: enabled
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFFC5A028),
              ),
              const SizedBox(width: 10),

              // Direct TextField sitting on the main field background
              Expanded(
                child: TextField(
                  controller: ctrl,
                  focusNode: focusNode,
                  enabled: enabled,
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  cursorColor: const Color(0xFFD4AF37),
                  style: AppTheme.sansBody(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.white : const Color(0xFFD6DDD9),
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTheme.sansBody(
                      fontSize: 12.5,
                      color: const Color(0xFF7A8E85),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              // Enclosed Gold Edit Button
              if (showEditIcon && enabled) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    focusNode?.requestFocus();
                    ctrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: ctrl.text.length),
                    );
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14201A),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: Color(0xFFE8CC8A),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── Compact Luxury Date Picker Component ───────────────────────────
  Widget _buildCompactLuxuryDatePicker({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    final displayText = selectedDate != null
        ? DateFormat('dd MMMM yyyy').format(selectedDate)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9EABA4),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final initial = selectedDate != null && selectedDate.isBefore(now)
                ? selectedDate
                : DateTime(2000, 1, 1);
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(1900),
              lastDate: now,
              helpText: "SELECT DATE OF BIRTH",
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFD4AF37),
                    onPrimary: Color(0xFF091210),
                    surface: Color(0xFF171411),
                    onSurface: Colors.white,
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: const Color(0xFF14201A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0A120E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.cake_outlined,
                  size: 16,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayText ?? "Select date of birth",
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: displayText != null
                          ? Colors.white
                          : const Color(0xFF7A8E85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: Color(0xFFE8CC8A),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Compact Luxury Dropdown Component ──────────────────────────────
  Widget _buildCompactLuxuryDropdown({
    required String label,
    required String value,
    required String hintText,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String> onChanged,
    bool allowCustomValue = false,
  }) {
    // Only allow custom items if explicitly permitted.
    // For canonical business branches, strictly enforce canonical options: Kadi and Thangadh.
    final effectiveItems = List<String>.from(items);
    if (allowCustomValue && value.isNotEmpty && !effectiveItems.contains(value)) {
      effectiveItems.insert(0, value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9EABA4),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0A120E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.isNotEmpty && effectiveItems.contains(value) ? value : null,
                    hint: Text(
                      hintText,
                      style: AppTheme.sansBody(
                        fontSize: 12.5,
                        color: const Color(0xFF7A8E85),
                      ),
                    ),
                    dropdownColor: const Color(0xFF14201A),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFFE8CC8A),
                    ),
                    isExpanded: true,
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    items: effectiveItems.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: AppTheme.sansBody(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        onChanged(val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Save Profile Button ─────────────────────────────────────────────
  Widget _buildSaveButton(CustomerProfile? profile) {
    final bool isSaving = widget.controller.isLoading.value || _isUploadingPhoto;

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE5C365),
          foregroundColor: const Color(0xFF091210),
          elevation: 4,
          shadowColor: const Color(0x40D4AF37),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: isSaving ? null : () => _handleSaveProfile(profile),
        child: isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Color(0xFF091210),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isUploadingPhoto ? "Uploading Avatar..." : "Saving Profile...",
                    style: AppTheme.sansBody(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF091210),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Save Profile Changes",
                    style: AppTheme.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF091210),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Color(0xFF091210),
                  ),
                ],
              ),
      ),
    );
  }

  /// Handles profile saving with deferred Supabase Storage upload:
  /// 1. Uploads selected photo to Supabase if a new file was chosen.
  /// 2. Updates canonical Firebase customer profile with the resulting public URL.
  /// 3. Updates all text fields and triggers reactive refresh of local state.
  Future<void> _handleSaveProfile(CustomerProfile? profile) async {
    final fullName = nameCtrl.text.trim();
    if (fullName.isEmpty) {
      Get.snackbar(
        "Validation",
        "Full Name is required.",
        backgroundColor: const Color(0xFF2D1515),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      nameFocus.requestFocus();
      return;
    }

    final phone = phoneCtrl.text.trim();
    if (phone.isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 10) {
        Get.snackbar(
          "Validation",
          "Please enter a valid 10-digit phone number.",
          backgroundColor: const Color(0xFF2D1515),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        phoneFocus.requestFocus();
        return;
      }
    }

    final pincode = pincodeCtrl.text.trim();
    if (pincode.isNotEmpty && pincode.length != 6) {
      Get.snackbar(
        "Validation",
        "Please enter a valid 6-digit postal pincode.",
        backgroundColor: const Color(0xFF2D1515),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      pincodeFocus.requestFocus();
      return;
    }

    if (_selectedDob != null && _selectedDob!.isAfter(DateTime.now())) {
      Get.snackbar(
        "Validation",
        "Date of Birth cannot be in the future.",
        backgroundColor: const Color(0xFF2D1515),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_selectedBranch.isNotEmpty && !AppBranches.isValidBranch(_selectedBranch)) {
      Get.snackbar(
        "Validation",
        "Please select a valid branch (Kadi or Thangadh).",
        backgroundColor: const Color(0xFF2D1515),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String profileImageUrl = profile?.profileImageUrl ?? '';

    // If user selected a new profile image, upload it to Supabase Storage first
    if (_selectedImageBytes != null) {
      try {
        setState(() => _isUploadingPhoto = true);
        final uploadedUrl = await widget.controller.uploadProfileImage(
          fileBytes: _selectedImageBytes!,
          fileName: _selectedImageName ?? 'avatar.jpg',
        );
        profileImageUrl = uploadedUrl;
      } catch (e) {
        String msg = e.toString();
        if (msg.contains('row-level security policy') || msg.contains('AccessDenied')) {
          msg = "Supabase Storage RLS policy is not configured for bucket 'profile'. Please add an INSERT policy in your Supabase SQL editor.";
        }
        Get.snackbar(
          "Upload Failed",
          msg,
          backgroundColor: const Color(0xFF2D1515),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        setState(() => _isUploadingPhoto = false);
        return; // Halt so existing profile is not overwritten with invalid state
      } finally {
        if (mounted) setState(() => _isUploadingPhoto = false);
      }
    }

    await widget.controller.updateProfile(
      fullName: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      gender: _selectedGender.trim(),
      dateOfBirth: _selectedDob,
      address: addressCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      pincode: pincodeCtrl.text.trim(),
      branch: _selectedBranch.trim(),
      profileImageUrl: profileImageUrl,
    );

    if (mounted) {
      setState(() {
        _selectedImageBytes = null;
        _selectedImageName = null;
      });
    }
  }

  // ─── Benefit Cards ───────────────────────────────────────────────────
  Widget _buildBenefitCards({required double width}) {
    final cards = [
      _buildBenefitCard(
        icon: Icons.shield_outlined,
        title: "Secure & Private",
        subtitle: "Your data is safe with us",
      ),
      _buildBenefitCard(
        icon: Icons.bolt_outlined,
        title: "Faster Service",
        subtitle: "Quick event coordination",
      ),
      _buildBenefitCard(
        icon: Icons.auto_awesome_outlined,
        title: "Personalised Experience",
        subtitle: "Tailored recommendations",
      ),
      _buildBenefitCard(
        icon: Icons.headset_mic_outlined,
        title: "Dedicated Support",
        subtitle: "Whenever you need us",
      ),
    ];

    if (width >= 860) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
          const SizedBox(width: 12),
          Expanded(child: cards[2]),
          const SizedBox(width: 12),
          Expanded(child: cards[3]),
        ],
      );
    } else if (width >= 560) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 10),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 10),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 8),
          cards[1],
          const SizedBox(height: 8),
          cards[2],
          const SizedBox(height: 8),
          cards[3],
        ],
      );
    }
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1713),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x28D4AF37),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                width: 0.9,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 13,
                color: const Color(0xFFE8CC8A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTheme.sansBody(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: AppTheme.sansBody(
                    fontSize: 9,
                    color: const Color(0xFF8B9D95),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Vector Crown Icon for the Platinum Lounge Member status badge.
class _CrownIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _CrownIcon({this.size = 16, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.75),
      painter: _CrownPainter(color: color),
    );
  }
}

class _CrownPainter extends CustomPainter {
  final Color color;
  _CrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * 0.95, size.height * 0.35);
    path.lineTo(size.width * 0.7, size.height * 0.65);
    path.lineTo(size.width * 0.5, size.height * 0.15);
    path.lineTo(size.width * 0.3, size.height * 0.65);
    path.lineTo(size.width * 0.05, size.height * 0.35);
    path.close();

    canvas.drawPath(path, paint);

    // Jewel accents on the crown tips
    final jewelRadius = size.width * 0.07;
    canvas.drawCircle(Offset(size.width * 0.05, size.height * 0.35 - jewelRadius), jewelRadius, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15 - jewelRadius), jewelRadius, paint);
    canvas.drawCircle(Offset(size.width * 0.95, size.height * 0.35 - jewelRadius), jewelRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _CrownPainter oldDelegate) => oldDelegate.color != color;
}
