import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).outlinedButtonTheme.style;
    final fallbackStyle = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      minimumSize: const Size(64, 48),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    return OutlinedButton(
      onPressed: onPressed,
      style: themeStyle?.merge(fallbackStyle) ?? fallbackStyle,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
