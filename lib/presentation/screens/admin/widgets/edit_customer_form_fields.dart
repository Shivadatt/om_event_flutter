import 'package:flutter/material.dart';
import 'edit_customer_desktop_fields.dart';
import 'edit_customer_mobile_fields.dart';

/// Form fields container orchestrating desktop vs mobile presentation for Edit Client Profile dialog.
class EditCustomerFormFields extends StatelessWidget {
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

  const EditCustomerFormFields({
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
      return EditCustomerMobileFields(
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

    return EditCustomerDesktopFields(
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
