import 'dart:math';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/config/app_routes.dart';
import '../../core/config/constants.dart';
import '../../core/utils/validators.dart';

import '../../domain/entities/quotation.dart';
import '../../domain/usecases/create_quotation.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../core/utils/app_logger.dart';
import '../../core/services/business_details_service.dart';
import 'cart_controller.dart';

class QuotationController extends GetxController {
  final CreateQuotation createQuotationUsecase;
  final QuotationRepository quotationRepository;
  final CartController cartController;

  QuotationController({
    required this.createQuotationUsecase,
    required this.quotationRepository,
    required this.cartController,
  });

  final isGeneratingQuote = false.obs;
  final rxCreatedQuotation = Rxn<Quotation>();

  // Generate Alphanumeric Public ID
  String _generatePublicId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  // Submit Quotation
  Future<bool> submitQuotationRequest({
    required String name,
    required String phone,
    required String dateStr,
    required String timeStr,
    required String location,
    required String notes,
  }) async {
    if (!AppValidators.isValidName(name)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid name (at least 2 letters).",
      );
      return false;
    }
    if (!AppValidators.isValidPhone(phone)) {
      Get.snackbar(
        "Validation Error",
        "Please enter a valid 10-digit phone number.",
      );
      return false;
    }
    if (location.trim().isEmpty) {
      Get.snackbar("Validation Error", "Please specify the venue or location.");
      return false;
    }
    if (cartController.rxCartItems.isEmpty) {
      Get.snackbar(
        "Canvas is Empty",
        "Please select at least one decoration to generate a quotation.",
      );
      return false;
    }

    try {
      isGeneratingQuote.value = true;

      final cleanedPhone = AppValidators.cleanPhone(phone);
      final eventDate = DateTime.tryParse(dateStr) ?? DateTime.now();
      final publicId = _generatePublicId().toUpperCase();
      final quotationId = DateTime.now().millisecondsSinceEpoch.toString();

      // Maps Cart Items to Quotation Items
      final quotationItems =
          cartController.rxCartItems.map((cartItem) {
            return QuotationItem(
              experienceId: cartItem.experience.id,
              name: cartItem.experience.name,
              quantity: cartItem.quantity,
              unitPrice: cartItem.experience.effectivePrice,
              color: cartItem.color.isEmpty ? "As shown" : cartItem.color,
              theme: cartItem.theme.isEmpty ? "As shown" : cartItem.theme,
              notes: cartItem.notes,
            );
          }).toList();

      // Calculation values matching backend standard
      final subtotal = cartController.subtotal;
      final discount = cartController.volumeDiscount;
      final delivery = cartController.deliveryCharge;
      final travel = cartController.travelCharge;

      // Note: We use standard server calculations for the database record
      // to ensure billing consistency
      final taxable = subtotal - discount + delivery + travel;
      final gstAmount = taxable * (AppConstants.gstPercent / 100.0);
      final grandTotal = taxable + gstAmount;

      final partialQuotation = Quotation(
        id: quotationId,
        publicId: publicId,
        customerPhone: cleanedPhone,
        customerName: name.trim(),
        eventDate: eventDate,
        eventTime: timeStr,
        location: location.trim(),
        notes: notes.trim(),
        subtotal: subtotal,
        discount: discount,
        deliveryCharge: delivery,
        travelCharge: travel,
        gstPercent: AppConstants.gstPercent,
        gstAmount: gstAmount,
        grandTotal: grandTotal,
        pdfUrl: '', // Updated post upload
        status: 'draft',
        items: quotationItems,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Generate invoice PDF
      final pdfBytes = await _generateInvoicePdf(partialQuotation);

      // Upload to Supabase Storage
      String uploadedPdfUrl = '';
      try {
        uploadedPdfUrl = await quotationRepository.uploadQuotationPdf(
          publicId,
          pdfBytes,
        );
      } catch (e) {
        // Fallback or log if Supabase keys not set
        AppLogger.error("Supabase upload error", e);
      }

      final finalQuotation = Quotation(
        id: partialQuotation.id,
        publicId: partialQuotation.publicId,
        customerPhone: partialQuotation.customerPhone,
        customerName: partialQuotation.customerName,
        eventDate: partialQuotation.eventDate,
        eventTime: partialQuotation.eventTime,
        location: partialQuotation.location,
        notes: partialQuotation.notes,
        subtotal: partialQuotation.subtotal,
        discount: partialQuotation.discount,
        deliveryCharge: partialQuotation.deliveryCharge,
        travelCharge: partialQuotation.travelCharge,
        gstPercent: partialQuotation.gstPercent,
        gstAmount: partialQuotation.gstAmount,
        grandTotal: partialQuotation.grandTotal,
        pdfUrl: uploadedPdfUrl,
        status: 'pending',
        items: partialQuotation.items,
        createdAt: partialQuotation.createdAt,
        updatedAt: partialQuotation.updatedAt,
      );

      // Save to Cloud Firestore
      await createQuotationUsecase(finalQuotation);

      rxCreatedQuotation.value = finalQuotation;

      // Reset selection drawer
      cartController.clearCart();

      // Route to success view
      Get.offNamed(AppRoutes.quoteSuccess);
      return true;
    } catch (e) {
      Get.snackbar("Failed", "Quotation failed: ${e.toString()}");
      return false;
    } finally {
      isGeneratingQuote.value = false;
    }
  }

  // Branded Client-side PDF Invoice Generator using pdf package
  Future<List<int>> _generateInvoicePdf(Quotation quote) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Brand Title
              pw.Text(
                AppConstants.businessName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("#9A6B3D"),
                ),
              ),
              pw.Text(
                "CELEBRATION PROPOSAL",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("#1E2926"),
                ),
              ),
              pw.SizedBox(height: 12),

              // Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Prepared for: ${quote.customerName}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "Location: ${quote.location}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Proposal ID: ${quote.publicId}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "Event Date: ${quote.eventDate.year}-${quote.eventDate.month}-${quote.eventDate.day} at ${quote.eventTime}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),

              // Line Items Table
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor.fromHex("#D8D4CC"),
                  width: 0.5,
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Head
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex("#1E2926"),
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Decoration",
                          style: pw.TextStyle(
                            color: PdfColor.fromHex("#FFFFFF"),
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Customisation",
                          style: pw.TextStyle(
                            color: PdfColor.fromHex("#FFFFFF"),
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Qty",
                          style: pw.TextStyle(
                            color: PdfColor.fromHex("#FFFFFF"),
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(
                          "Amount",
                          style: pw.TextStyle(
                            color: PdfColor.fromHex("#FFFFFF"),
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...quote.items.map((item) {
                    final customStr = [
                      item.color,
                      item.theme,
                    ].where((e) => e.isNotEmpty).join(' · ');
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            item.name,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            customStr.isEmpty ? "As shown" : customStr,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            item.quantity.toString(),
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            "Rs. ${item.totalPrice.toStringAsFixed(0)}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 14),

              // Summary
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 200,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "Subtotal:",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            "Rs. ${quote.subtotal.toStringAsFixed(2)}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "Celebration Discount:",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            "- Rs. ${quote.discount.toStringAsFixed(2)}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "Delivery:",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            "Rs. ${quote.deliveryCharge.toStringAsFixed(2)}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "GST (${quote.gstPercent.toStringAsFixed(0)}%):",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            "Rs. ${quote.gstAmount.toStringAsFixed(2)}",
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      pw.Divider(
                        color: PdfColor.fromHex("#9A6B3D"),
                        thickness: 1,
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "GRAND TOTAL:",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            "Rs. ${quote.grandTotal.toStringAsFixed(2)}",
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              pw.Spacer(),

              // Footnotes
              pw.Center(
                child: pw.Text(
                  "This quotation is valid for 7 days. Final booking is confirmed after advance payment.",
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "${AppConstants.businessEmail}   •   ${BusinessDetailsService.to.rxDetails.value.contacts.phones.where((c) => c.isActive).map((c) => c.value).join(' / ')}",
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }
}
