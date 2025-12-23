import 'package:flutter/material.dart';

class ImageHolder extends StatelessWidget {
  final String? imagePath;
  final BorderRadius borderRadius;
  final double width;
  final double height;

  const ImageHolder({
    super.key,
    required this.imagePath,
    required this.borderRadius,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image layer
            imagePath != null && imagePath!.isNotEmpty
                ? Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    width: width,
                    height: height,
                  )
                : const SizedBox.expand(), // Empty space if no image is provided
            // Gradient layer (Overlay)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x1F000000), // rgba(0, 0, 0, 0.03) as hex
                    const Color(0x4D000000), // rgba(0, 0, 0, 0.30) as hex
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
