import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/catalog_controller.dart';

class ManageExperiencesScreen extends StatelessWidget {
  const ManageExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogController = Get.find<CatalogController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MANAGE CATALOG",
          style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
      ),
      body: Obx(() {
        final items = catalogController.rxExperiences;
        if (items.isEmpty) {
          return const Center(child: Text("No items loaded."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: isDark ? AppTheme.darkPaper : AppTheme.lightPaper,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade800,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTheme.serifHeader(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(item.categoryName, style: AppTheme.sansBody(fontSize: 11, color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted)),
                          const SizedBox(height: 4),
                          Text(AppFormatters.formatCurrency(item.effectivePrice), style: AppTheme.sansBody(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text("Active", style: TextStyle(fontSize: 10)),
                            Switch(
                              value: item.isActive,
                              onChanged: (val) async {
                                try {
                                  await FirebaseFirestore.instance.collection('experiences').doc(item.id).update({
                                    'isActive': val,
                                  });
                                  catalogController.loadExperiences();
                                  Get.snackbar("Success", "Catalog status updated.");
                                } catch (e) {
                                  Get.snackbar("Error", e.toString());
                                }
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Featured", style: TextStyle(fontSize: 10)),
                            Switch(
                              value: item.isFeatured,
                              onChanged: (val) async {
                                try {
                                  await FirebaseFirestore.instance.collection('experiences').doc(item.id).update({
                                    'isFeatured': val,
                                  });
                                  catalogController.loadExperiences();
                                  Get.snackbar("Success", "Featured status updated.");
                                } catch (e) {
                                  Get.snackbar("Error", e.toString());
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    )
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
