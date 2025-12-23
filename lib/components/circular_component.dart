import 'package:flutter/material.dart';

class CircularComponent extends StatelessWidget {
  final String label;
  final String value;
  final Color backgroundColor;
  final bool labelInside;

  const CircularComponent({
    super.key,
    required this.label,
    required this.value,
    required this.backgroundColor,
    this.labelInside = false,
  });

  @override
  Widget build(BuildContext context) {
    // If labelInside, we will display both the value and the label inside the circle
    Widget circleContent;
    if (labelInside) {
      circleContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20, // Font size for the value
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, // Font size for the label inside the circle
              color: Colors.black54,
            ),
          ),
        ],
      );
    } else {
      // Otherwise, only show the value inside the circle with the label outside
      circleContent = Text(
        value,
        style: const TextStyle(
          fontSize: 20, // Font size for the value inside the circle
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 70, // Make the width bigger for the first row
          height: 70, // Adjust height for larger circles in the first row
          decoration: BoxDecoration(
            color: backgroundColor, // Background color for the circle
            shape: BoxShape.circle, // Circular shape
          ),
          alignment: Alignment.center, // Center the text inside the circle
          child: circleContent,
        ),
        const SizedBox(height: 6), // Space between the circle and the label
        if (!labelInside) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ), // Label below the circle
          ),
        ],
      ],
    );
  }
}
