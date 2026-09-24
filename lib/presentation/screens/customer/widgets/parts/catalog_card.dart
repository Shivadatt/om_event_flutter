part of '../home_catalog_section.dart';

class ExperienceCard extends StatefulWidget {
  final Experience item;
  final VoidCallback onQuickAdd;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.item,
    required this.onQuickAdd,
    required this.onTap,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isHovered = false;
  bool _isFavorite = false;

  Widget _buildImage(
    String url,
    String title,
    String categorySlug,
    String categoryName,
  ) {
    if (url.isEmpty) {
      return ItemVisualPlaceholder(
        title: title,
        categorySlug: categorySlug,
        categoryName: categoryName,
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => ItemVisualPlaceholder(
              title: title,
              categorySlug: categorySlug,
              categoryName: categoryName,
            ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => ItemVisualPlaceholder(
            title: title,
            categorySlug: categorySlug,
            categoryName: categoryName,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppColors.secondaryAccent.withValues(alpha: 0.6)
                  : AppColors.primaryAccent.withValues(alpha: 0.16),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.45 : 0.22),
                blurRadius: _isHovered ? 18 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
              if (_isHovered)
                BoxShadow(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.08),
                  blurRadius: 14,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Base background color
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: const Color(0xFF14241F).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),

                // Card content Column
                Positioned.fill(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned.fill(
                                child: AnimatedScale(
                                  scale: _isHovered ? 1.05 : 1.0,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOut,
                                  child: _buildImage(
                                    widget.item.imageUrl,
                                    widget.item.name,
                                    widget.item.categorySlug,
                                    widget.item.categoryName,
                                  ),
                                ),
                              ),
                              // Vignette overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.35),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.item.isFeatured)
                                Positioned(
                                  left: 10,
                                  top: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F1B18).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.secondaryAccent.withValues(alpha: 0.4),
                                        width: 0.9,
                                      ),
                                    ),
                                    child: Text(
                                      "MOST LOVED",
                                      style: AppTheme.sansBody(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryAccent,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      _ExperienceCardDetails(item: widget.item, isDark: isDark),
                    ],
                  ),
                ),

                // Floating Circular Favorite Button on top-right of image (Image 1 style)
                Positioned(
                  right: 10,
                  top: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isFavorite = !_isFavorite);
                          Get.snackbar(
                            _isFavorite ? "Saved" : "Removed",
                            _isFavorite
                                ? "${widget.item.name} added to favorites."
                                : "${widget.item.name} removed from favorites.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF1B2D27).withValues(alpha: 0.9),
                            colorText: Colors.white,
                            borderColor: AppColors.secondaryAccent.withValues(alpha: 0.3),
                            borderWidth: 1.0,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.45),
                            border: Border.all(
                              color: _isFavorite
                                  ? AppColors.secondaryAccent
                                  : AppColors.secondaryAccent.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: _isFavorite
                                ? AppColors.secondaryAccent
                                : Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperienceCardDetails extends StatelessWidget {
  final Experience item;
  final bool isDark;

  const _ExperienceCardDetails({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${item.categoryName.toUpperCase()} · ${item.durationHours.toStringAsFixed(0)} HRS",
            style: AppTheme.sansBody(
              fontSize: 8.5,
              color: AppColors.secondaryAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            item.name,
            style: GoogleFonts.italiana(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.15,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.formatCurrency(item.effectivePrice),
                    style: AppTheme.sansBody(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.offerPrice != null && item.offerPrice! < item.price) ...[
                        Text(
                          AppFormatters.formatCurrency(item.price),
                          style: TextStyle(
                            fontSize: 9.5,
                            color: AppColors.muted.withValues(alpha: 0.7),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        "onwards",
                        style: AppTheme.sansBody(
                          fontSize: 9,
                          color: AppColors.muted.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: AppColors.secondaryAccent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "${item.rating.toStringAsFixed(1)} (${item.reviewCount})",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
