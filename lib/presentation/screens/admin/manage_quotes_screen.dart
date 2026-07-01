import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import 'widgets/admin_back_button.dart';

class ManageQuotesScreen extends GetView<AdminController> {
  const ManageQuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "SAVED QUOTATIONS",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        final quotes = controller.rxQuotes;
        if (quotes.isEmpty) {
          return const Center(child: Text("No quotations generated yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: quotes.length,
          itemBuilder: (context, index) {
            final quote = quotes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          quote.publicId.toUpperCase(),
                          style: AppTheme.sansBody(
                            fontSize: 9,
                            color:
                                isDark ? AppTheme.darkGold : AppTheme.lightGold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        DropdownButton<String>(
                          value: quote.status,
                          items: const [
                            DropdownMenuItem(
                              value: 'draft',
                              child: Text("Draft"),
                            ),
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text("Pending"),
                            ),
                            DropdownMenuItem(
                              value: 'accepted',
                              child: Text("Accepted"),
                            ),
                            DropdownMenuItem(
                              value: 'expired',
                              child: Text("Expired"),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.updateQuotation(quote.id, val);
                            }
                          },
                          style: const TextStyle(fontSize: 12),
                          underline: const SizedBox(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quote.customerName,
                      style: AppTheme.serifHeader(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Phone: ${quote.customerPhone}",
                      style: AppTheme.sansBody(fontSize: 13),
                    ),
                    Text(
                      "Location: ${quote.location}",
                      style: AppTheme.sansBody(fontSize: 13),
                    ),
                    Text(
                      "Event Date: ${AppFormatters.formatShortDate(quote.eventDate)} at ${quote.eventTime}",
                      style: AppTheme.sansBody(fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total: ${AppFormatters.formatCurrency(quote.grandTotal)}",
                          style: AppTheme.sansBody(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (quote.pdfUrl.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 16,
                            ),
                            label: const Text(
                              "VIEW PDF",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final uri = Uri.parse(quote.pdfUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
