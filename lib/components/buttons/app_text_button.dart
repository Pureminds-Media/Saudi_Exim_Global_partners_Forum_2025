import 'package:flutter/material.dart';

/// A reusable text-only button using [TextButton].
class AppTextButton extends StatelessWidget {
  /// Label displayed inside the button.
  final String label;

  /// Callback triggered when the button is pressed.
  final VoidCallback onPressed;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
