import 'package:flutter/material.dart';

/// Extension methods on [BuildContext] to simplify theme access.
extension ThemeExtension on BuildContext {
  /// Quick access to the active [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Quick access to the active [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to the active [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
