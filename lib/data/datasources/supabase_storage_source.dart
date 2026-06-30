import 'package:http/http.dart' as http;

class SupabaseStorageSource {
  final String projectUrl;
  final String apiKey;
  final String bucketName;

  SupabaseStorageSource({
    required this.projectUrl,
    required this.apiKey,
    this.bucketName = 'om-event-media',
  });

  Future<String> uploadFile(String filePath, List<int> fileBytes, String contentType, {String? bucket}) async {
    final activeBucket = bucket ?? bucketName;
    // Standardize URL
    final cleanUrl = projectUrl.endsWith('/') ? projectUrl : '$projectUrl/';
    final uploadUrl = Uri.parse('${cleanUrl}storage/v1/object/$activeBucket/$filePath');

    final response = await http.post(
      uploadUrl,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'ApiKey': apiKey,
        'Content-Type': contentType,
      },
      body: fileBytes,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Returns the public URL for serving
      return '${cleanUrl}storage/v1/object/public/$activeBucket/$filePath';
    } else {
      throw Exception('Failed to upload file to Supabase Storage: ${response.body}');
    }
  }
}
