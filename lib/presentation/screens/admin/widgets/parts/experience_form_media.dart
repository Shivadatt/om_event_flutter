part of '../experience_form_dialog.dart';

extension _ExperienceFormMedia on _ExperienceFormDialogState {
  Widget _buildMediaColumn(BuildContext context) {
    const Color labelGold = Color(0xFFD4AF37);
    const Color inputFillColor = Color(0xFF131D18);
    const Color borderColor = Color(0xFF24352B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 1. DISPLAY IMAGE ───────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: inputFillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isUploadingImage)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: labelGold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Uploading image...",
                          style: AppTheme.sansBody(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                else if (imgCtrl.text.isNotEmpty) ...[
                  imgCtrl.text.startsWith('assets/')
                      ? Image.asset(
                          imgCtrl.text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImageError(),
                        )
                      : Image.network(
                          imgCtrl.text,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImageError(),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Center(
                      child: InkWell(
                        onTap: uploadExperienceImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: labelGold, width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_camera_outlined, color: labelGold, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "Change Image",
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else
                  InkWell(
                    onTap: uploadExperienceImage,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: labelGold.withValues(alpha: 0.6), size: 36),
                          const SizedBox(height: 8),
                          Text(
                            "Upload Display Image",
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Click to browse file",
                            style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFF7D8C83)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Recommended size: 1200 x 800 JPG, PNG (Max 5MB)",
          style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFF7D8C83)),
        ),

        const SizedBox(height: 16),

        // ── 2. CINEMATIC VIDEO ─────────────────────────────────────
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              color: inputFillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isUploadingVideo)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: labelGold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Uploading video...",
                          style: AppTheme.sansBody(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                else if (vidCtrl.text.isNotEmpty) ...[
                  Container(
                    color: const Color(0xFF0C1410),
                    child: Center(
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: const Icon(Icons.play_arrow_rounded, color: labelGold, size: 24),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 10,
                    right: 10,
                    child: Text(
                      vidCtrl.text.split('/').last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sansBody(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Center(
                      child: InkWell(
                        onTap: uploadExperienceVideo,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: labelGold, width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_outlined, color: labelGold, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                "Change Video",
                                style: AppTheme.sansBody(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else
                  InkWell(
                    onTap: uploadExperienceVideo,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_library_outlined, color: labelGold.withValues(alpha: 0.6), size: 30),
                          const SizedBox(height: 6),
                          Text(
                            "Upload Cinematic Video",
                            style: AppTheme.sansBody(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Click to browse MP4",
                            style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFF7D8C83)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Recommended: MP4 (Max 50MB)",
          style: AppTheme.sansBody(fontSize: 10, color: const Color(0xFF7D8C83)),
        ),
      ],
    );
  }

  Widget _buildImageError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, color: Colors.white38, size: 28),
          const SizedBox(height: 4),
          Text(
            "Image not available",
            style: AppTheme.sansBody(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}
