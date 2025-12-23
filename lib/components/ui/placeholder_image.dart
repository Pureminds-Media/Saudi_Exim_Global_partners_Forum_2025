import 'package:flutter/material.dart';

/// Grey rectangle placeholder for future imagery.
class PlaceholderImage extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const PlaceholderImage({
    super.key,
    this.width = 110,
    this.height = 100,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: borderRadius,
      ),
    );
  }
}
