import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Centralized Image loader with CachedNetworkImage and fallback states.
class AppImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, width: width, height: height, fit: fit);
    }
    
    // Calculate device pixel ratio for sharper mem cached images if width/height are provided
    final int? memCacheWidth = width != null ? (width! * 2).toInt() : null;
    final int? memCacheHeight = height != null ? (height! * 2).toInt() : null;

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) =>
          placeholder ??
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              color: Colors.white,
            ),
          ),
      errorWidget: (context, url, error) =>
          placeholder ??
          Container(
            color: Colors.grey.shade100,
            width: width,
            height: height,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
            ),
          ),
    );
  }
}
