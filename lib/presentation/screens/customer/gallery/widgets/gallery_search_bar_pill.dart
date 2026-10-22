import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/gallery_controller.dart';

class GallerySearchBarPill extends StatelessWidget {
  final TextEditingController searchCtrl;
  final GalleryController controller;
  final Color goldColor;

  const GallerySearchBarPill({
    super.key,
    required this.searchCtrl,
    required this.controller,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0E1C18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.38),
            width: 1.1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search_rounded, color: goldColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                cursorColor: goldColor,
                onChanged: (val) => controller.setSearchQuery(val),
                onSubmitted: (val) => controller.setSearchQuery(val),
                decoration: const InputDecoration(
                  hintText:
                      "Search themes (e.g., Royal Wedding, Stage, Floral, Pastel)...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 12.5),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Obx(() {
              if (controller.rxSearchQuery.value.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () {
                    searchCtrl.clear();
                    controller.clearSearch();
                  },
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => controller.setSearchQuery(searchCtrl.text),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x40D4AF37),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFF08110E),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
