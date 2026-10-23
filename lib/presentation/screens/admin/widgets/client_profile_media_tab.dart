import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/constants/app_colors.dart';

class ClientProfileMediaTab extends StatelessWidget {
  final bool isMobile;

  const ClientProfileMediaTab({
    super.key,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: isMobile ? 36 : 44,
              color: AppColors.primaryAccent.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              "Customer Media Gallery",
              style: AppTheme.sansBody(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Upload event photos or decor proposals shared with this client.",
              textAlign: TextAlign.center,
              style: AppTheme.sansBody(
                fontSize: 11,
                color: AppColors.darkMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: Text(
                "UPLOAD PROPOSAL MEDIA",
                style: AppTheme.sansBody(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 18 : 24,
                  vertical: isMobile ? 12 : 16,
                ),
                elevation: 0,
              ),
              onPressed: () {
                Get.snackbar(
                  "Upload Successful",
                  "Shared file saved to customer gallery bucket successfully.",
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
