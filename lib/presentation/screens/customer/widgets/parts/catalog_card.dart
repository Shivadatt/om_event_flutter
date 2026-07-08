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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.04 : 1.0,
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
                    if (widget.item.isFeatured)
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          color: const Color(0xEBFAF5EE),
                          child: Text(
                            "MOST LOVED",
                            style: AppTheme.sansBody(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF28322E),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onQuickAdd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _isHovered
                                      ? const Color(0xFFC79B61)
                                      : const Color(0xE6192320),
                            ),
                            alignment: Alignment.center,
                            child: AnimatedRotation(
                              turns: _isHovered ? 0.25 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: const Text(
                                "+",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
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
            _ExperienceCardDetails(item: widget.item, isDark: isDark),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${item.categoryName.toUpperCase()} · ${item.durationHours.toStringAsFixed(0)} HRS",
            style: AppTheme.sansBody(
              fontSize: 9,
              color: const Color(0xFFAA7C4B),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item.name,
            style: GoogleFonts.italiana(
              fontSize: 25,
              fontWeight: FontWeight.normal,
              color: isDark ? Colors.white : const Color(0xFF17201E),
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.sansBody(
                fontSize: 12,
                color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    AppFormatters.formatCurrency(item.effectivePrice),
                    style: AppTheme.sansBody(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF17201E),
                    ),
                  ),
                  if (item.offerPrice != null && item.offerPrice! < item.price) ...[
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.formatCurrency(item.price),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Text(
                    "starting price",
                    style: AppTheme.sansBody(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 12,
                    color: Color(0xFFC79B61),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "${item.rating} (${item.reviewCount})",
                    style: AppTheme.sansBody(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
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
