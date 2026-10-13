import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Centralized Image loader with CachedNetworkImage and fallback states.
class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return placeholder ??
          Container(
            color: Colors.grey.shade100,
            width: width,
            height: height,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
            ),
          );
    }

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ??
            Container(
              color: Colors.grey.shade900,
              width: width,
              height: height,
              child: const Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
              ),
            ),
      );
    }
    
    // Calculate device pixel ratio for sharper mem cached images if finite positive width/height are provided
    final int? memCacheWidth = (width != null && width!.isFinite && width! > 0)
        ? (width! * 2).toInt()
        : null;
    final int? memCacheHeight = (height != null && height!.isFinite && height! > 0)
        ? (height! * 2).toInt()
        : null;

    final safeUrl = url.contains(' ') ? Uri.encodeFull(url) : url;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) =>
          placeholder ??
          Shimmer.fromColors(
            baseColor: isDark ? const Color(0xFF14201A) : Colors.grey.shade200,
            highlightColor: isDark ? const Color(0xFF1E2E24) : Colors.grey.shade50,
            child: Container(
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              color: isDark ? const Color(0xFF101915) : Colors.white,
            ),
          ),
      errorWidget: (context, url, error) =>
          placeholder ??
          Container(
            color: isDark ? const Color(0xFF101915) : Colors.grey.shade100,
            width: width,
            height: height,
            child: Icon(
              Icons.broken_image_outlined,
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
    );
  }
}
