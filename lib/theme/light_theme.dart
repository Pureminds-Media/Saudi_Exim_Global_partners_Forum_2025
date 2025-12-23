import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// The single light theme for the application.
final TextTheme _baseTextTheme = GoogleFonts.alexandriaTextTheme();

final TextTheme _appTextTheme = _baseTextTheme.copyWith(
  bodyLarge: _baseTextTheme.bodyLarge?.copyWith(height: 1.5),
  bodyMedium: _baseTextTheme.bodyMedium?.copyWith(height: 1.5),
  labelLarge: _baseTextTheme.labelLarge?.copyWith(
    fontWeight: FontWeight.w600,
    height: 1.2,
  ),
);

TextStyle get _labelLarge =>
    _appTextTheme.labelLarge ??
    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

RoundedRectangleBorder get _buttonShape =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

const EdgeInsets _buttonPadding = EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 12,
);

ButtonStyle _baseElevatedStyle() => ElevatedButton.styleFrom(
  minimumSize: const Size(64, 48),
  padding: _buttonPadding,
  tapTargetSize: MaterialTapTargetSize.padded,
  textStyle: _labelLarge,
  shape: _buttonShape,
  backgroundColor: AppColors.primary,
  foregroundColor: AppColors.background,
);

ButtonStyle _baseFilledStyle(ColorScheme colorScheme) => FilledButton.styleFrom(
  minimumSize: const Size(64, 48),
  padding: _buttonPadding,
  tapTargetSize: MaterialTapTargetSize.padded,
  textStyle: _labelLarge,
  shape: _buttonShape,
  backgroundColor: colorScheme.primary,
  foregroundColor: colorScheme.onPrimary,
);

ButtonStyle _baseOutlinedStyle(ColorScheme colorScheme) =>
    OutlinedButton.styleFrom(
      minimumSize: const Size(64, 48),
      padding: _buttonPadding,
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: _labelLarge,
      shape: _buttonShape,
      side: BorderSide(color: colorScheme.primary, width: 1.5),
      foregroundColor: colorScheme.primary,
    );

ButtonStyle _baseTextButtonStyle(ColorScheme colorScheme) =>
    TextButton.styleFrom(
      minimumSize: const Size(64, 48),
      padding: _buttonPadding,
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: _labelLarge,
      foregroundColor: colorScheme.primary,
      shape: _buttonShape,
    );

final ThemeData lightTheme = () {
  final colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: Colors.red,
    surface: AppColors.background,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: _appTextTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(style: _baseElevatedStyle()),
    filledButtonTheme: FilledButtonThemeData(
      style: _baseFilledStyle(colorScheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _baseOutlinedStyle(colorScheme),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _baseTextButtonStyle(colorScheme),
    ),
  );
}();
