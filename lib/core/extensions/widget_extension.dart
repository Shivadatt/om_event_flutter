import 'package:flutter/material.dart';

/// General extension methods on [Widget] for visual adjustments, visibility, and layout constraints.
extension WidgetExtension on Widget {
  /// Wraps this widget in a [Center] widget.
  Widget center() => Center(child: this);

  /// Wraps this widget in an [Expanded] widget.
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Wraps this widget in a [Visibility] widget based on a condition.
  Widget visible(bool condition) => Visibility(visible: condition, child: this);
}
