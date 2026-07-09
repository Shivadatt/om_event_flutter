import 'package:flutter/material.dart';

/// Reusable Admin Filters wrap panel.
class AdminFilters extends StatelessWidget {
  final List<Widget> children;

  const AdminFilters({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1915),
        border: Border.all(color: const Color(0x21FFFFFF), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
