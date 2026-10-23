import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InquiryFilterChips extends StatelessWidget {
  final String selectedFilter;
  final int allCount;
  final int newCount;
  final int contactedCount;
  final int closedCount;
  final ValueChanged<String> onFilterSelected;
  final bool isMobile;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.allCount,
    required this.newCount,
    required this.contactedCount,
    required this.closedCount,
    required this.onFilterSelected,
    this.isMobile = false,
  });

  Widget _buildChip(String label, String value) {
    final bool isSelected = selectedFilter == value;

    return InkWell(
      onTap: () => onFilterSelected(value),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? goldColor : const Color(0xFF0D1B16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? goldColor : Colors.white.withValues(alpha: 0.12),
            width: 0.9,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF091410) : Colors.white70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      _buildChip("All ($allCount)", 'all'),
      _buildChip("New ($newCount)", 'new'),
      _buildChip("Contacted ($contactedCount)", 'contacted'),
      _buildChip("Closed ($closedCount)", 'closed'),
    ];

    if (isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chips[0],
        const SizedBox(width: 8),
        chips[1],
        const SizedBox(width: 8),
        chips[2],
        const SizedBox(width: 8),
        chips[3],
      ],
    );
  }
}
