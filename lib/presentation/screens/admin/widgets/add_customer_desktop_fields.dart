import 'package:flutter/material.dart';
import 'add_customer_form_field.dart';
import 'add_customer_type_dropdown.dart';

/// Two-column form layout with photo box for Desktop, Laptop, and Tablet.
class AddCustomerDesktopFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController addrCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController stateCtrl;
  final TextEditingController locCtrl;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final Widget photoWidget;
  final Color textColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color fieldFill;

  const AddCustomerDesktopFields({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.addrCtrl,
    required this.cityCtrl,
    required this.stateCtrl,
    required this.locCtrl,
    required this.selectedType,
    required this.onTypeChanged,
    required this.photoWidget,
    required this.textColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.fieldFill,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            photoWidget,
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AddCustomerTextField(
                          label: 'Full Name *',
                          controller: nameCtrl,
                          hint: 'e.g. Shivadatt Goswami',
                          icon: Icons.person_outline_rounded,
                          textColor: textColor,
                          borderColor: borderColor,
                          subtitleColor: subtitleColor,
                          fieldFill: fieldFill,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AddCustomerPhoneField(
                          controller: phoneCtrl,
                          textColor: textColor,
                          borderColor: borderColor,
                          subtitleColor: subtitleColor,
                          fieldFill: fieldFill,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AddCustomerTextField(
                          label: 'Email Address',
                          controller: emailCtrl,
                          hint: 'e.g. shivadatt@gmail.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textColor: textColor,
                          borderColor: borderColor,
                          subtitleColor: subtitleColor,
                          fieldFill: fieldFill,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AddCustomerTypeDropdown(
                          selectedType: selectedType,
                          textColor: textColor,
                          borderColor: borderColor,
                          fieldFill: fieldFill,
                          onTypeChanged: onTypeChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AddCustomerTextField(
          label: 'Street Address',
          controller: addrCtrl,
          hint: 'e.g. 403 Grand Imperial Heights',
          icon: Icons.home_outlined,
          textColor: textColor,
          borderColor: borderColor,
          subtitleColor: subtitleColor,
          fieldFill: fieldFill,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AddCustomerTextField(
                label: 'City',
                controller: cityCtrl,
                hint: 'e.g. Ahmedabad',
                icon: Icons.location_city_outlined,
                textColor: textColor,
                borderColor: borderColor,
                subtitleColor: subtitleColor,
                fieldFill: fieldFill,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AddCustomerTextField(
                label: 'State',
                controller: stateCtrl,
                hint: 'e.g. Gujarat',
                icon: Icons.map_outlined,
                textColor: textColor,
                borderColor: borderColor,
                subtitleColor: subtitleColor,
                fieldFill: fieldFill,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AddCustomerTextField(
          label: 'Map Location / GPS URL',
          controller: locCtrl,
          hint: 'e.g. https://maps.google.com/...',
          icon: Icons.pin_drop_outlined,
          textColor: textColor,
          borderColor: borderColor,
          subtitleColor: subtitleColor,
          fieldFill: fieldFill,
        ),
      ],
    );
  }
}
