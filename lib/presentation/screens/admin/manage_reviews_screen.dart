import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io' as io;
import '../../../core/config/app_theme.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/review_model.dart';
import '../../../data/datasources/supabase_storage_source.dart';
import 'widgets/admin_back_button.dart';

class ManageReviewsScreen extends GetView<AdminController> {
  const ManageReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1714),
      appBar: AppBar(
        leading: const AdminBackButton(),
        title: Text(
          "CUSTOMER REVIEWS",
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
            onPressed: () => _showReviewDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingReviews.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFC8A26A)),
            ),
          );
        }

        final reviews = controller.rxReviews;
        if (reviews.isEmpty) {
          return const Center(
            child: Text(
              "No customer reviews registered yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Sort reviews by displayOrder first, then createdAt desc
        final sortedReviews = List<ReviewModel>.from(reviews);
        sortedReviews.sort((a, b) {
          final orderCompare = a.displayOrder.compareTo(b.displayOrder);
          if (orderCompare != 0) return orderCompare;
          return b.createdAt.compareTo(a.createdAt);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: sortedReviews.length,
          itemBuilder: (context, index) {
            final review = sortedReviews[index];
            return Card(
              color: const Color(0xFF162822),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: Color(0xFF254235)),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF0D1915),
                              radius: 18,
                              backgroundImage: review.imageUrl.isNotEmpty
                                  ? NetworkImage(review.imageUrl)
                                  : null,
                              child: review.imageUrl.isEmpty
                                  ? Text(
                                      review.customerName.isEmpty
                                          ? 'C'
                                          : review.customerName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFFC8A26A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      review.customerName,
                                      style: AppTheme.serifHeader(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (review.isVerified) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFFC8A26A),
                                        size: 14,
                                      ),
                                    ],
                                    if (review.isFeatured) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(200, 162, 106, 0.2),
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(
                                            color: const Color(0xFFC8A26A),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: const Text(
                                          "FEATURED",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Color(0xFFC8A26A),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  "${review.eventName} • Display Order: ${review.displayOrder}",
                                  style: AppTheme.sansBody(
                                    fontSize: 11,
                                    color: const Color(0xFFA4A9A7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(5, (starIdx) {
                            return Icon(
                              starIdx < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFC8A26A),
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.comment,
                      style: AppTheme.sansBody(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 16,
                          children: [
                            _statusToggle("Published", review.isPublished, (val) {
                              final updated = _copyWith(review, isPublished: val);
                              controller.saveReview(updated, isEdit: true);
                            }),
                            _statusToggle("Featured", review.isFeatured, (val) {
                              final updated = _copyWith(review, isFeatured: val);
                              controller.saveReview(updated, isEdit: true);
                            }),
                            _statusToggle("Active", review.isActive, (val) {
                              final updated = _copyWith(review, isActive: val);
                              controller.saveReview(updated, isEdit: true);
                            }),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Color(0xFFA4A9A7),
                              ),
                              onPressed: () => _showReviewDialog(context, review: review),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => controller.deleteReview(review.id),
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

  Widget _statusToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFA4A9A7),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          height: 30,
          child: Switch(
            value: value,
            activeColor: const Color(0xFFC8A26A),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showReviewDialog(BuildContext context, {ReviewModel? review}) {
    final isEdit = review != null;
    final nameCtrl = TextEditingController(text: review?.customerName ?? '');
    final eventCtrl = TextEditingController(text: review?.eventName ?? '');
    final commentCtrl = TextEditingController(text: review?.comment ?? '');
    final imgUrlCtrl = TextEditingController(text: review?.imageUrl ?? '');
    final orderCtrl = TextEditingController(text: (review?.displayOrder ?? 1).toString());
    double ratingVal = (review?.rating ?? 5).toDouble();

    bool isPublishedVal = review?.isPublished ?? true;
    bool isFeaturedVal = review?.isFeatured ?? false;
    bool isVerifiedVal = review?.isVerified ?? true;
    bool isActiveVal = review?.isActive ?? true;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF162822),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF254235)),
        ),
        title: Text(
          isEdit ? "EDIT REVIEW" : "ADD REVIEW",
          style: const TextStyle(
            color: Color(0xFFC8A26A),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            bool isUploading = false;

            Future<void> pickAndUploadImage() async {
              try {
                final result = await FilePicker.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                  withData: true,
                );

                if (result == null) return;

                setState(() {
                  isUploading = true;
                });

                final file = result.files.single;
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
                  bucket: 'thumbnails',
                );

                setState(() {
                  imgUrlCtrl.text = publicUrl;
                });

                Get.snackbar(
                  "Upload Successful",
                  "Customer profile image uploaded successfully.",
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
                setState(() {
                  isUploading = false;
                });
              }
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildField("Customer Name *", nameCtrl),
                  const SizedBox(height: 12),
                  _buildField("Event Name *", eventCtrl),
                  const SizedBox(height: 12),
                  _buildField("Comment *", commentCtrl, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildField("Display Order", orderCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField("Customer Profile Image URL", imgUrlCtrl),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF254235),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          onPressed: isUploading ? null : pickAndUploadImage,
                          child: isUploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text("UPLOAD", style: TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Rating (Stars)",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      DropdownButton<double>(
                        value: ratingVal,
                        dropdownColor: const Color(0xFF162822),
                        items: [5.0, 4.0, 3.0, 2.0, 1.0].map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.toInt().toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              ratingVal = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text("Published", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: isPublishedVal,
                    activeColor: const Color(0xFFC8A26A),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        isPublishedVal = val ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Featured", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: isFeaturedVal,
                    activeColor: const Color(0xFFC8A26A),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        isFeaturedVal = val ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Verified Customer", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: isVerifiedVal,
                    activeColor: const Color(0xFFC8A26A),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        isVerifiedVal = val ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Active (Show)", style: TextStyle(color: Colors.white, fontSize: 12)),
                    value: isActiveVal,
                    activeColor: const Color(0xFFC8A26A),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        isActiveVal = val ?? true;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC8A26A),
            ),
            onPressed: () {
              if (nameCtrl.text.isEmpty || eventCtrl.text.isEmpty || commentCtrl.text.isEmpty) {
                Get.snackbar("Validation Error", "All fields with * are required.");
                return;
              }
              final newReview = ReviewModel(
                id: review?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                customerName: nameCtrl.text.trim(),
                eventName: eventCtrl.text.trim(),
                rating: ratingVal.toInt(),
                comment: commentCtrl.text.trim(),
                imageUrl: imgUrlCtrl.text.trim(),
                isVerified: isVerifiedVal,
                isPublished: isPublishedVal,
                isFeatured: isFeaturedVal,
                displayOrder: int.tryParse(orderCtrl.text) ?? 1,
                isActive: isActiveVal,
                createdAt: review?.createdAt ?? DateTime.now(),
              );
              controller.saveReview(newReview, isEdit: isEdit);
              Get.back();
            },
            child: const Text(
              "SAVE",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFC8A26A),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: const InputDecoration(
            fillColor: Color(0xFF0D1915),
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF254235)),
            ),
          ),
        ),
      ],
    );
  }

  ReviewModel _copyWith(
    ReviewModel r, {
    bool? isPublished,
    bool? isFeatured,
    bool? isActive,
    int? displayOrder,
  }) {
    return ReviewModel(
      id: r.id,
      customerName: r.customerName,
      eventName: r.eventName,
      rating: r.rating,
      comment: r.comment,
      imageUrl: r.imageUrl,
      isVerified: r.isVerified,
      isPublished: isPublished ?? r.isPublished,
      isFeatured: isFeatured ?? r.isFeatured,
      displayOrder: displayOrder ?? r.displayOrder,
      isActive: isActive ?? r.isActive,
      experienceId: r.experienceId,
      createdAt: r.createdAt,
    );
  }
}
