import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/config/app_theme.dart';

/// Search, sort, and view-mode toggle toolbar for the Customer Directory.
class CustomerDirectoryToolbar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final RxString rxSearchQuery;
  final RxString rxSortOption;
  final RxString rxViewMode;
  final bool isMobile;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryAccent;

  const CustomerDirectoryToolbar({
    super.key,
    required this.searchCtrl,
    required this.rxSearchQuery,
    required this.rxSortOption,
    required this.rxViewMode,
    required this.isMobile,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryAccent,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: searchCtrl,
        style: AppTheme.sansBody(fontSize: 13, color: textColor),
        onChanged: (val) => rxSearchQuery.value = val.trim(),
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          hintText: 'Search client name, email, phone, or city...',
          hintStyle: AppTheme.sansBody(fontSize: 13, color: subtitleColor),
          prefixIcon: Icon(Icons.search_rounded, color: primaryAccent, size: 20),
          suffixIcon: Obx(() => rxSearchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: subtitleColor,
                  onPressed: () {
                    searchCtrl.clear();
                    rxSearchQuery.value = '';
                  },
                )
              : const SizedBox.shrink()),
        ),
      ),
    );

    final sortWidget = Obx(() => Container(
          height: 48,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: PopupMenuButton<String>(
            tooltip: 'Sort Options',
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: borderColor),
            ),
            initialValue: rxSortOption.value,
            onSelected: (val) => rxSortOption.value = val,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Latest', child: Text('Sort: Latest')),
              PopupMenuItem(value: 'Oldest', child: Text('Sort: Oldest')),
              PopupMenuItem(value: 'Highest Spending', child: Text('Sort: Highest Spending')),
              PopupMenuItem(value: 'Lowest Spending', child: Text('Sort: Lowest Spending')),
              PopupMenuItem(value: 'Most Bookings', child: Text('Sort: Most Bookings')),
              PopupMenuItem(value: 'Least Bookings', child: Text('Sort: Least Bookings')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMobile ? rxSortOption.value : 'Sort: ${rxSortOption.value}',
                  style: AppTheme.sansBody(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                ),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_down_rounded, color: primaryAccent, size: 18),
              ],
            ),
          ),
        ));

    final viewControls = Obx(() => Container(
          height: 48,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewModeBtn(Icons.table_rows_rounded, 'Table', rxViewMode.value == 'table', () => rxViewMode.value = 'table'),
              const SizedBox(width: 4),
              _buildViewModeBtn(Icons.grid_view_rounded, 'Grid', rxViewMode.value == 'grid', () => rxViewMode.value = 'grid'),
            ],
          ),
        ));

    if (isMobile) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: sortWidget),
              const SizedBox(width: 10),
              viewControls,
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 14),
        sortWidget,
        const SizedBox(width: 12),
        viewControls,
      ],
    );
  }

  Widget _buildViewModeBtn(IconData icon, String tip, bool isSelected, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isSelected ? primaryAccent.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? primaryAccent.withValues(alpha: 0.4) : Colors.transparent),
          ),
          child: Icon(icon, size: 18, color: isSelected ? primaryAccent : Colors.white54),
        ),
      ),
    );
  }
}
