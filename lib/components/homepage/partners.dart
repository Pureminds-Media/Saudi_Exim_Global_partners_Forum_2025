import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PartnerLogo {
  final String asset;
  final String label; // accessibility
  const PartnerLogo(this.asset, this.label);
}

class Partners extends StatelessWidget {
  final String title;
  final List<PartnerLogo> logos;

  /// Tune these to your taste
  final double cardWidth; // visual width of each pill
  final double cardHeight; // logo area height
  final double radius;

  const Partners({
    super.key,
    required this.logos,
    this.title = 'شراكات ملهمة ',
    this.cardWidth = 250,
    this.cardHeight = 60,
    this.radius = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: cardHeight + 24, // pill + vertical padding
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: logos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = logos[i];
                return _LogoPill(
                  asset: p.asset,
                  label: p.label,
                  width: cardWidth,
                  height: cardHeight,
                  radius: radius,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPill extends StatelessWidget {
  final String asset;
  final String label;
  final double width;
  final double height;
  final double radius;
  const _LogoPill({
    required this.asset,
    required this.label,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Semantics(
          label: label,
          child: ExcludeSemantics(
            child: SizedBox(
              height: height,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  asset,
                  filterQuality: FilterQuality.medium,
                  // Helps you see the card even if the asset path is wrong
                  errorBuilder: (_, __, ___) => Container(
                    width: width - 28,
                    height: height,
                    color: AppColors.backgroundAlt,
                    alignment: Alignment.center,
                    child: const Text('?asset', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
