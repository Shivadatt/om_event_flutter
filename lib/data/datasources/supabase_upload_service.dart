import 'dart:async';
import 'package:flutter/services.dart';
import 'supabase_storage_source.dart';

class SupabaseUploadService {
  final SupabaseStorageSource _storageSource;

  SupabaseUploadService(this._storageSource);

  /// Loads a local asset from the bundle, uploads it to Supabase Storage, and returns its public URL.
  /// Implements retry logic with exponential backoff.
  Future<String> uploadAsset(String assetPath, String bucket, {int maxRetries = 3}) async {
    final fileName = assetPath.split('/').last;
    final contentType = _getContentType(fileName);

    int attempt = 0;
    while (true) {
      attempt++;
      try {
        // Load raw bytes from Flutter Assets bundle
        final ByteData byteData = await rootBundle.load(assetPath);
        final List<int> fileBytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );

        // Upload using storage source
        final publicUrl = await _storageSource.uploadFile(
          fileName,
          fileBytes,
          contentType,
          bucket: bucket,
        );

        return publicUrl;
      } catch (e) {
        if (attempt >= maxRetries) {
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        final waitDuration = Duration(seconds: attempt * 2);
        await Future.delayed(waitDuration);
      }
    }
  }

  String _getContentType(String fileName) {
    final lowercase = fileName.toLowerCase();
    if (lowercase.endsWith('.jpg') || lowercase.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lowercase.endsWith('.png')) {
      return 'image/png';
    } else if (lowercase.endsWith('.mp4')) {
      return 'video/mp4';
    } else if (lowercase.endsWith('.pdf')) {
      return 'application/pdf';
    }
    return 'application/octet-stream';
  }
}
