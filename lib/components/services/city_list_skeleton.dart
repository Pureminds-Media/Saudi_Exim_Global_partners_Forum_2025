import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Vertical skeleton list for the CitiesPage while data loads.
class CityListSkeleton extends StatelessWidget {
  const CityListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final base = const Color(0xFFE6E6E6);
    final highlight = const Color(0xFFF5F5F5);

    Widget shimmerBox({double? width, double? height, BorderRadius? radius}) =>
        Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: base,
                borderRadius: radius ?? BorderRadius.circular(8),
              ),
            ),
          ),
        );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: count,
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Divider(thickness: 1, color: Color(0xFFDFDFDF)),
      ),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centered title bar skeleton
            Align(
              alignment: Alignment.center,
              child: shimmerBox(
                width: 70,
                height: 28,
                radius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Image card skeleton with rounded corners and subtle shadow
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: shimmerBox(height: 180, radius: BorderRadius.circular(14)),
            ),
          ],
        );
      },
    );
  }
}
