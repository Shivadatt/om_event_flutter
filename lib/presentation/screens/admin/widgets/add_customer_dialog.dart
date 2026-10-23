import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import 'add_customer_dialog_actions.dart';
import 'add_customer_dialog_header.dart';
import 'add_customer_dialog_helper.dart';
import 'add_customer_form_fields.dart';
import 'add_customer_photo_upload.dart';
import 'add_customer_submit_handler.dart';

/// Backward compatibility alias for CustomerCreateDialog.
typedef CustomerCreateDialog = AddCustomerDialog;

/// Responsive modal dialog for adding a new customer in OM Events Admin.
class AddCustomerDialog extends StatefulWidget {
  final AdminController controller;

  const AddCustomerDialog({super.key, required this.controller});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addrCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  String selectedType = 'Individual';

  Uint8List? _photoBytes;
  String? _photoName;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addrCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    locCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await AddCustomerSubmitHandler.submit(
        context: context,
        controller: widget.controller,
        name: nameCtrl.text.trim(),
        rawPhone: phoneCtrl.text.trim(),
        rawEmail: emailCtrl.text.trim().toLowerCase(),
        address: addrCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        mapLocation: locCtrl.text.trim(),
        selectedType: selectedType,
        photoBytes: _photoBytes,
        photoName: _photoName,
        onUploadStateChange: (uploading) {
          if (mounted) setState(() => _isUploadingPhoto = uploading);
        },
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
    final double maxWidth = isMobile ? 360 : (screenSize.width < 900 ? 700 : 750);
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
              AddCustomerDialogHeader(
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
                      final isNarrow = constraints.maxWidth < 580;
                      return AddCustomerFormFields(
                        nameCtrl: nameCtrl,
                        phoneCtrl: phoneCtrl,
                        emailCtrl: emailCtrl,
                        addrCtrl: addrCtrl,
                        cityCtrl: cityCtrl,
                        stateCtrl: stateCtrl,
                        locCtrl: locCtrl,
                        selectedType: selectedType,
                        onTypeChanged: (val) => setState(() => selectedType = val),
                        photoWidget: AddCustomerPhotoUpload(
                          photoBytes: _photoBytes,
                          photoName: _photoName,
                          isUploading: _isUploadingPhoto,
                          width: isNarrow ? 150 : 140,
                          height: isNarrow ? 130 : 144,
                          fieldFill: fieldFill,
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                          onPhotoSelected: (b, n) => setState(() { _photoBytes = b; _photoName = n; }),
                          onPhotoCleared: () => setState(() { _photoBytes = null; _photoName = null; }),
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
              AddCustomerDialogActions(
                isSaving: _isSaving,
                isMobile: isMobile,
                textColor: textColor,
                borderColor: borderColor,
                fieldFill: fieldFill,
                onCancel: () => safeDismissDialog(context),
                onCreate: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
