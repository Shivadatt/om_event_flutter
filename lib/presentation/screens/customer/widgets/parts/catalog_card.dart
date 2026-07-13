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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? AppColors.secondaryAccent.withValues(alpha: 0.6) : AppColors.primaryAccent.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.50 : 0.25),
                blurRadius: _isHovered ? 24 : 12,
                offset: Offset(0, _isHovered ? 10 : 4),
              ),
              if (_isHovered)
                BoxShadow(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: -2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.8),
            child: Stack(
              children: [
                // Base background color (card body is glassmorphic)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.8),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: const Color(0xFF1B2D27).withValues(alpha: 0.65), // Card Background
                      ),
                    ),
                  ),
                ),

                // Card content Column
                ClipRect(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.25,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18.8),
                          topRight: Radius.circular(18.8),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: AnimatedScale(
                                scale: _isHovered ? 1.06 : 1.0,
                                duration: const Duration(milliseconds: 400),
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
                                      Colors.black.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (widget.item.isFeatured)
                              Positioned(
                                left: 14,
                                top: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F1B18).withValues(alpha: 0.8), // Primary Background
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.secondaryAccent.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "MOST LOVED",
                                    style: AppTheme.sansBody(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryAccent,
                                      letterSpacing: 1.5,
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

                // Floating Circular Add Button on top-right of details
                Positioned(
                  right: 14,
                  top: 14,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: GestureDetector(
                        onTap: widget.onQuickAdd,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isHovered ? AppColors.secondaryAccent : Colors.black.withValues(alpha: 0.45),
                            border: Border.all(
                              color: _isHovered ? Colors.transparent : AppColors.secondaryAccent.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AnimatedRotation(
                            turns: _isHovered ? 0.25 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: Icon(
                              Icons.add,
                              size: 18,
                              color: _isHovered ? const Color(0xFF0F1B18) : Colors.white,
                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${item.categoryName.toUpperCase()} · ${item.durationHours.toStringAsFixed(0)} HRS",
            style: AppTheme.sansBody(
              fontSize: 9,
              color: AppColors.secondaryAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: GoogleFonts.italiana(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sansBody(
                fontSize: 12,
                color: AppColors.muted.withValues(alpha: 0.8),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppFormatters.formatCurrency(item.effectivePrice),
                    style: AppTheme.sansBody(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (item.offerPrice != null && item.offerPrice! < item.price) ...[
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.formatCurrency(item.price),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.muted.withValues(alpha: 0.7),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  Text(
                    "onwards",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      color: AppColors.muted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 12,
                    color: AppColors.secondaryAccent,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "${item.rating} (${item.reviewCount})",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
