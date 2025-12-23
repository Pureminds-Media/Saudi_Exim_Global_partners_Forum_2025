import 'package:flutter/material.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:saudiexim_mobile_app/views/services/widgets/pinned_header_delegate.dart';

class CityTitleHeader extends StatelessWidget {
  const CityTitleHeader({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.heroTag,
    this.titleColor,
  });

  final int selectedIndex;
  final String title;
  final String heroTag;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: PinnedHeaderDelegate(
        minExtent: 48,
        maxExtent: 56,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerStart,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
            child: Hero(
              key: ValueKey<int>(selectedIndex),
              tag: heroTag,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: titleColor ?? AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Non-sliver variant of the same header to enable reuse in box layouts.
class CityTitleHeaderBox extends StatelessWidget {
  const CityTitleHeaderBox({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.heroTag,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.backgroundColor = Colors.white,
    this.titleColor,
  });

  final int selectedIndex;
  final String title;
  final String heroTag;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container
    (
      height: height,
      color: backgroundColor,
      padding: padding,
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: Hero(
          key: ValueKey<int>(selectedIndex),
          tag: heroTag,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: titleColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
