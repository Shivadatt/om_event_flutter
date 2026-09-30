import 'asset_downloader_stub.dart'
    if (dart.library.html) 'asset_downloader_web.dart' as impl;

class AssetDownloader {
  /// Extracts the canonical filename from a URL or generates a clean fallback based on title.
  static String resolveFileName(String url, {String? customName, String? fallbackTitle}) {
    if (customName != null && customName.trim().isNotEmpty) {
      var name = customName.trim();
      if (!name.contains('.')) name = '$name.jpg';
      return name;
    }

    try {
      final uri = Uri.parse(url);
      final lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      if (lastSegment.contains('.')) {
        return Uri.decodeComponent(lastSegment.split('?').first);
      }
    } catch (_) {}

    if (fallbackTitle != null && fallbackTitle.trim().isNotEmpty) {
      final clean = fallbackTitle
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\.-]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      return clean.endsWith('.jpg') || clean.endsWith('.png') ? clean : '$clean.jpg';
    }

    return 'event_asset.jpg';
  }

  static Future<void> download(String url, {String? fileName, String? fallbackTitle}) async {
    if (url.trim().isEmpty) return;
    final name = resolveFileName(url, customName: fileName, fallbackTitle: fallbackTitle);
    await impl.downloadAssetFile(url, name);
  }
}
