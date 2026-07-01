import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../../../controllers/catalog_controller.dart';
import '../../../controllers/quotation_controller.dart';

/// Helper class for launching Customer portal interactive dialog sheets and modals.
class CustomerDialogHelper {
  CustomerDialogHelper._();

  /// Launches the customer callback request dialog form.
  static void openLeadDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final dateController = TextEditingController();
    final budgetController = TextEditingController();
    final reqsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final catalogController = Get.find<CatalogController>();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          insetPadding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LET'S TALK",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "Tell us about the occasion.",
                      style: AppTheme.serifHeader(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomInput(
                      label: "Your Name",
                      placeholder: "Enter full name",
                      controller: nameController,
                      validator:
                          (val) =>
                              AppValidators.isValidName(val ?? '')
                                  ? null
                                  : "Please enter your name.",
                    ),
                    CustomInput(
                      label: "Phone Number",
                      placeholder: "10-digit mobile number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator:
                          (val) =>
                              AppValidators.isValidPhone(val ?? '')
                                  ? null
                                  : "Please enter a 10-digit number.",
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: "Event Date",
                            placeholder: "YYYY-MM-DD",
                            controller: dateController,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: "Approx. Budget",
                            placeholder: "₹",
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    CustomInput(
                      label: "What are you imagining?",
                      placeholder: "Details, must-have accents, themes...",
                      controller: reqsController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomButton(
                        text: "Request a callback",
                        isLoading: catalogController.isSubmittingLead.value,
                        onPressed: () async {
                          if (formKey.currentState?.validate() == true) {
                            final success = await catalogController
                                .requestCallback(
                                  name: nameController.text,
                                  phone: phoneController.text,
                                  dateStr: dateController.text,
                                  budgetStr: budgetController.text,
                                  requirements: reqsController.text,
                                );
                            if (success) {
                              Get.back();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Launches the quotation creation dialog form.
  static void openQuoteDialog(
    BuildContext context,
    QuotationController quoteController,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController(text: "18:00");
    final locController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          insetPadding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ALMOST THERE",
                      style: AppTheme.sansBody(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      "Where should we bring the wonder?",
                      style: AppTheme.serifHeader(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomInput(
                      label: "Full Name",
                      placeholder: "Enter full name",
                      controller: nameController,
                      validator:
                          (val) =>
                              AppValidators.isValidName(val ?? '')
                                  ? null
                                  : "Please enter your name.",
                    ),
                    CustomInput(
                      label: "Phone",
                      placeholder: "10-digit mobile number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator:
                          (val) =>
                              AppValidators.isValidPhone(val ?? '')
                                  ? null
                                  : "Please enter a 10-digit number.",
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInput(
                            label: "Event Date",
                            placeholder: "YYYY-MM-DD",
                            controller: dateController,
                            keyboardType: TextInputType.datetime,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Date required.";
                              }
                              final parsed = DateTime.tryParse(val);
                              if (parsed == null) return "Invalid date.";
                              if (!AppValidators.isFutureDate(parsed)) {
                                return "Cannot be in the past.";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomInput(
                            label: "Event Time",
                            placeholder: "HH:MM",
                            controller: timeController,
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                      ],
                    ),
                    CustomInput(
                      label: "Venue / Location",
                      placeholder: "Venue name, area and city",
                      controller: locController,
                      validator:
                          (val) =>
                              (val != null && val.trim().isNotEmpty)
                                  ? null
                                  : "Location required.",
                    ),
                    CustomInput(
                      label: "Notes or Special Instructions",
                      placeholder: "Timings, access rules, specific colors...",
                      controller: notesController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomButton(
                        text: "Generate quotation",
                        isLoading: quoteController.isGeneratingQuote.value,
                        onPressed: () async {
                          if (formKey.currentState?.validate() == true) {
                            final success = await quoteController
                                .submitQuotationRequest(
                                  name: nameController.text,
                                  phone: phoneController.text,
                                  dateStr: dateController.text,
                                  timeStr: timeController.text,
                                  location: locController.text,
                                  notes: notesController.text,
                                );
                            if (success) {
                              Get.back();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
