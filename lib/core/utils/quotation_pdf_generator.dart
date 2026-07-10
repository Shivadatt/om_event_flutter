import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../config/constants.dart';
import '../services/business_details_service.dart';
import '../../domain/entities/quotation.dart';

class QuotationPdfGenerator {
  QuotationPdfGenerator._();

  static Future<List<int>> generate(Quotation quote) async {
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
                "CELEBRATION PROPOSAL (v${quote.version})",
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
