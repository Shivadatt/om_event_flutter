import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/experience.dart';

class ManageExperiencesScreen extends GetView<AdminController> {
  const ManageExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MANAGE CATALOG",
          style: AppTheme.sansBody(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showExperienceDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingExperiences.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.rxExperiences;
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade900,
                      child:
                          item.imageUrl.isNotEmpty
                              ? Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.image, size: 20),
                              )
                              : const Icon(Icons.image, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTheme.serifHeader(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item.categoryName,
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              color:
                                  isDark
                                      ? AppTheme.darkMuted
                                      : AppTheme.lightMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppFormatters.formatCurrency(item.effectivePrice),
                            style: AppTheme.sansBody(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Active",
                              style: TextStyle(fontSize: 10),
                            ),
                            Switch(
                              value: item.isActive,
                              onChanged: (val) {
                                final updated = _copyWithActiveFeatured(
                                  item,
                                  active: val,
                                );
                                controller.saveExperience(
                                  updated,
                                  isEdit: true,
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Featured",
                              style: TextStyle(fontSize: 10),
                            ),
                            Switch(
                              value: item.isFeatured,
                              onChanged: (val) {
                                final updated = _copyWithActiveFeatured(
                                  item,
                                  featured: val,
                                );
                                controller.saveExperience(
                                  updated,
                                  isEdit: true,
                                );
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed:
                                  () => _showExperienceDialog(
                                    context,
                                    experience: item,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _confirmDelete(item.slug),
                            ),
                          ],
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

  Experience _copyWithActiveFeatured(
    Experience item, {
    bool? active,
    bool? featured,
  }) {
    return Experience(
      id: item.id,
      categoryId: item.categoryId,
      categoryName: item.categoryName,
      categorySlug: item.categorySlug,
      name: item.name,
      slug: item.slug,
      description: item.description,
      price: item.price,
      offerPrice: item.offerPrice,
      durationHours: item.durationHours,
      popularity: item.popularity,
      rating: item.rating,
      reviewCount: item.reviewCount,
      availability: item.availability,
      tags: item.tags,
      colors: item.colors,
      themes: item.themes,
      imageUrl: item.imageUrl,
      videoUrl: item.videoUrl,
      isFeatured: featured ?? item.isFeatured,
      isActive: active ?? item.isActive,
    );
  }

  void _confirmDelete(String slug) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Experience"),
        content: Text(
          "Are you sure you want to delete experience '$slug'? This will remove it from the catalog.",
        ),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Get.back()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
            onPressed: () {
              Get.back();
              controller.deleteExperience(slug);
            },
          ),
        ],
      ),
    );
  }

  void _showExperienceDialog(BuildContext context, {Experience? experience}) {
    final isEdit = experience != null;
    final nameCtrl = TextEditingController(text: experience?.name ?? '');
    final slugCtrl = TextEditingController(text: experience?.slug ?? '');
    final descCtrl = TextEditingController(text: experience?.description ?? '');
    final priceCtrl = TextEditingController(
      text: experience?.price.toString() ?? '',
    );
    final offerCtrl = TextEditingController(
      text: experience?.offerPrice?.toString() ?? '',
    );
    final durCtrl = TextEditingController(
      text: experience?.durationHours.toString() ?? '3',
    );
    final imgCtrl = TextEditingController(text: experience?.imageUrl ?? '');
    final vidCtrl = TextEditingController(text: experience?.videoUrl ?? '');

    final tagsCtrl = TextEditingController(
      text: experience?.tags.join(', ') ?? '',
    );
    final colorsCtrl = TextEditingController(
      text: experience?.colors.join(', ') ?? '',
    );
    final themesCtrl = TextEditingController(
      text: experience?.themes.join(', ') ?? '',
    );

    String? selectedCategoryId = experience?.categoryId;
    if (selectedCategoryId == null && controller.rxCategories.isNotEmpty) {
      selectedCategoryId = controller.rxCategories.first.id;
    }

    String availability = experience?.availability ?? 'available';
    bool isActive = experience?.isActive ?? true;
    bool isFeatured = experience?.isFeatured ?? false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? "Edit Experience" : "Add Experience"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                    onChanged: (val) {
                      if (!isEdit) {
                        slugCtrl.text = val
                            .toLowerCase()
                            .trim()
                            .replaceAll(RegExp(r'\s+'), '-')
                            .replaceAll(RegExp(r'[^a-z0-9\-]'), '');
                      }
                    },
                  ),
                  TextField(
                    controller: slugCtrl,
                    decoration: const InputDecoration(labelText: "Slug"),
                    enabled: !isEdit,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: "Category"),
                    items:
                        controller.rxCategories.map((c) {
                          return DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategoryId = val;
                      });
                    },
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: offerCtrl,
                    decoration: const InputDecoration(
                      labelText: "Offer Price (Discounted, Optional)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: durCtrl,
                    decoration: const InputDecoration(
                      labelText: "Duration (Hours)",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButtonFormField<String>(
                    value: availability,
                    decoration: const InputDecoration(
                      labelText: "Availability",
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text("Available"),
                      ),
                      DropdownMenuItem(
                        value: 'unavailable',
                        child: Text("Unavailable"),
                      ),
                      DropdownMenuItem(value: 'booked', child: Text("Booked")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          availability = val;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: "Tags (comma-separated)",
                    ),
                  ),
                  TextField(
                    controller: colorsCtrl,
                    decoration: const InputDecoration(
                      labelText: "Colors (comma-separated)",
                    ),
                  ),
                  TextField(
                    controller: themesCtrl,
                    decoration: const InputDecoration(
                      labelText: "Themes (comma-separated)",
                    ),
                  ),
                  TextField(
                    controller: imgCtrl,
                    decoration: const InputDecoration(labelText: "Image URL"),
                  ),
                  TextField(
                    controller: vidCtrl,
                    decoration: const InputDecoration(labelText: "Video URL"),
                  ),
                  SwitchListTile(
                    title: const Text("Is Active"),
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
                  ),
                  SwitchListTile(
                    title: const Text("Is Featured"),
                    value: isFeatured,
                    onChanged: (val) => setState(() => isFeatured = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Get.back(),
              ),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () {
                  if (nameCtrl.text.isEmpty ||
                      slugCtrl.text.isEmpty ||
                      selectedCategoryId == null) {
                    Get.snackbar(
                      "Validation Error",
                      "Name, Slug and Category are required.",
                    );
                    return;
                  }
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final offerPrice = double.tryParse(offerCtrl.text);
                  final duration = double.tryParse(durCtrl.text) ?? 3.0;

                  final cat = controller.rxCategories.firstWhere(
                    (c) => c.id == selectedCategoryId,
                  );

                  final updated = Experience(
                    id: experience?.id ?? slugCtrl.text,
                    categoryId: cat.id,
                    categoryName: cat.name,
                    categorySlug: cat.slug,
                    name: nameCtrl.text.trim(),
                    slug: slugCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    price: price,
                    offerPrice: offerPrice,
                    durationHours: duration,
                    popularity: experience?.popularity ?? 0,
                    rating: experience?.rating ?? 5.0,
                    reviewCount: experience?.reviewCount ?? 0,
                    availability: availability,
                    tags:
                        tagsCtrl.text
                            .split(',')
                            .map((t) => t.trim())
                            .where((t) => t.isNotEmpty)
                            .toList(),
                    colors:
                        colorsCtrl.text
                            .split(',')
                            .map((c) => c.trim())
                            .where((c) => c.isNotEmpty)
                            .toList(),
                    themes:
                        themesCtrl.text
                            .split(',')
                            .map((t) => t.trim())
                            .where((t) => t.isNotEmpty)
                            .toList(),
                    imageUrl: imgCtrl.text.trim(),
                    videoUrl: vidCtrl.text.trim(),
                    isFeatured: isFeatured,
                    isActive: isActive,
                  );

                  Get.back();
                  controller.saveExperience(updated, isEdit: isEdit);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
