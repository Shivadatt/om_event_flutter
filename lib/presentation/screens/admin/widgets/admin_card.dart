import 'package:flutter/material.dart';

/// Reusable Admin Container Card widget.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AdminCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1915),
        border: Border.all(color: const Color(0x21FFFFFF), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
