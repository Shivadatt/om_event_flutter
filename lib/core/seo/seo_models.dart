/// Model representing SEO metadata configuration for a specific route.
class SeoMetadata {
  /// The document title.
  final String title;

  /// The meta description.
  final String description;

  /// The meta keywords.
  final String keywords;

  /// The author name.
  final String author;

  /// The dynamic canonical URL of the page.
  final String canonicalUrl;

  /// The OpenGraph representation image.
  final String ogImage;

  /// The OpenGraph content type (e.g. website, product).
  final String ogType;

  /// The Twitter Card display type (e.g. summary_large_image).
  final String twitterCard;

  /// JSON-LD Structured Data Schema script.
  final String? jsonLd;

  /// Creates a [SeoMetadata] container with all required meta parameters.
  const SeoMetadata({
    required this.title,
    required this.description,
    required this.keywords,
    required this.author,
    required this.canonicalUrl,
    required this.ogImage,
    required this.ogType,
    required this.twitterCard,
    this.jsonLd,
  });
}
