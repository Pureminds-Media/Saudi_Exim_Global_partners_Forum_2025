// Bottom navigation bar for the 4 main sections of the app.
//
// Usage:
// - Place inside the shared Scaffold (see `lib/router.dart`).
// - Pass the current index (0..3) that corresponds to the current route.
// - To add a new tab, add a [NavItem] below and update the index mapping in
//   `lib/router.dart` accordingly.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';

class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final String currentPath;
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.currentPath,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with TickerProviderStateMixin {
  // Base container height of the navbar
  static const double _baseBarHeight = 75;
  static const String _fallbackRoute = '/home';

  static const String _menuRoute = '/menu';
  static const int _menuIndex = 3;

  late final List<AnimationController> _itemCtrls;
  late final List<Animation<double>> _itemAnims;
  String? _lastNonMenuRoute;

  // Icons + routes for tabs. Labels come from AppLocalizations.
  final List<NavItem> _navItems = const [
    NavItem('assets/icons/home.svg', '/home'),
    NavItem('assets/icons/agenda.svg', '/agenda'),
    NavItem('assets/icons/services.svg', '/location'),
    NavItem('assets/icons/menu.svg', '/menu'),
  ];

  @override
  void initState() {
    super.initState();

    // Per-item animations used to fade in the label of the selected tab
    _itemCtrls = List.generate(
      _navItems.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      ),
    );
    _itemAnims = _itemCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut))
        .toList();

    if (widget.currentIndex != _menuIndex && widget.currentPath.isNotEmpty) {
      _lastNonMenuRoute = widget.currentPath;
    } else {
      _lastNonMenuRoute = _fallbackRoute;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentIndex < _itemCtrls.length) {
        _itemCtrls[widget.currentIndex].forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentIndex != _menuIndex && widget.currentPath.isNotEmpty) {
      _lastNonMenuRoute = widget.currentPath;
    }

    if (oldWidget.currentIndex != widget.currentIndex) {
      if (oldWidget.currentIndex < _itemCtrls.length) {
        _itemCtrls[oldWidget.currentIndex].reverse();
      }
      if (widget.currentIndex < _itemCtrls.length) {
        _itemCtrls[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _itemCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(BuildContext context, int index) {
    final router = GoRouter.of(context);
    final String targetRoute = _navItems[index].route;
    final bool isMenuTab = index == _menuIndex;
    final bool isCurrentTab = index == widget.currentIndex;

    if (isMenuTab) {
      if (!isCurrentTab) {
        if (widget.currentIndex != _menuIndex &&
            widget.currentPath.isNotEmpty) {
          _lastNonMenuRoute = widget.currentPath;
        }
        context.push(targetRoute);
        return;
      }

      if (widget.currentPath != _menuRoute) {
        context.push(_menuRoute);
        return;
      }

      if (router.canPop()) {
        router.pop();
        return;
      }

      final String fallback = _resolveFallbackRoute();
      if (widget.currentPath != fallback) {
        context.go(fallback);
      }
      return;
    }

    if (isCurrentTab) {
      if (widget.currentPath != targetRoute) {
        context.go(targetRoute);
      }
      return;
    }

    _lastNonMenuRoute = targetRoute;
    context.go(targetRoute);
  }

  String _resolveFallbackRoute() {
    final String? stored = _lastNonMenuRoute;
    if (stored != null && stored.isNotEmpty && stored != _menuRoute) {
      return stored;
    }
    return _fallbackRoute;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    const double verticalMargin = 10;
    final double itemHeight = _baseBarHeight - (verticalMargin * 2);
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double barHeight = _baseBarHeight + bottomInset;
    // Provide localized labels from l10n
    String labelFor(int index) => switch (index) {
          0 => s.navHome,
          1 => s.agendaTitle,
          2 => s.navLocation,
          3 => s.navMenu,
          _ => '',
        };

    // Make the bar as tall as base height + safe-bottom inset to keep
    // content size consistent while filling the home-indicator area.
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        // Force 100% opacity for the navbar background
        color: Theme.of(context).colorScheme.surface.withOpacity(1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false, // avoid shrinking content; we already accounted height
        child: Row(
          children: List.generate(_navItems.length, (index) {
            final bool selected = widget.currentIndex == index;

            // Animate the width share (flex) for the selected item.
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: selected ? 1.6 : 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              builder: (context, animatedFlex, child) {
                return Flexible(
                  flex: (animatedFlex * 1000)
                      .round(), // smooth-ish flex animation
                  child: child!,
                );
              },
              child: _NavItemPill(
                height: itemHeight,
                marginV: verticalMargin,
                iconAsset: _navItems[index].iconAsset,
                label: labelFor(index),
                selected: selected,
                animation: _itemAnims[index],
                onTap: () => _onTap(context, index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// A single tab pill with icon + optional label (visible when selected).
class _NavItemPill extends StatelessWidget {
  const _NavItemPill({
    required this.height,
    required this.marginV,
    required this.iconAsset,
    required this.label,
    required this.selected,
    required this.animation,
    required this.onTap,
  });

  final double height;
  final double marginV;
  final String iconAsset;
  final String label;
  final bool selected;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.primary;
    // Icons: white when selected, AppColors.darkBorder when not
    final Color iconColor = selected ? Colors.white : AppColors.darkBorder;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: height,
        margin: EdgeInsets.symmetric(horizontal: 6, vertical: marginV),
        decoration: BoxDecoration(
          // Selected pill background at 100% opacity
          color: selected ? activeColor.withOpacity(1.0) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(
                  color: activeColor.withAlpha((0.28 * 255).round()),
                  width: 1,
                )
              : null,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: selected
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              // Icon
              SvgPicture.asset(
                iconAsset,
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),

              // Label reveals smoothly next to the icon when selected
              ClipRect(
                child: SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.horizontal,
                  axisAlignment: -1.0,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: FadeTransition(
                      opacity: animation,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String iconAsset;
  final String route;

  /// [iconAsset]: path to the SVG icon
  /// [route]: router path (must exist in `lib/router.dart`)
  const NavItem(this.iconAsset, this.route);
}
