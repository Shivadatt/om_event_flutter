import 'package:flutter/material.dart';
import 'add_customer_desktop_fields.dart';
import 'add_customer_mobile_fields.dart';

/// Form fields container orchestrating desktop vs mobile presentation for Add New Client dialog.
class AddCustomerFormFields extends StatelessWidget {
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
  final bool isNarrow;
  final Color textColor;
  final Color borderColor;
  final Color subtitleColor;
  final Color fieldFill;

  const AddCustomerFormFields({
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
    required this.isNarrow,
    required this.textColor,
    required this.borderColor,
    required this.subtitleColor,
    required this.fieldFill,
  });

  @override
  Widget build(BuildContext context) {
    if (isNarrow) {
      return AddCustomerMobileFields(
        nameCtrl: nameCtrl,
        phoneCtrl: phoneCtrl,
        emailCtrl: emailCtrl,
        addrCtrl: addrCtrl,
        cityCtrl: cityCtrl,
        stateCtrl: stateCtrl,
        locCtrl: locCtrl,
        selectedType: selectedType,
        onTypeChanged: onTypeChanged,
        photoWidget: photoWidget,
        textColor: textColor,
        borderColor: borderColor,
        subtitleColor: subtitleColor,
        fieldFill: fieldFill,
      );
    }

    return AddCustomerDesktopFields(
      nameCtrl: nameCtrl,
      phoneCtrl: phoneCtrl,
      emailCtrl: emailCtrl,
      addrCtrl: addrCtrl,
      cityCtrl: cityCtrl,
      stateCtrl: stateCtrl,
      locCtrl: locCtrl,
      selectedType: selectedType,
      onTypeChanged: onTypeChanged,
      photoWidget: photoWidget,
      textColor: textColor,
      borderColor: borderColor,
      subtitleColor: subtitleColor,
      fieldFill: fieldFill,
    );
  }
}
