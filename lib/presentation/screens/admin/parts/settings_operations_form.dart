part of '../system_settings_screen.dart';

extension _SettingsOperationsFormExtension on _SystemSettingsScreenState {
  Widget _buildThemeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("THEME STYLES", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Primary Hex Color", _themePrimary),
        _field("Secondary Hex Color", _themeSecondary),
        _field("Accent Hex Color", _themeAccent),
        _field("Default Border Radius", _themeRadius),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('theme', () async {
                final current = AppConfigService.to.rxThemeSettings.value;
                await _repository.saveTheme(
                  ThemeSettings(
                    primaryColor: _themePrimary.text,
                    secondaryColor: _themeSecondary.text,
                    accentColor: _themeAccent.text,
                    darkColors: current.darkColors,
                    lightColors: current.lightColors,
                    typography: current.typography,
                    borderRadius:
                        double.tryParse(_themeRadius.text) ??
                        current.borderRadius,
                    buttonStyle: current.buttonStyle,
                    cardStyle: current.cardStyle,
                    animationSpeed: current.animationSpeed,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildPricingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PRICING & GST RULES", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("GST percentage", _priceGST),
        _field("Flat delivery charge", _priceDelivery),
        _field("Travel charge per km", _priceTravel),
        _field("Default discount amount", _priceDiscount),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('pricing', () async {
                final current = AppConfigService.to.rxPricingSettings.value;
                await _repository.savePricing(
                  PricingSettings(
                    gst: double.tryParse(_priceGST.text) ?? current.gst,
                    deliveryCharge:
                        double.tryParse(_priceDelivery.text) ??
                        current.deliveryCharge,
                    travelCharge:
                        double.tryParse(_priceTravel.text) ??
                        current.travelCharge,
                    discount:
                        double.tryParse(_priceDiscount.text) ??
                        current.discount,
                    coupons: current.coupons,
                    advanceAmount: current.advanceAmount,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildBookingForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BOOKING PROTOCOLS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Advance Booking Offset Days", _bookingAdvanceDays),
        _field("Business hours", _bookingWorkingHours),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('booking', () async {
                final current = AppConfigService.to.rxBookingSettings.value;
                await _repository.saveBooking(
                  BookingSettings(
                    bookingRules: current.bookingRules,
                    advanceDays:
                        int.tryParse(_bookingAdvanceDays.text) ??
                        current.advanceDays,
                    workingHours: _bookingWorkingHours.text,
                    cancellationRules: current.cancellationRules,
                    refundRules: current.refundRules,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildPDFForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("PDF ESTIMATE CONFIG", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Invoice Document Header", _pdfHeader),
        _field("Invoice Document Footer", _pdfFooter),
        _field("Invoice Terms conditions", _pdfTerms),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('pdf', () async {
                final current = AppConfigService.to.rxPDFSettings.value;
                await _repository.savePDF(
                  PDFSettings(
                    invoiceHeader: _pdfHeader.text,
                    invoiceFooter: _pdfFooter.text,
                    terms: _pdfTerms.text,
                    bankDetails: current.bankDetails,
                    upi: current.upi,
                    signature: current.signature,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildInvoiceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INVOICE SETTINGS", style: GoogleFonts.italiana(fontSize: 24)),
        const SizedBox(height: 24),
        _field("Tax Registration ID", _invoiceTax),
        _field("Default Invoice Note", _invoiceNote),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('invoice', () async {
                await _repository.saveInvoice(
                  InvoiceSettings(
                    taxNumber: _invoiceTax.text,
                    invoiceNote: _invoiceNote.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildWorkingHoursForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "BUSINESS HOURS & HOLIDAYS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Holiday Lists (comma separated)", _workHolidays),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('working_hours', () async {
                final current =
                    AppConfigService.to.rxWorkingHoursSettings.value;
                await _repository.saveWorkingHours(
                  WorkingHoursSettings(
                    weekdayHours: current.weekdayHours,
                    holidays:
                        _workHolidays.text
                            .split(",")
                            .map((s) => s.trim())
                            .toList(),
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }

  Widget _buildPoliciesForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "LEGAL POLICIES & TERMS",
          style: GoogleFonts.italiana(fontSize: 24),
        ),
        const SizedBox(height: 24),
        _field("Privacy Policy", _policyPrivacy),
        _field("Terms of Service", _policyTerms),
        _field("Refund Policy", _policyRefund),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              () => _saveAndPublish('policies', () async {
                await _repository.savePolicies(
                  PoliciesSettings(
                    privacyPolicy: _policyPrivacy.text,
                    termsOfService: _policyTerms.text,
                    refundPolicy: _policyRefund.text,
                  ),
                );
              }),
          child: const Text("Save & Publish Live"),
        ),
      ],
    );
  }
}
