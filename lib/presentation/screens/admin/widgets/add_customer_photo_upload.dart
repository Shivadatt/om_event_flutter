import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

/// Photo uploader and preview box for Add New Client dialog.
class AddCustomerPhotoUpload extends StatelessWidget {
  final Uint8List? photoBytes;
  final String? photoName;
  final bool isUploading;
  final double width;
  final double height;
  final Color fieldFill;
  final Color textColor;
  final Color subtitleColor;
  final Function(Uint8List bytes, String name) onPhotoSelected;
  final VoidCallback onPhotoCleared;

  const AddCustomerPhotoUpload({
    super.key,
    required this.photoBytes,
    required this.photoName,
    required this.isUploading,
    required this.width,
    required this.height,
    required this.fieldFill,
    required this.textColor,
    required this.subtitleColor,
    required this.onPhotoSelected,
    required this.onPhotoCleared,
  });

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;

      if (file.size > 2 * 1024 * 1024) {
        Get.snackbar(
          "File Too Large",
          "Profile photo must be less than 2MB.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }

      onPhotoSelected(file.bytes!, file.name);
    } catch (e) {
      Get.snackbar(
        "Photo Error",
        "Could not select photo: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : _pickPhoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fieldFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryAccent.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: photoBytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(photoBytes!, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_outlined, size: 12, color: AppColors.primaryAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Change',
                            style: AppTheme.sansBody(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: onPhotoCleared,
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isUploading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryAccent.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Photo',
                    style: AppTheme.sansBody(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'JPG, PNG (Max 2MB)',
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: subtitleColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
