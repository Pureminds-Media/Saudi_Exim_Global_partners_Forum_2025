import 'package:flutter/widgets.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:shimmer/shimmer.dart';

class CachedUrlImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width, height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final SecureImageCache cache;
  final Color? color;
  final BlendMode? colorBlendMode;
  final bool refreshNetwork;

  /// Shimmer config
  final bool shimmerEnabled;
  final Duration shimmerPeriod;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const CachedUrlImage(
    this.url, {
    super.key,
    required this.cache,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.shimmerEnabled = true,
    this.shimmerPeriod = const Duration(milliseconds: 1200),
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.color,
    this.colorBlendMode,
    this.refreshNetwork = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth =
            width ??
            (constraints.maxWidth.isFinite ? constraints.maxWidth : null);
        final resolvedHeight =
            height ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : null);

        Widget loadingFallback() {
          if (shimmerEnabled) {
            return _ShimmerBox(
              width: resolvedWidth,
              height: resolvedHeight,
              borderRadius: borderRadius,
              period: shimmerPeriod,
              baseColor: shimmerBaseColor,
              highlightColor: shimmerHighlightColor,
            );
          }
          return placeholder ??
              SizedBox(
                width: resolvedWidth,
                height: resolvedHeight,
                child: const ColoredBox(color: Color(0xFFE5E5E5)),
              );
        }

        Widget builder(ImageProvider? img) {
          Widget content;
          if (img == null) {
            content = loadingFallback();
          } else {
            content = Image(
              image: img,
              fit: fit,
              width: resolvedWidth,
              height: resolvedHeight,
              color: color,
              colorBlendMode: colorBlendMode,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: frame != null
                      ? child
                      : KeyedSubtree(
                          key: const ValueKey('cached_url_image#loading'),
                          child: loadingFallback(),
                        ),
                );
              },
            );
          }

          return borderRadius == null
              ? content
              : ClipRRect(borderRadius: borderRadius!, child: content);
        }

        return StreamBuilder<ImageProvider>(
          stream: cache.imageStream(
            url,
            refresh: refreshNetwork,
          ), // cached-first, then refresh-if-changed
          builder: (context, snap) => builder(snap.data),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width, height;
  final BorderRadius? borderRadius;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
    required this.period,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    // In dark mode, avoid near-black for better contrast against pure black UIs.
    final base = baseColor ?? const Color(0xFFE6E6E6);
    final highlight = highlightColor ?? const Color(0xFFF5F5F5);

    final skeleton = SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );

    // RepaintBoundary helps keep the shimmer from repainting unrelated widgets.
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
