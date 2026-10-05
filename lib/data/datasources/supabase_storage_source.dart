import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SupabaseStorageSource {
  final String projectUrl;
  final String apiKey;
  final String bucketName;

  SupabaseStorageSource({
    required this.projectUrl,
    required this.apiKey,
    this.bucketName = 'gallery',
  });

  Future<String> uploadFile(
    String filePath,
    List<int> fileBytes,
    String contentType, {
    String? bucket,
  }) async {
    final activeBucket = bucket ?? bucketName;
    // Standardize URL
    final cleanUrl = projectUrl.endsWith('/') ? projectUrl : '$projectUrl/';
    final uploadUrl = Uri.parse(
      '${cleanUrl}storage/v1/object/$activeBucket/$filePath',
    );

    debugPrint('[SUPABASE_UPLOAD][START] bucket=$activeBucket path=$filePath bytes=${fileBytes.length}');
    try {
      final response = await http.post(
        uploadUrl,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'ApiKey': apiKey,
          'Content-Type': contentType,
          'x-upsert': 'true',
        },
        body: fileBytes,
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          throw Exception('Supabase storage upload timed out after 12 seconds');
        },
      );

      debugPrint('[SUPABASE_UPLOAD][RESPONSE] status=${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final publicUrl = '${cleanUrl}storage/v1/object/public/$activeBucket/$filePath';
        debugPrint('[SUPABASE_UPLOAD][SUCCESS] url=$publicUrl');
        return publicUrl;
      } else {
        debugPrint('[SUPABASE_UPLOAD][FAILED] status=${response.statusCode} body=${response.body}');
        throw Exception(
          'Failed to upload file to Supabase Storage: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[SUPABASE_UPLOAD][ERROR] $e');
      rethrow;
    }
  }
}
