import 'package:flutter/material.dart';

/// Canonical shared page container ensuring uniform horizontal alignment across all sections,
/// strictly mirroring the boundaries established by CategoriesSection.
class AppPageContainer extends StatelessWidget {
  final Widget child;
  final double? verticalPadding;
  final AlignmentGeometry alignment;
  final BoxConstraints? constraints;

  const AppPageContainer({
    super.key,
    required this.child,
    this.verticalPadding,
    this.alignment = Alignment.center,
    this.constraints,
  });

  /// Canonical horizontal padding derived from CategoriesSection:
  /// - Desktop (>= 1200px): 48.0
  /// - Tablet (800px - 1199px): 32.0
  /// - Mobile (< 800px): 20.0
  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 1200
        ? 48.0
        : (width >= 800 ? 32.0 : 20.0);
  }

  /// Canonical maximum content width matching CategoriesSection.
  static const double maxContentWidth = 1440.0;

  @override
  Widget build(BuildContext context) {
    final hPad = horizontalPadding(context);
    final vPad = verticalPadding ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: constraints ?? const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
