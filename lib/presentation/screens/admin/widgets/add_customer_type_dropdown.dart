import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

/// Client type dropdown selector for Add New Client dialog.
class AddCustomerTypeDropdown extends StatelessWidget {
  final String selectedType;
  final Color textColor;
  final Color borderColor;
  final Color fieldFill;
  final ValueChanged<String> onTypeChanged;

  const AddCustomerTypeDropdown({
    super.key,
    required this.selectedType,
    required this.textColor,
    required this.borderColor,
    required this.fieldFill,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLIENT TYPE *',
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                Icons.person_pin_outlined,
                color: AppColors.primaryAccent.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    dropdownColor: fieldFill,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Individual', child: Text('Individual')),
                      DropdownMenuItem(value: 'Business', child: Text('Business')),
                      DropdownMenuItem(value: 'Corporate', child: Text('Corporate')),
                      DropdownMenuItem(value: 'VIP', child: Text('VIP')),
                    ],
                    onChanged: (val) {
                      if (val != null) onTypeChanged(val);
                    },
                    style: AppTheme.sansBody(fontSize: 13, color: textColor),
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
