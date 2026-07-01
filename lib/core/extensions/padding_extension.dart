import 'package:flutter/material.dart';

/// Extension methods on [Widget] to apply padding cleanly using builder chaining.
extension PaddingExtension on Widget {
  /// Wraps this widget in a [Padding] with equal inset padding on all sides.
  Widget paddingAll(double val) =>
      Padding(padding: EdgeInsets.all(val), child: this);

  /// Wraps this widget in a [Padding] with symmetric horizontal and vertical inset padding.
  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Wraps this widget in a [Padding] specifying custom inset padding on individual edges.
  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );
}
