/// Centralized Supabase Storage bucket name constants.
class AppBuckets {
  AppBuckets._();

  /// Primary media gallery bucket.
  static const String gallery = 'gallery';

  /// Gallery sub-folder for images.
  static const String imagesFolder = 'images';

  /// Gallery sub-folder for videos.
  static const String videosFolder = 'Video';

  /// Supabase project base public URL.
  static const String supabaseBaseUrl =
      'https://kwegyvbgdaednljyhcgm.supabase.co/storage/v1/object/public';

  /// Convenience URL for gallery images folder.
  static const String galleryImagesUrl =
      '$supabaseBaseUrl/$gallery/$imagesFolder';

  /// Convenience URL for gallery videos folder.
  static const String galleryVideosUrl =
      '$supabaseBaseUrl/$gallery/$videosFolder';
}
