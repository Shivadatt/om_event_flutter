import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

/// Styled input field for Add New Client dialog.
class AddCustomerTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final Color textColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color fieldFill;

  const AddCustomerTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    required this.textColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.fieldFill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTheme.sansBody(fontSize: 13, color: textColor),
            decoration: InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              hintText: hint,
              hintStyle: AppTheme.sansBody(
                fontSize: 13,
                color: subtitleColor.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryAccent.withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Phone input field with '+91' country code for Add New Client dialog.
class AddCustomerPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final Color textColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color fieldFill;

  const AddCustomerPhoneField({
    super.key,
    required this.controller,
    required this.textColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.fieldFill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PHONE NUMBER *',
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryAccent,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.phone_outlined,
                color: AppColors.primaryAccent.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                '+91',
                style: AppTheme.sansBody(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 18, color: borderColor),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: AppTheme.sansBody(fontSize: 13, color: textColor),
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: '9876543210',
                    hintStyle: AppTheme.sansBody(
                      fontSize: 13,
                      color: subtitleColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
