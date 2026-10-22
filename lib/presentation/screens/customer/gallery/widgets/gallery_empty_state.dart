import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/config/app_theme.dart';
import '../../../../controllers/gallery_controller.dart';

class GalleryEmptyState extends StatelessWidget {
  final TextEditingController searchCtrl;
  final GalleryController controller;
  final Color goldColor;

  const GalleryEmptyState({
    super.key,
    required this.searchCtrl,
    required this.controller,
    required this.goldColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: 56,
                color: goldColor.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                "No celebration photos match your criteria",
                style: GoogleFonts.italiana(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Try searching for another keyword or switch category filters.",
                style: AppTheme.sansBody(fontSize: 12, color: Colors.white38),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("RESET ALL FILTERS"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: goldColor,
                  side: BorderSide(color: goldColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  searchCtrl.clear();
                  controller.resetFilters();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
