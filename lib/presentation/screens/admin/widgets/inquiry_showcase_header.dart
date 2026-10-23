import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InquiryShowcaseHeader extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onAddInquiry;
  static const Color goldColor = Color(0xFFECC24A);

  const InquiryShowcaseHeader({
    super.key,
    required this.isMobile,
    required this.onAddInquiry,
  });

  Widget _buildAddButton() {
    
    final btn = Container(
      height: 36,
      decoration: BoxDecoration(
        color: goldColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onAddInquiry,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 15,
                  color: Color(0xFF091410),
                ),
                const SizedBox(width: 4),
                Text(
                  "Add Inquiry",
                  style: GoogleFonts.montserrat(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF091410),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return isMobile ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  @override
  Widget build(BuildContext context) {
    final titleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Inquiry Showcase",
          style: GoogleFonts.montserrat(
            fontSize: isMobile ? 20 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "Real inquiries, real opportunities. Convert moments into celebrations.",
          style: TextStyle(
            fontSize: isMobile ? 11.0 : 12.0,
            color: Colors.white60,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 12),
          _buildAddButton(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 12),
        _buildAddButton(),
      ],
    );
  }
}
