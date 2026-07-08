part of '../home_catalog_section.dart';

extension _CatalogToolbarExtension on ExperiencesCatalogSection {
  Widget _buildChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color:
                isActive
                    ? (isDark ? Colors.white : const Color(0xFF1E2B27))
                    : Colors.transparent,
            border: Border.all(
              color:
                  isActive
                      ? Colors.transparent
                      : (isDark ? Colors.white24 : Colors.black12),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: AppTheme.sansBody(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color:
                  isActive
                      ? (isDark ? const Color(0xFF17201E) : Colors.white)
                      : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
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
            letterSpacing: 2,
            color: const Color(0xFFAA7C4B),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.italiana(
              fontSize: titleSize,
              fontWeight: FontWeight.normal,
              color: isDark ? Colors.white : const Color(0xFF17201E),
              height: 0.98,
            ),
            children: [
              const TextSpan(text: "Designed to leave\n"),
              const TextSpan(text: "a "),
              TextSpan(
                text: "beautiful echo.",
                style: GoogleFonts.italiana(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFAA7C4B),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final descWidget = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Text(
        "Explore signature concepts, see an honest starting price, then tune every color, material and detail.",
        style: AppTheme.sansBody(
          fontSize: 14,
          color: isDark ? AppTheme.darkMuted : AppTheme.lightMuted,
          height: 1.8,
        ),
      ),
    );

    final headerRow =
        isWide
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                headingWidget,
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: descWidget,
                ),
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [headingWidget, const SizedBox(height: 22), descWidget],
            );

    final searchWidget = Container(
      height: 46,
      width: isWide ? 280 : double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => controller.updateSearchQuery(val),
              style: AppTheme.sansBody(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF17201E),
              ),
              decoration: const InputDecoration(
                hintText: "Search a mood, theme or event…",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );

    final sortWidget = Container(
      height: 46,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortBy.value,
            dropdownColor: isDark ? const Color(0xFF1B2320) : Colors.white,
            icon: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'popular', child: Text("Most loved")),
              DropdownMenuItem(value: 'latest', child: Text("Latest")),
              DropdownMenuItem(
                value: 'price_low',
                child: Text("Price: low to high"),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text("Price: high to low"),
              ),
            ],
            onChanged: (val) {
              if (val != null) controller.updateSort(val);
            },
            style: AppTheme.sansBody(
              fontSize: 12,
              color: isDark ? Colors.white : const Color(0xFF17201E),
            ),
          ),
        ),
      ),
    );

    final chipsWidget = SizedBox(
      height: 46,
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
            const SizedBox(width: 7),
            Obx(
              () => Row(
                children:
                    controller.rxCategories.map((cat) {
                      final isActive =
                          controller.selectedCategorySlug.value == cat.slug;
                      return Padding(
                        padding: const EdgeInsets.only(right: 7.0),
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

    final toolbar =
        isWide
            ? Row(
              children: [
                searchWidget,
                const SizedBox(width: 14),
                Expanded(child: chipsWidget),
                const SizedBox(width: 14),
                sortWidget,
              ],
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchWidget,
                const SizedBox(height: 14),
                chipsWidget,
                const SizedBox(height: 14),
                Align(alignment: Alignment.centerLeft, child: sortWidget),
              ],
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerRow,
        const SizedBox(height: 62),
        toolbar,
      ],
    );
  }
}
