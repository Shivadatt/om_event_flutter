import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/helpers/supabase_mapper.dart';
import '../../../../../core/config/app_theme.dart';
import '../../../../../domain/entities/customer_quotation.dart';
import '../../../../controllers/customer_dashboard_controller.dart';

/// Quotations management tab view for customers.
class QuotesView extends StatelessWidget {
  final CustomerDashboardController controller;
  final Function(String) onRequestRevision;

  const QuotesView({
    super.key,
    required this.controller,
    required this.onRequestRevision,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("My Quotations", style: AppTheme.serifHeader(fontSize: 24)),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.rxQuotations.isEmpty) {
                return Center(
                  child: Text("No quotations received yet.", style: AppTheme.sansBody(fontSize: 14, color: Colors.white54)),
                );
              }
              return ListView.builder(
                itemCount: controller.rxQuotations.length,
                itemBuilder: (context, index) {
                  final quote = controller.rxQuotations[index];
                  return Card(
                    color: const Color(0xFF12271F),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      iconColor: const Color(0xFFC9A77E),
                      collapsedIconColor: Colors.white70,
                      title: Text(quote.quotationNumber, style: AppTheme.serifHeader(fontSize: 16)),
                      subtitle: Text("Amount: ₹${quote.amount.toStringAsFixed(2)} | Expiry: ${quote.expiryDate.toLocal().toString().split(' ')[0]}"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${quote.status.toUpperCase()}", style: AppTheme.serifHeader(fontSize: 14, color: _getStatusColor(quote.status))),
                              const SizedBox(height: 12),
                              if (quote.notes.isNotEmpty) ...[
                                Text("Notes: ${quote.notes}", style: AppTheme.sansBody(fontSize: 13)),
                                const SizedBox(height: 12),
                              ],

                              // List of items in this quotation rendered as homepage-style cards
                              if (quote.items.isNotEmpty) ...[
                                const Text("DECORATION ITEMS SELECTED", style: TextStyle(color: Color(0xFFC9A77E), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                const SizedBox(height: 8),
                                ...quote.items.map((item) => QuotationItemCard(item: item)),
                                const SizedBox(height: 12),
                              ],

                              Row(
                                children: [
                                  if (quote.status == 'pending') ...[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => controller.rejectQuotation(quote.id),
                                      child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (quote.pdfUrl.isNotEmpty)
                                    TextButton.icon(
                                      icon: const Icon(Icons.download, color: Color(0xFFC9A77E)),
                                      label: const Text("Download PDF", style: TextStyle(color: Color(0xFFC9A77E))),
                                      onPressed: () {
                                        Get.snackbar("Download Started", "Downloading proposal documents...");
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'approved':
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.white54;
    }
  }
}

/// A premium list card representing a quotation decoration item styled exactly like a homepage concept card.
class QuotationItemCard extends StatelessWidget {
  final CustomerQuotationItem item;

  const QuotationItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return FutureBuilder<Map<String, dynamic>?>(
      future: client.from('experiences').select().eq('id', item.experienceId).maybeSingle(),
      builder: (context, snapshot) {
        String imageUrl = '';
        String description = 'Premium custom event decoration concept.';
        String category = 'Decoration';
        double duration = 3.0;
        bool isFeatured = false;

        if (snapshot.hasData && snapshot.data != null) {
          final data = SupabaseMapper.toCamelCase(snapshot.data!);
          imageUrl = data['imageUrl'] ?? data['image_url'] ?? '';
          description = data['description'] ?? '';
          category = data['categoryName'] ?? data['category_name'] ?? 'Decoration';
          duration = (data['durationHours'] ?? data['duration_hours'] as num?)?.toDouble() ?? 3.0;
          isFeatured = data['isFeatured'] ?? data['is_featured'] ?? false;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1914),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withAlpha(13)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Image with MOST LOVED badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  if (isFeatured)
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        color: const Color(0xEBFAF5EE),
                        child: const Text(
                          "MOST LOVED",
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28322E),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Right: Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${category.toUpperCase()} · ${duration.toStringAsFixed(0)} HRS",
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFAA7C4B),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: GoogleFonts.italiana(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Selected Customizations badge row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.color.isNotEmpty)
                          _buildBadge("Color: ${item.color}"),
                        if (item.theme.isNotEmpty)
                          _buildBadge("Theme: ${item.theme}"),
                        if (item.notes.isNotEmpty)
                          _buildBadge("Notes: ${item.notes}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Qty and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Qty: ${item.quantity}",
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        Text(
                          "₹${item.unitPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC9A77E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.white.withAlpha(13),
      alignment: Alignment.center,
      child: const Icon(Icons.image, color: Colors.white24, size: 24),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x1FC9A77E),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x3DC9A77E)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFFC9A77E),
        ),
      ),
    );
  }
}
