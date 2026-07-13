part of '../home_catalog_section.dart';

extension _CatalogToolbarExtension on ExperiencesCatalogSection {
  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return _ToolbarChip(label: label, isActive: isActive, onTap: onTap);
  }

  Widget _buildToolbar({
    required BuildContext context,
    required bool isDark,
    required double width,
    required double titleSize,
    required bool isWide,
  }) {
    final headingWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CURATED EXPERIENCES",
          style: AppTheme.sansBody(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.5,
            color: AppColors.primaryAccent,
          ),
        ),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              colors: [Colors.white, Color(0xFFE6C55A), Color(0xFFD4AF37)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.italiana(
                fontSize: titleSize,
                fontWeight: FontWeight.normal,
                color: Colors.white,
                height: 1.0,
                letterSpacing: 1.2,
              ),
              children: [
                const TextSpan(text: "DESIGNED TO LEAVE\n"),
                const TextSpan(text: "A "),
                TextSpan(
                  text: "BEAUTIFUL ECHO.",
                  style: GoogleFonts.italiana(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final descWidget = Container(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Text(
        "Explore signature concepts, see an honest starting price, then tune every color, material and detail.",
        style: AppTheme.sansBody(
          fontSize: 14.5,
          color: AppColors.muted,
          height: 1.8,
        ),
      ),
    );

    final headerRow = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headingWidget,
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: descWidget,
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headingWidget,
              const SizedBox(height: 24),
              descWidget,
            ],
          );

    final searchWidget = Container(
      height: 44,
      width: isWide ? 280 : double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2D27).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 16,
            color: AppColors.secondaryAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (val) => controller.updateSearchQuery(val),
              style: AppTheme.sansBody(
                fontSize: 13,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Search a mood, theme or event…",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );

    final sortWidget = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2D27).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortBy.value,
            dropdownColor: const Color(0xFF1B2D27),
            icon: const Padding(
              padding: EdgeInsets.only(left: 6.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: AppColors.secondaryAccent,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'popular', child: Text("MOST LOVED")),
              DropdownMenuItem(value: 'latest', child: Text("LATEST")),
              DropdownMenuItem(
                value: 'price_low',
                child: Text("PRICE: LOW TO HIGH"),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text("PRICE: HIGH TO LOW"),
              ),
            ],
            onChanged: (val) {
              if (val != null) controller.updateSort(val);
            },
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );

    final chipsWidget = SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Obx(() {
              final isActive = controller.selectedCategorySlug.value.isEmpty;
              return _buildChip(
                label: "All",
                isActive: isActive,
                onTap: () => controller.selectCategory(''),
                isDark: isDark,
              );
            }),
            const SizedBox(width: 8),
            Obx(
              () => Row(
                children: controller.rxCategories.map((cat) {
                  final isActive = controller.selectedCategorySlug.value == cat.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildChip(
                      label: cat.name.replaceFirst(" Celebrations", ""),
                      isActive: isActive,
                      onTap: () => controller.selectCategory(cat.slug),
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );

    final toolbar = isWide
        ? Row(
            children: [
              searchWidget,
              const SizedBox(width: 20),
              Expanded(child: chipsWidget),
              const SizedBox(width: 20),
              sortWidget,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchWidget,
              const SizedBox(height: 16),
              chipsWidget,
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: sortWidget),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        const SizedBox(height: 60),
        toolbar,
      ],
    );
  }
}

class _ToolbarChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolbarChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ToolbarChip> createState() => _ToolbarChipState();
}

class _ToolbarChipState extends State<_ToolbarChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeGradient = const LinearGradient(
      colors: [AppColors.highlight, AppColors.secondaryAccent, AppColors.primaryAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isActive ? activeGradient : null,
            color: widget.isActive ? null : Colors.transparent,
            border: Border.all(
              color: widget.isActive
                  ? Colors.transparent
                  : (_isHovered ? AppColors.primaryAccent : AppColors.primaryAccent.withValues(alpha: 0.2)),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.isActive && _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: AppTheme.sansBody(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: widget.isActive ? const Color(0xFF0F1B18) : AppColors.muted,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
