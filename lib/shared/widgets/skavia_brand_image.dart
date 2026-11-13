import 'package:flutter/material.dart';

/// Density-aware asset image widget that caps decoded bitmap size to display dimensions,
/// preventing multi-megabyte full-resolution RGBA texture uploads in Flutter Engine.
class SkaviaBrandImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const SkaviaBrandImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final int? cacheW = width != null ? (width! * dpr).round().clamp(16, 1200) : null;
    final int? cacheH = height != null ? (height! * dpr).round().clamp(16, 1200) : null;

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      cacheWidth: cacheW,
      cacheHeight: cacheH,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}

