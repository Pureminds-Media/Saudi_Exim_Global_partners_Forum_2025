import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/utils/hero_utils.dart';
import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:saudiexim_mobile_app/utils/haptic_feedback_helper.dart';

class CityFilterItem extends StatefulWidget {
  final String label;
  final String image;
  final bool selected;
  final VoidCallback? onTap;

  const CityFilterItem({
    super.key,
    required this.label,
    required this.image,
    this.selected = false,
    this.onTap,
  });

  @override
  State<CityFilterItem> createState() => _CityFilterItemState();
}

class _CityFilterItemState extends State<CityFilterItem>
    with SingleTickerProviderStateMixin {
  static const _imgSize = 56.0;
  static const _imgSizeSelected = 64.0;
  static const _fontSize = 13.0;
  static const _fontSizeSelected = 14.5;
  static const _radius = 12.0;
  static const _duration = Duration(milliseconds: 220);

  late final AnimationController _c;
  late final Animation<double> _curve; // for smooth tweens
  late final Animation<double> _popCurve; // for image “pop”

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: _duration,
      value: widget.selected ? 1 : 0,
    );
    _curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _popCurve = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
  }

  @override
  void didUpdateWidget(covariant CityFilterItem old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      widget.selected ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cache = context.read<SecureImageCache>();

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: SizedBox(
        width: widget.selected ? 70 : 64,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius + 2),
            onTap: () async {
              await triggerSelectionHaptic();
              widget.onTap?.call();
            },
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _curve.value; // 0→1
                final p = _popCurve.value; // eased differently
                final size = lerpDouble(_imgSize, _imgSizeSelected, t)!;
                final borderW = lerpDouble(0, 2, t)!;
                final shadowOpacity = 0.10 * t; // subtle
                final fontSize = lerpDouble(_fontSize, _fontSizeSelected, t)!;
                final fontWeight = FontWeight.lerp(
                  FontWeight.w500,
                  FontWeight.w700,
                  t,
                )!;
                final color = t > 0
                    ? AppColors.textPrimary
                    : const Color(0xFF6E6E6E);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Picture card
                    Hero(
                      tag: 'city-chip-img-${widget.label}',
                      // Keep hero shape consistent during flight
                      flightShuttleBuilder: shapedHeroFlight(
                        borderRadius: BorderRadius.circular(_radius),
                      ),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_radius),
                          border: Border.all(
                            color: AppColors.primary,
                            width: borderW,
                          ),
                          boxShadow: shadowOpacity == 0
                              ? const []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      shadowOpacity,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Transform.scale(
                          scale: lerpDouble(
                            1.0,
                            _imgSizeSelected / _imgSize,
                            p,
                          )!,
                          child: _buildImage(widget.image, cache),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Label
                    Hero(
                      tag: 'city-chip-label-${widget.label}',
                      child: DefaultTextStyle(
                        style:
                            (Theme.of(context).textTheme.labelMedium ??
                                    const TextStyle())
                                .copyWith(
                                  fontSize: fontSize,
                                  fontWeight: fontWeight,
                                  color: color,
                                ),
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String src, SecureImageCache cache) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return CachedUrlImage(src, cache: cache, fit: BoxFit.cover);
    }
    if (src.isEmpty) return const ColoredBox(color: Color(0xFFD9D9D9));
    return Image.asset(src, fit: BoxFit.cover);
  }
}
