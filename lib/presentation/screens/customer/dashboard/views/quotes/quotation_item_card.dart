import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:om_event/core/constants/app_collections.dart';
import 'package:om_event/core/widgets/app_image.dart';
import 'package:om_event/domain/entities/quotation.dart';

/// A premium list card representing a quotation decoration item.
class QuotationItemCard extends StatelessWidget {
  final QuotationItem item;

  const QuotationItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final db = Get.find<FirebaseFirestore>();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: db.collection(AppCollections.items).doc(item.experienceId).get(),
      builder: (context, snapshot) {
        String imageUrl = '';
        String category = 'Decoration';
        double duration = 3.0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data()!;
          imageUrl = data['imageUrl'] ?? data['image_url'] ?? '';
          category = data['categoryName'] ?? data['category_name'] ?? 'Decoration';
          duration = (data['durationHours'] ?? data['duration_hours'] as num?)?.toDouble() ?? 3.0;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0D0B), // Matte Black base
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AD4AF37)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x1AD4AF37)),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? AppImage(
                          url: imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.white10,
                          child: const Icon(Icons.image, color: Colors.white24, size: 20),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${category.toUpperCase()} · ${duration.toStringAsFixed(0)} HRS",
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          "₹${item.unitPrice.toStringAsFixed(0)}",
                          style: GoogleFonts.italiana(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.italiana(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.color.isNotEmpty)
                          _buildBadge("Color: ${item.color}"),
                        if (item.theme.isNotEmpty)
                          _buildBadge("Theme: ${item.theme}"),
                        _buildBadge("Qty: ${item.quantity}"),
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

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x0AD4AF37),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0x1AD4AF37)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          color: Color(0xFFE6C98D),
        ),
      ),
    );
  }
}
