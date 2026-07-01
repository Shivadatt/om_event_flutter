import 'package:flutter/material.dart';

/// Extension methods on [String] to perform parsing, formatting, and validation.
extension StringExtension on String {
  /// Converts a hex color string (e.g. "#FF0000" or "FF0000") into a [Color] object.
  Color toColor() {
    final cleanHex = replaceAll('#', '');
    if (cleanHex.length == 6) {
      return Color(int.parse('FF$cleanHex', radix: 16));
    } else if (cleanHex.length == 8) {
      return Color(int.parse(cleanHex, radix: 16));
    }
    return Colors.grey;
  }

  /// Capitalizes the first character of this string.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
