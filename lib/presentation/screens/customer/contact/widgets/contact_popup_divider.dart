import 'package:flutter/material.dart';

class CustomPopupDivider extends PopupMenuEntry<Never> {
  const CustomPopupDivider({super.key});
  @override
  double get height => 1;
  @override
  bool represents(dynamic value) => false;
  @override
  State<CustomPopupDivider> createState() => _CustomPopupDividerState();
}

class _CustomPopupDividerState extends State<CustomPopupDivider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFC9A77E).withValues(alpha: 0.25),
    );
  }
}
