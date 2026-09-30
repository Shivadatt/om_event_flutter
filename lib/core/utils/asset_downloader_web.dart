// ignore_for_file: avoid_web_libraries_in_flutter, avoid_web_libraries_in_dart, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'app_logger.dart';

Future<void> downloadAssetFile(String url, String fileName) async {
  if (url.trim().isEmpty) return;
  final cleanFileName = fileName.trim().isNotEmpty ? fileName.trim() : 'event_asset.jpg';

  // 1. Local Flutter asset files (e.g. assets/images/...)
  if (url.startsWith('assets/')) {
    try {
      final byteData = await rootBundle.load(url);
      final blob = html.Blob([byteData.buffer.asUint8List()]);
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      _triggerBrowserBlobDownload(blobUrl, cleanFileName);
      return;
    } catch (e) {
      AppLogger.warning("Failed to load local asset for download: $e");
    }
  }

  // 2. Remote URLs (e.g. Supabase Storage / CDN)
  // For Supabase Storage, ?download= triggers server Content-Disposition: attachment
  String downloadUrl = url;
  if (downloadUrl.contains('supabase.co') || downloadUrl.contains('/storage/v1/object/')) {
    final sep = downloadUrl.contains('?') ? '&' : '?';
    downloadUrl = '$downloadUrl${sep}download=${Uri.encodeComponent(cleanFileName)}';
  }

  // First attempt: Fetch as blob to generate same-origin blob: URL.
  // Modern browsers strictly honor the download attribute on same-origin/blob URLs,
  // preventing new tabs from opening and directly triggering the download manager.
  try {
    final request = await html.HttpRequest.request(
      downloadUrl,
      method: 'GET',
      responseType: 'blob',
    );

    if (request.response != null) {
      final blob = request.response as html.Blob;
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);
      _triggerBrowserBlobDownload(blobUrl, cleanFileName);
      return;
    }
  } catch (e) {
    AppLogger.warning("Blob download request failed, trying direct attachment trigger: $e");
  }

  // 3. Fallback: Invisible iframe or anchor WITHOUT target="_blank"
  // Having target="_blank" forced the browser to open a preview tab.
  // Using an invisible iframe or anchor without target="_blank" forces direct download.
  try {
    final anchor = html.AnchorElement(href: downloadUrl)
      ..setAttribute('download', cleanFileName)
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  } catch (e) {
    AppLogger.error("Failed to trigger browser download for $url", e);
  }
}

void _triggerBrowserBlobDownload(String blobUrl, String fileName) {
  final anchor = html.AnchorElement(href: blobUrl)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  Future.delayed(const Duration(seconds: 3), () {
    try {
      html.Url.revokeObjectUrl(blobUrl);
    } catch (_) {}
  });
}
