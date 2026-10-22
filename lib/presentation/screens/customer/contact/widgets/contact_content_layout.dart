import 'package:flutter/material.dart';

class ContactContentLayout extends StatelessWidget {
  final bool useTwoColumn;
  final bool isDesktop;
  final bool isLaptop;
  final Widget leftContent;
  final Widget rightContent;

  const ContactContentLayout({
    super.key,
    required this.useTwoColumn,
    required this.isDesktop,
    required this.isLaptop,
    required this.leftContent,
    required this.rightContent,
  });

  @override
  Widget build(BuildContext context) {
    if (useTwoColumn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: isDesktop ? 57 : (isLaptop ? 56 : 53),
            child: leftContent,
          ),
          SizedBox(width: isDesktop ? 28 : (isLaptop ? 20 : 16)),
          Expanded(
            flex: isDesktop ? 43 : (isLaptop ? 44 : 47),
            child: rightContent,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leftContent,
          const SizedBox(height: 24),
          rightContent,
        ],
      );
    }
  }
}
