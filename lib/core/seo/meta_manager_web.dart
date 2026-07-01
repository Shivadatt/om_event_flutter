// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, avoid_web_libraries_in_dart
import 'dart:html' as html;
import 'seo_models.dart';

/// Web-specific implementation of MetaManager using dart:html.
void updateMetadataImpl(SeoMetadata metadata) {
  // Update Title
  html.document.title = metadata.title;

  // Standard Metadata
  _updateMeta('name', 'description', metadata.description);
  _updateMeta('name', 'keywords', metadata.keywords);
  _updateMeta('name', 'author', metadata.author);

  // Canonical Link
  _updateLink('canonical', metadata.canonicalUrl);

  // OpenGraph Tags
  _updateMeta('property', 'og:title', metadata.title);
  _updateMeta('property', 'og:description', metadata.description);
  _updateMeta('property', 'og:image', metadata.ogImage);
  _updateMeta('property', 'og:url', metadata.canonicalUrl);
  _updateMeta('property', 'og:type', metadata.ogType);

  // Twitter Cards
  _updateMeta('name', 'twitter:title', metadata.title);
  _updateMeta('name', 'twitter:description', metadata.description);
  _updateMeta('name', 'twitter:image', metadata.ogImage);
  _updateMeta('name', 'twitter:card', metadata.twitterCard);

  // JSON-LD script
  _updateJsonLd(metadata.jsonLd);
}

void _updateMeta(String attribute, String attrValue, String content) {
  var element = html.document.querySelector('meta[$attribute="$attrValue"]');
  if (element == null) {
    element = html.document.createElement('meta');
    element.setAttribute(attribute, attrValue);
    html.document.head?.append(element);
  }
  element.setAttribute('content', content);
}

void _updateLink(String rel, String href) {
  var element = html.document.querySelector('link[rel="$rel"]');
  if (element == null) {
    element = html.document.createElement('link');
    element.setAttribute('rel', rel);
    html.document.head?.append(element);
  }
  element.setAttribute('href', href);
}

void _updateJsonLd(String? jsonString) {
  final existing = html.document.querySelectorAll(
    'script[type="application/ld+json"]',
  );
  for (final el in existing) {
    el.remove();
  }
  if (jsonString != null && jsonString.isNotEmpty) {
    final script = html.document.createElement('script');
    script.setAttribute('type', 'application/ld+json');
    script.text = jsonString;
    html.document.head?.append(script);
  }
}
