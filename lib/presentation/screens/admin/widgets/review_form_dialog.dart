import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const Color goldColor = Color(0xFFECC24A);

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

  void _onSave() {
    if (nameCtrl.text.trim().isEmpty ||
        eventCtrl.text.trim().isEmpty ||
        commentCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Validation Error",
        "All fields with * are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
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
      displayOrder: int.tryParse(orderCtrl.text.trim()) ?? 1,
      isActive: isActiveVal,
      experienceId: widget.review?.experienceId,
      createdAt: widget.review?.createdAt ?? DateTime.now(),
    );

    widget.controller.saveReview(newReview, isEdit: isEdit);
    Get.back();
  }

  Widget _buildIconBlock(IconData icon, {double size = 18}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF132820),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ReviewFormDialog.goldColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: ReviewFormDialog.goldColor,
          size: size,
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required IconData icon,
    required String label,
    required TextEditingController ctrl,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 48.0, bottom: 5),
          child: RichText(
            text: TextSpan(
              text: label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: ReviewFormDialog.goldColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Row(
          crossAxisAlignment:
              maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            _buildIconBlock(icon),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: maxLines > 1 ? 76 : 40,
                child: TextField(
                  controller: ctrl,
                  maxLines: maxLines,
                  keyboardType: keyboardType,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF091410),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: maxLines > 1 ? 10 : 10,
                    ),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: ReviewFormDialog.goldColor.withValues(alpha: 0.20),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: ReviewFormDialog.goldColor.withValues(alpha: 0.20),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: ReviewFormDialog.goldColor,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: ReviewFormDialog.goldColor,
          side: BorderSide(
            color: ReviewFormDialog.goldColor.withValues(alpha: 0.8),
            width: 1.0,
          ),
          backgroundColor: const Color(0xFF132820),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: isUploading ? null : pickAndUploadImage,
        icon: isUploading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ReviewFormDialog.goldColor,
                ),
              )
            : const Icon(Icons.upload_rounded, size: 16, color: ReviewFormDialog.goldColor),
        label: Text(
          "UPLOAD",
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: ReviewFormDialog.goldColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 48.0, bottom: 5),
          child: Text(
            "Rating (Stars)",
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        Row(
          children: [
            _buildIconBlock(Icons.star_rounded, size: 20),
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 160,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF091410),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ReviewFormDialog.goldColor.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<double>(
                  value: ratingVal,
                  dropdownColor: const Color(0xFF0C1914),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: ReviewFormDialog.goldColor,
                    size: 20,
                  ),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [5.0, 4.0, 3.0, 2.0, 1.0].map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(
                        r.toInt().toString(),
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF142921) : const Color(0xFF091410),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? ReviewFormDialog.goldColor
                : Colors.white.withValues(alpha: 0.15),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ReviewFormDialog.goldColor.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isSelected ? ReviewFormDialog.goldColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? ReviewFormDialog.goldColor : Colors.white38,
                  width: 1.2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Color(0xFF0C1914),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? ReviewFormDialog.goldColor : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEdit ? "EDIT REVIEW" : "ADD REVIEW",
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // CANCEL button with red outline
        InkWell(
          onTap: () => Get.back(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF160E10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE55353),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "CANCEL",
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE55353),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // SAVE button in champagne gold with checkmark
        InkWell(
          onTap: _onSave,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: ReviewFormDialog.goldColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: ReviewFormDialog.goldColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF0C1914),
                ),
                const SizedBox(width: 6),
                Text(
                  "SAVE",
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0C1914),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = MediaQuery.of(context).size.width;
          final bool isMobile = availableWidth < 700;
          final double dialogWidth =
              isMobile ? (availableWidth - 32).clamp(280.0, 500.0) : 690.0;

          return Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              color: const Color(0xFF0C1914),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ReviewFormDialog.goldColor.withValues(alpha: 0.28),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: ReviewFormDialog.goldColor.withValues(alpha: 0.05),
                  blurRadius: 16,
                ),
              ],
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),

                  if (isMobile) ...[
                    // Responsive Mobile Layout
                    _buildLabeledField(
                      icon: Icons.person_outline_rounded,
                      label: "Customer Name",
                      ctrl: nameCtrl,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledField(
                      icon: Icons.calendar_today_outlined,
                      label: "Event Name",
                      ctrl: eventCtrl,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledField(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "Comment",
                      ctrl: commentCtrl,
                      isRequired: true,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledField(
                      icon: Icons.format_list_bulleted_rounded,
                      label: "Display Order",
                      ctrl: orderCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildLabeledField(
                      icon: Icons.link_rounded,
                      label: "Customer Profile Image URL",
                      ctrl: imgUrlCtrl,
                      trailing: _buildUploadButton(),
                    ),
                    const SizedBox(height: 12),
                    _buildRatingField(),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      label: "Published",
                      isSelected: isPublishedVal,
                      onChanged: (val) => setState(() => isPublishedVal = val),
                    ),
                    const SizedBox(height: 8),
                    _buildOptionCard(
                      label: "Featured",
                      isSelected: isFeaturedVal,
                      onChanged: (val) => setState(() => isFeaturedVal = val),
                    ),
                    const SizedBox(height: 8),
                    _buildOptionCard(
                      label: "Verified Customer",
                      isSelected: isVerifiedVal,
                      onChanged: (val) => setState(() => isVerifiedVal = val),
                    ),
                  ] else ...[
                    // Desktop 2-Column Layout matching IMAGE 1
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLabeledField(
                            icon: Icons.person_outline_rounded,
                            label: "Customer Name",
                            ctrl: nameCtrl,
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabeledField(
                            icon: Icons.calendar_today_outlined,
                            label: "Event Name",
                            ctrl: eventCtrl,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Full-width Comment
                    _buildLabeledField(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: "Comment",
                      ctrl: commentCtrl,
                      isRequired: true,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),

                    // Display Order & Profile Image URL with Upload
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildLabeledField(
                            icon: Icons.format_list_bulleted_rounded,
                            label: "Display Order",
                            ctrl: orderCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLabeledField(
                            icon: Icons.link_rounded,
                            label: "Customer Profile Image URL",
                            ctrl: imgUrlCtrl,
                            trailing: _buildUploadButton(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Rating
                    _buildRatingField(),
                    const SizedBox(height: 16),

                    // Option Cards (Published, Featured, Verified Customer)
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildOptionCard(
                          label: "Published",
                          isSelected: isPublishedVal,
                          onChanged: (val) => setState(() => isPublishedVal = val),
                        ),
                        _buildOptionCard(
                          label: "Featured",
                          isSelected: isFeaturedVal,
                          onChanged: (val) => setState(() => isFeaturedVal = val),
                        ),
                        _buildOptionCard(
                          label: "Verified Customer",
                          isSelected: isVerifiedVal,
                          onChanged: (val) => setState(() => isVerifiedVal = val),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  _buildActions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
