import 'package:flutter/material.dart';

/// Global helper to reliably open the Customer Event Canvas (CartDrawer)
/// from any modal, screen, or catalog card across the application.
class CustomerDrawerHelper {
  CustomerDrawerHelper._();

  static final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();

  /// Opens the right-side Event Canvas drawer.
  static void openEventCanvas([BuildContext? context]) {
    try {
      if (homeScaffoldKey.currentState != null) {
        if (!homeScaffoldKey.currentState!.isEndDrawerOpen) {
          homeScaffoldKey.currentState!.openEndDrawer();
        }
        return;
      }
      if (context != null) {
        final scaffold = Scaffold.maybeOf(context);
        if (scaffold != null && scaffold.hasEndDrawer && !scaffold.isEndDrawerOpen) {
          scaffold.openEndDrawer();
        }
      }
    } catch (_) {}
  }
}
