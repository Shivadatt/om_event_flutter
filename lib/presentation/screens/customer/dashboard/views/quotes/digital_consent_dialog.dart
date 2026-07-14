import 'package:flutter/material.dart';
import 'package:om_event/core/config/app_theme.dart';
import 'package:om_event/core/utils/formatters.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// Modal dialog capturing digital consent checkbox and signatory name.
class DigitalConsentDialog extends StatefulWidget {
  final Quotation activeQuote;
  final Function(String signature) onAccept;

  const DigitalConsentDialog({
    super.key,
    required this.activeQuote,
    required this.onAccept,
  });

  @override
  State<DigitalConsentDialog> createState() => _DigitalConsentDialogState();
}

class _DigitalConsentDialogState extends State<DigitalConsentDialog> {
  bool _isAgreed = false;
  late TextEditingController _nameCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.activeQuote.customerName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Widget _buildConsentDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white30)),
          Text(val, style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF171411),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x33D4AF37)),
      ),
      title: Row(
        children: [
          const Icon(Icons.gavel_outlined, color: Color(0xFFD4AF37), size: 24),
          const SizedBox(width: 12),
          Text(
            "Digital Consent & Confirmation",
            style: AppTheme.serifHeader(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please review and sign the legal confirmation for this proposal.",
                style: AppTheme.sansBody(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConsentDetailRow("Quotation No", widget.activeQuote.publicId),
                    _buildConsentDetailRow("Version", "v${widget.activeQuote.version}"),
                    _buildConsentDetailRow("Grand Total", AppFormatters.formatCurrency(widget.activeQuote.grandTotal)),
                    _buildConsentDetailRow("Validity Until", AppFormatters.formatShortDate(widget.activeQuote.createdAt.add(const Duration(days: 7)))),
                    _buildConsentDetailRow("Customer Name", widget.activeQuote.customerName),
                    _buildConsentDetailRow("Event Date", AppFormatters.formatShortDate(widget.activeQuote.eventDate)),
                    _buildConsentDetailRow("Event Location", widget.activeQuote.location),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "LEGAL AGREEMENT",
                style: AppTheme.sansBody(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37), letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              Text(
                "\"I confirm that I have reviewed this quotation and agree with the pricing, services and terms.\"",
                style: AppTheme.sansBody(fontSize: 12, color: Colors.white).copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: "SIGNATORY FULL NAME",
                  labelStyle: AppTheme.sansBody(fontSize: 11, color: const Color(0xFFD4AF37)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Full name signature is required.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: const Color(0xFFD4AF37),
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white54),
                      onChanged: (val) {
                        setState(() {
                          _isAgreed = val ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "I understand that checking this box constitutes a legal digital signature of acceptance.",
                      style: TextStyle(fontSize: 10, color: Colors.white54, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL", style: TextStyle(fontSize: 11, color: Colors.white30, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF091210),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: AppTheme.sansBody(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          onPressed: _isAgreed
              ? () {
                  if (_formKey.currentState?.validate() == true) {
                    widget.onAccept(_nameCtrl.text.trim());
                    Navigator.pop(context);
                  }
                }
              : null,
          child: const Text("SIGN & SUBMIT"),
        ),
      ],
    );
  }
}
