import 'package:flutter/material.dart';

/// A reusable outlined button using [OutlinedButton].
class AppOutlinedButton extends StatelessWidget {
  /// Label displayed inside the button.
  final String label;

  /// Callback triggered when the button is pressed.
  final VoidCallback onPressed;

  /// Optional fixed size for the button.
  final Size? size;

  /// Optional padding inside the button.
  final EdgeInsetsGeometry? padding;

  const AppOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: size,
        padding: padding,
      ),
      child: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}
