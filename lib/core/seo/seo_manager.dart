import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../utils/app_logger.dart';
import 'meta_manager.dart';
import 'seo_routes.dart';

/// Observer class hooking into GetX navigation streams to rewrite SEO metadata.
class SeoManager extends GetObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateSeo(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateSeo(newRoute.settings.name);
    }
  }

  void _updateSeo(String? routeName) {
    if (routeName == null || routeName.isEmpty) return;
    AppLogger.info("SEO route change detected: $routeName");
    final metadata = SeoRoutes.getMetadataForPath(routeName);
    MetaManager.updateMetadata(metadata);
  }
}
