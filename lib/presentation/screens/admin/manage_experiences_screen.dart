// ignore_for_file: avoid_print
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../controllers/admin_controller.dart';
import '../../../domain/entities/experience.dart';
import '../../../data/datasources/supabase_storage_source.dart';
import 'widgets/admin_back_button.dart';

class ManageExperiencesScreen extends GetView<AdminController> {
  const ManageExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const AdminBackButton(),
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
      categoryIds: item.categoryIds,
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

    final selectedCategoryIds = <String>{};
    if (experience != null) {
      selectedCategoryIds.addAll(experience.categoryIds);
      if (selectedCategoryIds.isEmpty && experience.categoryId.isNotEmpty) {
        selectedCategoryIds.add(experience.categoryId);
      }
    } else if (controller.rxCategories.isNotEmpty) {
      selectedCategoryIds.add(controller.rxCategories.first.id);
    }

    String availability = experience?.availability ?? 'available';
    bool isActive = experience?.isActive ?? true;
    bool isFeatured = experience?.isFeatured ?? false;

    // Debug logs as requested by the user
    if (isEdit) {
      print("Firestore Document Loaded");
      print("Experience ID: ${experience.id}");
      print("Name: ${experience.name}");
      print("Slug: ${experience.slug}");
      print("category_id: ${experience.categoryId}");
      print("category_ids: ${experience.categoryIds}");
    }
    print("TextControllers initialized");
    print("Selected Categories Count: ${selectedCategoryIds.length}");
    print("Categories Checked: $selectedCategoryIds");

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
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Categories",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      children: controller.rxCategories.map((cat) {
                        final isChecked = selectedCategoryIds.contains(cat.id);
                        return CheckboxListTile(
                          title: Text(cat.name),
                          value: isChecked,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (bool? val) {
                            setState(() {
                              if (val == true) {
                                selectedCategoryIds.add(cat.id);
                              } else {
                                if (selectedCategoryIds.length > 1) {
                                  selectedCategoryIds.remove(cat.id);
                                } else {
                                  Get.snackbar(
                                    "Validation Error",
                                    "At least one category must be selected.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
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
                  StatefulBuilder(
                    builder: (context, setUploadState) {
                      bool isUploadingImage = false;
                      bool isUploadingVideo = false;

                      Future<void> uploadExperienceImage() async {
                        try {
                          final result = await FilePicker.pickFiles(
                            type: FileType.image,
                            allowMultiple: false,
                            withData: true,
                          );
                          if (result == null || result.files.isEmpty) return;

                          setUploadState(() {
                            isUploadingImage = true;
                          });

                          final file = result.files.first;
                          final fileName = file.name;

                          List<int> fileBytes;
                          if (file.bytes != null) {
                            fileBytes = file.bytes!;
                          } else if (file.path != null) {
                            final dartFile = io.File(file.path!);
                            fileBytes = await dartFile.readAsBytes();
                          } else {
                            throw Exception("Could not read file data.");
                          }

                          String contentType = 'image/jpeg';
                          if (fileName.toLowerCase().endsWith('.png')) {
                            contentType = 'image/png';
                          }

                          final storage = Get.find<SupabaseStorageSource>();
                          final publicUrl = await storage.uploadFile(
                            'images/$fileName',
                            fileBytes,
                            contentType,
                            bucket: 'gallery',
                          );

                          setState(() {
                            imgCtrl.text = publicUrl;
                          });

                          Get.snackbar(
                            "Upload Successful",
                            "Experience image uploaded to Supabase gallery.",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          Get.snackbar(
                            "Upload Failed",
                            e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade900,
                            colorText: Colors.white,
                          );
                        } finally {
                          setUploadState(() {
                            isUploadingImage = false;
                          });
                        }
                      }

                      Future<void> uploadExperienceVideo() async {
                        try {
                          final result = await FilePicker.pickFiles(
                            type: FileType.video,
                            allowMultiple: false,
                            withData: true,
                          );
                          if (result == null || result.files.isEmpty) return;

                          setUploadState(() {
                            isUploadingVideo = true;
                          });

                          final file = result.files.first;
                          final fileName = file.name;

                          List<int> fileBytes;
                          if (file.bytes != null) {
                            fileBytes = file.bytes!;
                          } else if (file.path != null) {
                            final dartFile = io.File(file.path!);
                            fileBytes = await dartFile.readAsBytes();
                          } else {
                            throw Exception("Could not read file data.");
                          }

                          String contentType = 'video/mp4';
                          if (fileName.toLowerCase().endsWith('.mov')) {
                            contentType = 'video/quicktime';
                          } else if (fileName.toLowerCase().endsWith('.avi')) {
                            contentType = 'video/x-msvideo';
                          }

                          final storage = Get.find<SupabaseStorageSource>();
                          final publicUrl = await storage.uploadFile(
                            'Video/$fileName',
                            fileBytes,
                            contentType,
                            bucket: 'gallery',
                          );

                          setState(() {
                            vidCtrl.text = publicUrl;
                          });

                          Get.snackbar(
                            "Upload Successful",
                            "Experience video uploaded to Supabase gallery.",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          Get.snackbar(
                            "Upload Failed",
                            e.toString(),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade900,
                            colorText: Colors.white,
                          );
                        } finally {
                          setUploadState(() {
                            isUploadingVideo = false;
                          });
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Experience Image Preview",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: isUploadingImage ? null : uploadExperienceImage,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: isUploadingImage
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFC79B61),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                "Uploading image to Supabase...",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : imgCtrl.text.isNotEmpty
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                imgCtrl.text.startsWith('assets/')
                                                    ? Image.asset(
                                                        imgCtrl.text,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.network(
                                                        imgCtrl.text,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                const Center(
                                                                  child: Icon(
                                                                    Icons
                                                                        .broken_image_outlined,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                ),
                                                      ),
                                                Container(
                                                  color: Colors.black45,
                                                ),
                                                const Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .cloud_upload_outlined,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "Click to Change Image",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.cloud_upload_outlined,
                                                    color: Colors.grey,
                                                    size: 36,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Click to Upload Experience Image",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "(Saves to Supabase gallery/images)",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Experience Video Preview",
                            style: AppTheme.sansBody(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: isUploadingVideo ? null : uploadExperienceVideo,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: isUploadingVideo
                                      ? const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFFC79B61),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                "Uploading video to Supabase...",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : vidCtrl.text.isNotEmpty
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Container(
                                                  color: Colors.black54,
                                                ),
                                                Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.video_library,
                                                        color: Color(0xFFC79B61),
                                                        size: 32,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        vidCtrl.text.split('/').last,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      const Text(
                                                        "Click to Change Video",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.video_call_outlined,
                                                    color: Colors.grey,
                                                    size: 36,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Click to Upload Experience Video",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "(Saves to Supabase gallery/Video)",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
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
                      selectedCategoryIds.isEmpty) {
                    Get.snackbar(
                      "Validation Error",
                      "Name, Slug and Category are required.",
                    );
                    return;
                  }
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final offerPrice = double.tryParse(offerCtrl.text);
                  final duration = double.tryParse(durCtrl.text) ?? 3.0;

                  final firstCatId = selectedCategoryIds.first;
                  final cat = controller.rxCategories.firstWhere(
                    (c) => c.id == firstCatId,
                  );

                  print("Saving category_ids: ${selectedCategoryIds.toList()}");
                  print("Saving category_id: ${cat.id}");

                  final updated = Experience(
                    id: experience?.id ?? slugCtrl.text,
                    categoryId: cat.id,
                    categoryName: cat.name,
                    categorySlug: cat.slug,
                    categoryIds: selectedCategoryIds.toList(),
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
