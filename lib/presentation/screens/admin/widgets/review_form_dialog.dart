import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../data/models/review_model.dart';
import '../../../controllers/admin_controller.dart';
import '../../../../data/datasources/supabase_storage_source.dart';

class ReviewFormDialog extends StatefulWidget {
  final ReviewModel? review;
  final AdminController controller;

  const ReviewFormDialog({
    super.key,
    this.review,
    required this.controller,
  });

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  late bool isEdit;
  late TextEditingController nameCtrl;
  late TextEditingController eventCtrl;
  late TextEditingController commentCtrl;
  late TextEditingController imgUrlCtrl;
  late TextEditingController orderCtrl;
  late double ratingVal;

  late bool isPublishedVal;
  late bool isFeaturedVal;
  late bool isVerifiedVal;
  late bool isActiveVal;

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    final rev = widget.review;
    isEdit = rev != null;

    nameCtrl = TextEditingController(text: rev?.customerName ?? '');
    eventCtrl = TextEditingController(text: rev?.eventName ?? '');
    commentCtrl = TextEditingController(text: rev?.comment ?? '');
    imgUrlCtrl = TextEditingController(text: rev?.imageUrl ?? '');
    orderCtrl = TextEditingController(text: (rev?.displayOrder ?? 1).toString());
    ratingVal = (rev?.rating ?? 5).toDouble();

    isPublishedVal = rev?.isPublished ?? true;
    isFeaturedVal = rev?.isFeatured ?? false;
    isVerifiedVal = rev?.isVerified ?? true;
    isActiveVal = rev?.isActive ?? true;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    eventCtrl.dispose();
    commentCtrl.dispose();
    imgUrlCtrl.dispose();
    orderCtrl.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
      content: SingleChildScrollView(
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
              id: widget.review?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
              experienceId: widget.review?.experienceId,
              createdAt: widget.review?.createdAt ?? DateTime.now(),
            );
            widget.controller.saveReview(newReview, isEdit: isEdit);
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
    );
  }
}
