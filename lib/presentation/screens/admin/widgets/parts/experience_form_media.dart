part of '../experience_form_dialog.dart';

extension _ExperienceFormMedia on _ExperienceFormDialogState {
  Widget _buildMediaUploads(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Click to Change Image",
                                      style: TextStyle(
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
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    fontWeight: FontWeight.bold,
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    fontWeight: FontWeight.bold,
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
      ],
    );
  }
}
