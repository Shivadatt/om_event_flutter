import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder:
          (context, url) =>
              placeholder ??
              Container(
                color: Colors.grey.shade100,
                width: width,
                height: height,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
      errorWidget:
          (context, url, error) =>
              placeholder ??
              Container(
                color: Colors.grey.shade200,
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
