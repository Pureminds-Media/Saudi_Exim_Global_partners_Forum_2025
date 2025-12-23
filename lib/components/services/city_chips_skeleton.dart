import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Horizontal skeleton placeholders resembling the city chips row.
class CityChipsSkeleton extends StatelessWidget {
  const CityChipsSkeleton({
    super.key,
    this.count = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  });

  final int count;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipSkeleton(context),
          // Divider matching the chips row layout
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFFDFDFDF),
          ),
          for (int i = 0; i < count; i++)
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 12),
              child: _ChipSkeleton(),
            ),
        ],
      ),
    );
  }

  Widget _chipSkeleton(BuildContext context) => const _ChipSkeleton();
}

class _ChipSkeleton extends StatelessWidget {
  const _ChipSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFFE6E6E6);
    final highlight = const Color(0xFFF5F5F5);

    Widget shimmerBox({double? width, double? height, BorderRadius? radius}) {
      final box = SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: base,
            borderRadius: radius ?? BorderRadius.circular(12),
          ),
        ),
      );
      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: box,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image placeholder
        shimmerBox(width: 56, height: 56, radius: BorderRadius.circular(12)),
        const SizedBox(height: 8),
        // Label line placeholder
        shimmerBox(width: 58, height: 12, radius: BorderRadius.circular(4)),
      ],
    );
  }
}
