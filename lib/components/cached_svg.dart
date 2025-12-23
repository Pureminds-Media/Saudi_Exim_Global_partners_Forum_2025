import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:shimmer/shimmer.dart';

class CachedSvg extends StatelessWidget {
  final String url;
  final SecureImageCache cache;
  final double? width, height;
  final BoxFit fit;
  final Color? color;
  final BlendMode colorBlendMode;
  final String? semanticsLabel;

  // Shimmer config
  final bool shimmerEnabled;
  final Duration shimmerPeriod;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;
  final bool refreshNetwork;

  const CachedSvg(
    this.url, {
    super.key,
    required this.cache,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
    this.semanticsLabel,
    this.shimmerEnabled = true,
    this.shimmerPeriod = const Duration(milliseconds: 1200),
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.refreshNetwork = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget builder(Uint8List? bytes) {
      if (bytes == null) {
        if (!shimmerEnabled) {
          return SizedBox(width: width, height: height);
        }
        return _ShimmerBox(
          width: width,
          height: height,
          period: shimmerPeriod,
          baseColor: shimmerBaseColor,
          highlightColor: shimmerHighlightColor,
        );
      }
      return SvgPicture.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        semanticsLabel: semanticsLabel,
        colorFilter: color != null
            ? ColorFilter.mode(color!, colorBlendMode)
            : null,
      );
    }

    return StreamBuilder<Uint8List>(
      stream: cache.svgBytesStream(url, refresh: refreshNetwork),
      builder: (context, snap) => builder(snap.data),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width, height;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.period,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final base = baseColor ?? const Color(0xFFE6E6E6);
    final highlight = highlightColor ?? const Color(0xFFF5F5F5);

    final skeleton = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );

    return RepaintBoundary(
      child: Shimmer.fromColors(
        period: period,
        baseColor: base,
        highlightColor: highlight,
        child: ExcludeSemantics(child: skeleton),
      ),
    );
  }
}
