part of '../customer_dialog_helper.dart';

extension CustomerBookingDialogs on CustomerDialogHelper {
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
                      validator: (val) => AppValidators.isValidName(val ?? '')
                          ? null
                          : "Please enter your name.",
                    ),
                    CustomInput(
                      label: "Phone Number",
                      placeholder: "10-digit mobile number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) => AppValidators.isValidPhone(val ?? '')
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
                            final success = await catalogController.requestCallback(
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
                      validator: (val) => AppValidators.isValidName(val ?? '')
                          ? null
                          : "Please enter your name.",
                    ),
                    CustomInput(
                      label: "Phone",
                      placeholder: "10-digit mobile number",
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (val) => AppValidators.isValidPhone(val ?? '')
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
                            readOnly: true,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now().add(const Duration(days: 7)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFFC9A77E),
                                        onPrimary: Color(0xFF091210),
                                        surface: Color(0xFF12271F),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                dateController.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              }
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Date required.";
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
                            readOnly: true,
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: const TimeOfDay(hour: 18, minute: 0),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFFC9A77E),
                                        onPrimary: Color(0xFF091210),
                                        surface: Color(0xFF12271F),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                timeController.text =
                                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        final options = [
                          "Sindhu Bhavan Hall, SBR, Ahmedabad",
                          "SG Highway Royal Palace, Ahmedabad",
                          "Club O7 Banquet, Shela, Ahmedabad",
                          "Kadi Community Center, Kadi, Gujarat",
                          "Thangadh Town Palace, Thangadh, Gujarat",
                          "Bopal Celebration Ground, Ahmedabad",
                          "Sabarmati Riverfront Event Center, Ahmedabad",
                          "Nikol Party Plot, Ahmedabad",
                        ];
                        return options.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        locController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        if (textEditingController.text.isEmpty && locController.text.isNotEmpty) {
                          textEditingController.text = locController.text;
                        }
                        textEditingController.addListener(() {
                          locController.text = textEditingController.text;
                        });
                        return CustomInput(
                          label: "Venue / Location",
                          placeholder: "Venue name, area and city",
                          controller: textEditingController,
                          validator: (val) => (val != null && val.trim().isNotEmpty) ? null : "Location required.",
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            color: const Color(0xFF12271F),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: const Color(0xFFC9A77E).withValues(alpha: 0.3)),
                            ),
                            child: SizedBox(
                              width: 440,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(index);
                                  return ListTile(
                                    hoverColor: Colors.white12,
                                    title: Text(option, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
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
                            final success = await quoteController.submitQuotationRequest(
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
