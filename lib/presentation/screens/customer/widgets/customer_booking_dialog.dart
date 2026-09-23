import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/config/app_routes.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/booking_availability_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../../data/datasources/supabase_storage_source.dart';
import '../../../../domain/entities/experience.dart';
import '../../../../domain/entities/package_option.dart';
import '../../../controllers/customer_auth_controller.dart';
import '../../../controllers/quotation_controller.dart';

import 'customer_login_required_dialog.dart';
export 'customer_login_required_dialog.dart';

void showCustomerBookingDialog(
  BuildContext context, {
  required Experience experience,
  required PackageOption selectedPackage,
}) {
  final authCtrl = Get.find<CustomerAuthController>();
  if (!authCtrl.isAuthenticatedCustomer) {
    showCustomerLoginRequiredDialog(
      context,
      subtitle: "Please login to continue with your booking for ${experience.name}.",
    );
    return;
  }

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.75),
    builder: (_) => CustomerBookingDialog(
      experience: experience,
      selectedPackage: selectedPackage,
    ),
  );
}

class CustomerBookingDialog extends StatefulWidget {
  final Experience experience;
  final PackageOption selectedPackage;

  const CustomerBookingDialog({
    super.key,
    required this.experience,
    required this.selectedPackage,
  });

  @override
  State<CustomerBookingDialog> createState() => _CustomerBookingDialogState();
}

class _CustomerBookingDialogState extends State<CustomerBookingDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController(text: "18:00");
  final _venueController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  bool _isCheckingAvailability = false;
  DateAvailabilityResult? _availabilityResult;

  Uint8List? _referenceImageBytes;
  String? _referenceImageName;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (currentUser.displayName?.isNotEmpty == true) {
        _nameController.text = currentUser.displayName!;
      }
      if (currentUser.phoneNumber?.isNotEmpty == true) {
        _phoneController.text = currentUser.phoneNumber!;
      }
      if (currentUser.email?.isNotEmpty == true) {
        _emailController.text = currentUser.email!;
      }
    }

    if (Get.isRegistered<CustomerAuthController>()) {
      final profile = Get.find<CustomerAuthController>().rxCustomerProfile.value;
      if (profile != null) {
        if (profile.fullName.isNotEmpty) _nameController.text = profile.fullName;
        if (profile.phone.isNotEmpty) _phoneController.text = profile.phone;
        if (profile.email.isNotEmpty) _emailController.text = profile.email;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final availabilityService = Get.isRegistered<BookingAvailabilityService>()
        ? BookingAvailabilityService.to
        : Get.put(BookingAvailabilityService());

    final minDate = availabilityService.minBookingDate;
    final maxDate = DateTime.now().add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null && _selectedDate!.isAfter(minDate)
          ? _selectedDate!
          : minDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.secondaryAccent,
              onPrimary: const Color(0xFF0F1B18),
              surface: const Color(0xFF152621),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = BookingAvailabilityService.normalizeDateString(picked);
        _isCheckingAvailability = true;
        _availabilityResult = null;
      });

      final result = await availabilityService.checkDateAvailability(picked);
      if (mounted) {
        setState(() {
          _isCheckingAvailability = false;
          _availabilityResult = result;
        });
      }
    }
  }

  Future<void> _pickReferenceImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          Get.snackbar("File too large", "Reference image must be under 10MB.");
          return;
        }

        setState(() {
          _referenceImageBytes = file.bytes;
          _referenceImageName = file.name;
        });
      }
    } catch (e) {
      Get.snackbar("Image Selection Error", e.toString());
    }
  }

  Future<String?> _uploadReferenceImage(String publicId) async {
    if (_referenceImageBytes == null) return null;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.isAnonymous) {
      Get.snackbar("Authentication Required", "You must be logged in to upload reference images.");
      return null;
    }
    try {
      setState(() => _isUploadingImage = true);
      if (Get.isRegistered<SupabaseStorageSource>()) {
        final storage = Get.find<SupabaseStorageSource>();
        final extension = _referenceImageName?.split('.').last ?? 'jpg';
        final fileName = '${publicId}_ref_${DateTime.now().millisecondsSinceEpoch}.$extension';
        final url = await storage.uploadFile(
          fileName,
          _referenceImageBytes!,
          'image/$extension',
          bucket: 'quotation_attachments',
        );
        return url;
      }
    } catch (_) {
      // Graceful fallback if storage bucket offline
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 768;
    final quoteController = Get.find<QuotationController>();

    final goldColor = AppColors.secondaryAccent;
    const darkBg = Color(0xFF0D1915);
    const cardBg = Color(0xFF152621);
    const borderColor = Color(0xFF1E3A32);

    return Dialog(
      backgroundColor: darkBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderColor, width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 680 : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CONFIRM EVENT BOOKING",
                          style: AppTheme.sansBody(
                            fontSize: 10,
                            color: goldColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.experience.name,
                          style: GoogleFonts.italiana(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Package summary banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: goldColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: goldColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                widget.selectedPackage.tier.toUpperCase(),
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  color: goldColor,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.selectedPackage.name,
                                    style: AppTheme.sansBody(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    "${widget.selectedPackage.durationHours} Hours Setup & Execution",
                                    style: AppTheme.sansBody(fontSize: 11, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              AppFormatters.formatCurrency(widget.selectedPackage.effectivePrice),
                              style: AppTheme.serifHeader(
                                fontSize: 18,
                                color: goldColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Customer Information
                      Text(
                        "1. CONTACT DETAILS",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: goldColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomInput(
                        label: "Full Name *",
                        placeholder: "e.g. Aarav Patel",
                        controller: _nameController,
                        validator: (val) =>
                            AppValidators.isValidName(val ?? '') ? null : "Please enter your full name.",
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomInput(
                              label: "Phone Number *",
                              placeholder: "10-digit mobile number",
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (val) => AppValidators.isValidPhone(val ?? '')
                                  ? null
                                  : "Valid 10-digit number required.",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomInput(
                              label: "Email Address (Optional)",
                              placeholder: "name@example.com",
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val != null && val.trim().isNotEmpty) {
                                  return AppValidators.isValidEmail(val.trim())
                                      ? null
                                      : "Invalid email format.";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Event Information
                      Text(
                        "2. OCCASION & LOGISTICS",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: goldColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date & Time Row with Availability Check
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomInput(
                                  label: "Event Date *",
                                  placeholder: "YYYY-MM-DD",
                                  controller: _dateController,
                                  readOnly: true,
                                  onTap: () => _pickDate(context),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return "Date is required.";
                                    }
                                    if (_availabilityResult?.isAvailable == false) {
                                      return "Selected date is unavailable.";
                                    }
                                    return null;
                                  },
                                ),
                                if (_isCheckingAvailability)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, left: 4),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(goldColor),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Checking date availability...",
                                          style: AppTheme.sansBody(fontSize: 11, color: goldColor),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_availabilityResult != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, left: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _availabilityResult!.isAvailable
                                              ? Icons.check_circle_rounded
                                              : Icons.cancel_rounded,
                                          size: 14,
                                          color: _availabilityResult!.isAvailable
                                              ? const Color(0xFF4EBA7A)
                                              : const Color(0xFFE57373),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            _availabilityResult!.isAvailable
                                                ? "Date Available (1 Grand Event/Day Guaranteed)"
                                                : _availabilityResult!.reason ?? "Date unavailable.",
                                            style: AppTheme.sansBody(
                                              fontSize: 11,
                                              color: _availabilityResult!.isAvailable
                                                  ? const Color(0xFF4EBA7A)
                                                  : const Color(0xFFE57373),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: CustomInput(
                              label: "Event Time *",
                              placeholder: "18:00",
                              controller: _timeController,
                              readOnly: true,
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: const TimeOfDay(hour: 18, minute: 0),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: goldColor,
                                          surface: const Color(0xFF152621),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  _timeController.text =
                                      "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Venue Autocomplete
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          const options = [
                            "Sindhu Bhavan Hall, SBR, Ahmedabad",
                            "SG Highway Royal Palace, Ahmedabad",
                            "Club O7 Banquet, Shela, Ahmedabad",
                            "Kadi Community Center, Kadi, Gujarat",
                            "Thangadh Town Palace, Thangadh, Gujarat",
                            "Bopal Celebration Ground, Ahmedabad",
                            "Sabarmati Riverfront Event Center, Ahmedabad",
                            "Nikol Party Plot, Ahmedabad",
                            "Science City Grand Ballroom, Ahmedabad",
                            "Prahlad Nagar Garden Banquet, Ahmedabad",
                          ];
                          return options.where(
                            (opt) => opt.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                          );
                        },
                        onSelected: (selection) => _venueController.text = selection,
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          if (controller.text.isEmpty && _venueController.text.isNotEmpty) {
                            controller.text = _venueController.text;
                          }
                          controller.addListener(() => _venueController.text = controller.text);
                          return CustomInput(
                            label: "Venue / Location *",
                            placeholder: "Venue name, area and city (e.g. SG Highway, Ahmedabad)",
                            controller: controller,
                            validator: (val) =>
                                (val != null && val.trim().isNotEmpty) ? null : "Venue location required.",
                          );
                        },
                      ),

                      // Service Area Coverage Helper Note
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFD4AF37)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Hubs: Kadi, Thangadh & Greater Ahmedabad (Free standard logistics). Nominal travel for extended Gujarat venues.",
                                style: AppTheme.sansBody(fontSize: 10.5, color: Colors.white54),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => Get.toNamed(AppRoutes.serviceArea),
                              child: Text(
                                "Check Coverage ↗",
                                style: AppTheme.sansBody(fontSize: 10.5, color: goldColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Reference Image Upload
                      Text(
                        "3. REFERENCE INSPIRATION (OPTIONAL)",
                        style: AppTheme.sansBody(
                          fontSize: 11,
                          color: goldColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: _referenceImageBytes != null
                            ? Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      _referenceImageBytes!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _referenceImageName ?? "Reference Image",
                                          style: AppTheme.sansBody(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Ready for decor team review",
                                          style: AppTheme.sansBody(fontSize: 11, color: goldColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white60),
                                    onPressed: () {
                                      setState(() {
                                        _referenceImageBytes = null;
                                        _referenceImageName = null;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : InkWell(
                                onTap: _pickReferenceImage,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined, color: goldColor, size: 22),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Upload Reference Photo / Moodboard (Max 10MB)",
                                        style: AppTheme.sansBody(
                                          fontSize: 12,
                                          color: goldColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Special Notes
                      CustomInput(
                        label: "Special Instructions / Color Theme",
                        placeholder: "e.g. Royal emerald & champagne gold theme, entry passage setup...",
                        controller: _notesController,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Submit Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "By submitting, you agree to our ",
                            style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
                          ),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.bookingPolicy),
                            child: Text(
                              "Booking Policy",
                              style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            " & ",
                            style: AppTheme.sansBody(fontSize: 11, color: Colors.white54),
                          ),
                          InkWell(
                            onTap: () => Get.toNamed(AppRoutes.cancellationPolicy),
                            child: Text(
                              "Cancellation Policy",
                              style: AppTheme.sansBody(fontSize: 11, color: goldColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                    text: _isUploadingImage
                        ? "Uploading Reference Image..."
                        : "CONFIRM & SUBMIT BOOKING",
                    isLoading: quoteController.isGeneratingQuote.value || _isUploadingImage || _isSubmitting,
                    onPressed: (_isSubmitting || quoteController.isGeneratingQuote.value || _isUploadingImage)
                        ? null
                        : () async {
                            final authCtrl = Get.find<CustomerAuthController>();
                            if (!authCtrl.isAuthenticatedCustomer) {
                              Get.snackbar(
                                "Login Required",
                                "Please login to continue with your booking.",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFF231B1B),
                                colorText: const Color(0xFFFFAA99),
                              );
                              return;
                            }
                            if (_formKey.currentState?.validate() != true) return;
                            if (_availabilityResult?.isAvailable == false) {
                              Get.snackbar("Date Unavailable", "Please select an available event date.");
                              return;
                            }

                            setState(() => _isSubmitting = true);
                            try {
                              final navigator = Navigator.of(context);
                              String? uploadedImageUrl;
                              if (_referenceImageBytes != null) {
                                uploadedImageUrl = await _uploadReferenceImage(
                                  widget.experience.id,
                                );
                              }

                              final success = await quoteController.submitDirectBookingRequest(
                                experience: widget.experience,
                                package: widget.selectedPackage,
                                name: _nameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                email: _emailController.text.trim(),
                                dateStr: _dateController.text.trim(),
                                timeStr: _timeController.text.trim(),
                                venue: _venueController.text.trim(),
                                notes: _notesController.text.trim(),
                                referenceImageUrl: uploadedImageUrl,
                              );

                              if (success) {
                                navigator.pop();
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
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
