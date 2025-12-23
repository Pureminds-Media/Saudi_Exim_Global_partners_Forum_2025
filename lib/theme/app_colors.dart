import 'package:flutter/material.dart';

/// Centralized color definitions for the SaudiExim app (real palette).
class AppColors {
  AppColors._();

  // ── Brand / Primary ───────────────────────────────────────────────────────────

  /// Main brand color (primary buttons, highlights, key UI elements).
  static const Color primary = Color(0xFF02548C);

  /// Darker variant when needed (headers/overlays); same as brand unless a separate tone is provided.
  static const Color primaryDark = Color(0xFF02548C);

  // ── Text ──────────────────────────────────────────────────────────────────────

  /// Headings and high-emphasis text.
  static const Color textPrimary = Color(0xFF02548C);

  /// Accents and secondary emphasis (e.g., links, metadata tags).
  static const Color textSecondary = Color(0xFF00B3AF);

  /// Body copy and long-form text; balanced readability.
  static const Color textBody = Color(0xFF737373);

  // ── Backgrounds ───────────────────────────────────────────────────────────────

  /// Default page/app background.
  static const Color background = Color(0xFFFFFFFF);

  /// Subtle surface/section background (cards, panels, table rows).
  static const Color backgroundAlt = Color(0xFFF8F8F8);

  // ── Borders ──────────────────────────────────────────────────────────────────

  /// Hairline borders/dividers (1px), light and unobtrusive.
  static const Color border = Color(0xFFDFDFDF);
  static const Color darkBorder = Color(0xFF777777);

  // ── Legacy Aliases (keep for backward compatibility) ─────────────────────────

  /// Alias for primary text. Prefer [textPrimary] in new code.
  static const Color text = textPrimary;

  /// Legacy "secondary" accent. Prefer [textSecondary] in new code.
  static const Color secondary = Color(0xFF00B3AF);

  /// Utility gray used in older views; safe to remove if unused.
  static const Color grayShade = Color(0xFFD9D9D9);

  // ── Utility / Neutrals ────────────────────────────────────────────────────────
  static const Color black = Color(0xFF1C1F1F); // requested "black"

  static const Color darkBlue = Color(0xFF02548C); // Existing primary color
  static const Color teal = Color(0xFF33AAA6); // New teal color
  static const Color green = Color(0xFF769B0D); // New green color
  // ── Gradients ─────────────────────────────────────────────────────────────────

  /// Brand vertical gradient (top → bottom).
  ///
  /// Edges at ~90% opacity for a soft fade:
  /// - 0%:   #02548C @ 90% alpha (0xE6)
  /// - 33%:  #02548C @ 100% alpha
  /// - 66%:  #02548C @ 100% alpha
  /// - 100%: #02548C @ 90% alpha (0xE6)
  static const LinearGradient brandVerticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xE602548C),
      Color(0xFF02548C),
      Color(0xFF02548C),
      Color(0xE602548C),
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
  );
}
