import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A reusable primary button styled with [ElevatedButton].
class PrimaryButton extends StatelessWidget {
  /// Label displayed inside the button.
  final String label;

  /// Callback triggered when the button is pressed.
  final VoidCallback onPressed;

  /// Optional minimum width of the button. Defaults to 64.
  final double? width;

  /// Optional minimum height of the button. Defaults to 48.
  final double? height;

  /// Optional background color. Defaults to [AppColors.primary].
  final Color? backgroundColor;

  /// Optional border radius. Defaults to `BorderRadius.circular(12)`.
  final BorderRadiusGeometry? borderRadius;

  /// Optional internal padding. Defaults to `EdgeInsets.symmetric(horizontal: 20, vertical: 12)`.
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).elevatedButtonTheme.style;
    final fallbackStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: AppColors.background,
      minimumSize: Size(width ?? 64, height ?? 48),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: Theme.of(context).textTheme.labelLarge,
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: themeStyle?.merge(fallbackStyle) ?? fallbackStyle,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
