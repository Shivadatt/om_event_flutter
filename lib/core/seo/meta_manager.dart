import 'seo_models.dart';
import 'meta_manager_stub.dart'
    if (dart.library.html) 'meta_manager_web.dart'
    as impl;

/// Core manager responsible for dynamically updating HTML metadata and JSON-LD scripts in the DOM.
class MetaManager {
  MetaManager._();

  /// Updates all relevant head tags and scripts for the active route.
  static void updateMetadata(SeoMetadata metadata) {
    impl.updateMetadataImpl(metadata);
  }
}
