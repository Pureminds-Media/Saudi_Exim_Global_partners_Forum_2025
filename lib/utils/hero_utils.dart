import 'package:flutter/material.dart';

typedef HeroShuttle =
    Widget Function(
      BuildContext,
      Animation<double>,
      HeroFlightDirection,
      BuildContext,
      BuildContext,
    );

/// Returns a flightShuttleBuilder that keeps a rounded shape during the hero
/// flight. Useful for images or cards with rounded corners.
HeroShuttle shapedHeroFlight({
  BorderRadius? borderRadius,
  Clip clip = Clip.antiAlias,
}) {
  final br = borderRadius ?? BorderRadius.circular(12);
  return (
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final Widget targetChild = direction == HeroFlightDirection.push
        ? (toContext.widget as Hero).child
        : (fromContext.widget as Hero).child;
    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: br,
        clipBehavior: clip,
        child: targetChild,
      ),
    );
  };
}
