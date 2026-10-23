import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

/// Footer action buttons (Cancel and Create Client) for Add New Client dialog.
class AddCustomerDialogActions extends StatelessWidget {
  final bool isSaving;
  final bool isMobile;
  final Color textColor;
  final Color borderColor;
  final Color fieldFill;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const AddCustomerDialogActions({
    super.key,
    required this.isSaving,
    required this.isMobile,
    required this.textColor,
    required this.borderColor,
    required this.fieldFill,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final cancelBtn = TextButton(
      onPressed: isSaving ? null : onCancel,
      style: TextButton.styleFrom(
        backgroundColor: fieldFill,
        side: BorderSide(color: borderColor),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Cancel',
        style: AppTheme.sansBody(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor.withValues(alpha: 0.8),
        ),
      ),
    );

    final createBtn = ElevatedButton.icon(
      icon: isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
            )
          : const Icon(Icons.person_add_outlined, size: 18, color: Colors.black),
      label: Text(isSaving ? 'Creating...' : 'Create Client'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 18 : 26,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      onPressed: isSaving ? null : onCreate,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 28,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor, width: 0.8)),
      ),
      child: isMobile
          ? Row(
              children: [
                Expanded(child: cancelBtn),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: createBtn),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                cancelBtn,
                const SizedBox(width: 14),
                createBtn,
              ],
            ),
    );
  }
}
