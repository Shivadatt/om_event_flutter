import 'package:flutter/material.dart';

class InquirySearchToolbar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final bool isGridView;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<bool> onViewModeChanged;
  final bool isMobile;
  static const Color goldColor = Color(0xFFECC24A);

  const InquirySearchToolbar({
    super.key,
    required this.searchCtrl,
    required this.isGridView,
    required this.onSearchChanged,
    required this.onViewModeChanged,
    this.isMobile = false,
  });

  Widget _buildSearchField({bool isExpanded = false}) {
    final field = Container(
      width: isExpanded ? null : 190,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1612),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white12, width: 0.9),
      ),
      child: TextField(
        controller: searchCtrl,
        onChanged: onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 11.5),
        cursorColor: goldColor,
        decoration: InputDecoration(
          hintText: "Search inquiries...",
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 11.0),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: goldColor.withValues(alpha: 0.75),
            size: 15,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 34),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          isDense: true,
          suffixIcon: searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 13, color: Colors.white54),
                  splashRadius: 13,
                  onPressed: () {
                    searchCtrl.clear();
                    onSearchChanged('');
                  },
                )
              : null,
        ),
      ),
    );

    return isExpanded ? Expanded(child: field) : field;
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF142B20) : const Color(0xFF0A1612),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? goldColor : Colors.white12,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? goldColor : Colors.white54,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridBtn = _buildToggleBtn(
      icon: Icons.grid_view_rounded,
      isSelected: isGridView,
      onTap: () => onViewModeChanged(true),
    );
    final listBtn = _buildToggleBtn(
      icon: Icons.view_list_rounded,
      isSelected: !isGridView,
      onTap: () => onViewModeChanged(false),
    );

    if (isMobile) {
      return Row(
        children: [
          _buildSearchField(isExpanded: true),
          const SizedBox(width: 8),
          gridBtn,
          const SizedBox(width: 6),
          listBtn,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchField(isExpanded: false),
        const SizedBox(width: 8),
        gridBtn,
        const SizedBox(width: 5),
        listBtn,
      ],
    );
  }
}
