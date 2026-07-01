import 'seo_constants.dart';
import 'seo_models.dart';

/// Mapping configurations mapping route paths to page-specific [SeoMetadata] contexts.
class SeoRoutes {
  SeoRoutes._();

  /// Map of route path keys to static [SeoMetadata] declarations.
  static final Map<String, SeoMetadata> routesMap = {
    '/': const SeoMetadata(
      title: SeoConstants.defaultTitle,
      description: SeoConstants.defaultDesc,
      keywords: SeoConstants.defaultKeywords,
      author: SeoConstants.authorName,
      canonicalUrl: SeoConstants.baseDomain,
      ogImage: SeoConstants.defaultImage,
      ogType: "website",
      twitterCard: "summary_large_image",
    ),
    '/docs': const SeoMetadata(
      title: "Developer API Documentation — Om Events",
      description:
          "Explore the open-source client schemas, booking REST endpoints, and integration guides for the Om Events platforms.",
      keywords:
          "om events api, developer docs, integration guides, database structure",
      author: SeoConstants.authorName,
      canonicalUrl: "${SeoConstants.baseDomain}/docs",
      ogImage: SeoConstants.defaultImage,
      ogType: "article",
      twitterCard: "summary_large_image",
    ),
    '/login': const SeoMetadata(
      title: "Team Login Portal — Om Events",
      description:
          "Secure login portal for Om Events managers, staff decorators, and administrator roles.",
      keywords: "admin login, manager console, team studio",
      author: SeoConstants.authorName,
      canonicalUrl: "${SeoConstants.baseDomain}/login",
      ogImage: SeoConstants.defaultImage,
      ogType: "website",
      twitterCard: "summary_large_image",
    ),
    '/admin/dashboard': const SeoMetadata(
      title: "Manager Console Dashboard — Om Events",
      description:
          "Analyze active studio leads, review transaction ledgers, and manage catalog categories.",
      keywords: "metrics crm, recent leads list, revenue tracking",
      author: SeoConstants.authorName,
      canonicalUrl: "${SeoConstants.baseDomain}/admin/dashboard",
      ogImage: SeoConstants.defaultImage,
      ogType: "website",
      twitterCard: "summary_large_image",
    ),
  };

  /// Returns matching metadata for a given path, or defaults to the home-page meta context.
  static SeoMetadata getMetadataForPath(String path) {
    // Sanitizes trailing slashes or subpaths
    final cleanPath = path == '/home' ? '/' : path;
    return routesMap[cleanPath] ?? routesMap['/']!;
  }
}
