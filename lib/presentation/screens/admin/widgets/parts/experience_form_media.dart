part of '../experience_form_dialog.dart';

extension _ExperienceFormMedia on _ExperienceFormDialogState {
  Widget _buildMediaUploads(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryAccent = AppColors.primaryAccent;
    final Color textColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inputFillColor = isDark ? const Color(0xFF1A1715) : const Color(0xFFFAF8F5);
    final Color borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          "DISPLAY IMAGE PREVIEW",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
            letterSpacing: 1.0,
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
                color: inputFillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isUploadingImage
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFC79B61),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Uploading image to Supabase...",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.6),
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
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                              Container(
                                color: Colors.black45,
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload_outlined,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Click to Change Image",
                                      style: AppTheme.sansBody(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: primaryAccent.withValues(alpha: 0.4),
                                  size: 36,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Upload Experience Image",
                                  style: AppTheme.sansBody(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "(Saves to Supabase gallery/images)",
                                  style: AppTheme.sansBody(
                                    color: textColor.withValues(alpha: 0.5),
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
        const SizedBox(height: 24),
        Text(
          "CINEMATIC VIDEO SHOWCASE",
          style: AppTheme.sansBody(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: primaryAccent,
            letterSpacing: 1.0,
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
                color: inputFillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isUploadingVideo
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFC79B61),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Uploading video to Supabase...",
                              style: AppTheme.sansBody(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.6),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      style: AppTheme.sansBody(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Click to Change Video",
                                      style: AppTheme.sansBody(
                                        color: textColor.withValues(alpha: 0.5),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_call_outlined,
                                  color: primaryAccent.withValues(alpha: 0.4),
                                  size: 36,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Upload Experience Video",
                                  style: AppTheme.sansBody(
                                    color: textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "(Saves to Supabase gallery/Video)",
                                  style: AppTheme.sansBody(
                                    color: textColor.withValues(alpha: 0.5),
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
      ],
    );
  }
}
