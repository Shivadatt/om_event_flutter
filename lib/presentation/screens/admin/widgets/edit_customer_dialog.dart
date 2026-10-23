import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/customer_model.dart';
import '../../../controllers/admin_controller.dart';
import 'add_customer_dialog_helper.dart';
import 'edit_customer_dialog_actions.dart';
import 'edit_customer_dialog_header.dart';
import 'edit_customer_form_fields.dart';
import 'edit_customer_photo_section.dart';
import 'edit_customer_submit_handler.dart';

/// Backward compatibility alias for CustomerEditDialog.
typedef CustomerEditDialog = EditCustomerDialog;

/// Responsive modal dialog for editing a client profile in OM Events Admin.
class EditCustomerDialog extends StatefulWidget {
  final CustomerModel customer;
  final AdminController controller;

  const EditCustomerDialog({super.key, required this.customer, required this.controller});

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  late final TextEditingController nameCtrl, phoneCtrl, emailCtrl, addrCtrl, cityCtrl, stateCtrl, locCtrl;
  late String selectedType;

  Uint8List? _selectedPhotoBytes;
  String? _selectedPhotoName;
  bool _removedExistingPhoto = false;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.customer.name);
    final rawPhone = widget.customer.phone.isNotEmpty ? widget.customer.phone : widget.customer.id;
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    final tenDigit = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    phoneCtrl = TextEditingController(text: tenDigit);
    emailCtrl = TextEditingController(text: widget.customer.email);
    addrCtrl = TextEditingController(text: widget.customer.address);
    cityCtrl = TextEditingController(text: widget.customer.city);
    stateCtrl = TextEditingController(text: widget.customer.state);
    locCtrl = TextEditingController(text: widget.customer.mapLocation);
    selectedType = widget.customer.type.isNotEmpty ? widget.customer.type : 'Individual';
  }

  @override
  void dispose() {
    for (final c in [nameCtrl, phoneCtrl, emailCtrl, addrCtrl, cityCtrl, stateCtrl, locCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await EditCustomerSubmitHandler.save(
        context: context,
        customer: widget.customer,
        controller: widget.controller,
        name: nameCtrl.text.trim(),
        rawPhone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        address: addrCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        mapLocation: locCtrl.text.trim(),
        selectedType: selectedType,
        selectedPhotoBytes: _selectedPhotoBytes,
        selectedPhotoName: _selectedPhotoName,
        removedExistingPhoto: _removedExistingPhoto,
        onUploadStateChange: (up) => mounted ? setState(() => _isUploadingPhoto = up) : null,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color cardColor = isDark ? const Color(0xFF0F1511) : AppColors.lightPaper;
    final Color fieldFill = isDark ? const Color(0xFF131A15) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? const Color(0xFF1F3025) : AppColors.lightLine;
    final Color subtitleColor = isDark ? const Color(0xFF8E9893) : AppColors.lightMuted;

    final screenSize = MediaQuery.sizeOf(context);
    final isMobile = screenSize.width < 600;
    final double maxWidth = isMobile ? 360 : (screenSize.width < 900 ? 720 : 780);
    final double maxHeight = screenSize.height * (isMobile ? 0.92 : 0.88);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 16),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(color: AppColors.primaryAccent.withValues(alpha: 0.12), blurRadius: 28, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 36, offset: const Offset(0, 16)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditCustomerDialogHeader(
                isMobile: isMobile,
                textColor: textColor,
                subtitleColor: subtitleColor,
                borderColor: borderColor,
                onClose: () => safeDismissDialog(context),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(isMobile ? 18 : 28, 16, isMobile ? 18 : 28, 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      return EditCustomerFormFields(
                        nameCtrl: nameCtrl,
                        phoneCtrl: phoneCtrl,
                        emailCtrl: emailCtrl,
                        addrCtrl: addrCtrl,
                        cityCtrl: cityCtrl,
                        stateCtrl: stateCtrl,
                        locCtrl: locCtrl,
                        selectedType: selectedType,
                        onTypeChanged: (val) => setState(() => selectedType = val),
                        photoWidget: EditCustomerPhotoSection(
                          existingPhotoUrl: widget.customer.profileImageUrl,
                          selectedPhotoBytes: _selectedPhotoBytes,
                          selectedPhotoName: _selectedPhotoName,
                          removedExistingPhoto: _removedExistingPhoto,
                          isUploading: _isUploadingPhoto,
                          width: isNarrow ? 150 : 160,
                          height: isNarrow ? 160 : 220,
                          fieldFill: fieldFill,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                          onPhotoSelected: (b, n) => setState(() {
                            _selectedPhotoBytes = b; _selectedPhotoName = n; _removedExistingPhoto = false;
                          }),
                          onPhotoRemoved: () => setState(() {
                            _selectedPhotoBytes = null; _selectedPhotoName = null; _removedExistingPhoto = true;
                          }),
                        ),
                        isNarrow: isNarrow,
                        textColor: textColor,
                        borderColor: borderColor,
                        subtitleColor: subtitleColor,
                        fieldFill: fieldFill,
                      );
                    },
                  ),
                ),
              ),
              EditCustomerDialogActions(
                isSaving: _isSaving,
                isMobile: isMobile,
                textColor: textColor,
                borderColor: borderColor,
                fieldFill: fieldFill,
                onCancel: () => safeDismissDialog(context),
                onSave: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
