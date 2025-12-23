import 'package:flutter/material.dart';

/// Compile-time flag for enabling responsive polish work.
///
/// Toggle with `--dart-define=ENABLE_RESPONSIVE_POLISH=false` to revert quickly.
const bool kEnableResponsivePolish = bool.fromEnvironment(
  'ENABLE_RESPONSIVE_POLISH',
  defaultValue: true,
);

/// Global text scaling clamp (see UX consistency plan).
const double kMinTextScaleFactor = 1.0;
const double kMaxTextScaleFactor = 1.4;

/// Slightly tighter clamp for dense data views like agenda tables.
const double kDenseMaxTextScaleFactor = 1.2;

/// Breakpoints derived from the UX hardening plan.
const double kCompactWidthBreakpoint = 360;
const double kWideWidthBreakpoint = 600;

/// Calculates page padding based on responsive breakpoints.
EdgeInsets responsivePagePadding(double maxWidth) {
  if (maxWidth >= kWideWidthBreakpoint) {
    return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
  }
  if (maxWidth <= kCompactWidthBreakpoint) {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }
  return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
}

/// Helper to clamp text scaling when the responsive polish flag is on.
Widget maybeClampTextScaling(
  BuildContext context, {
  required Widget child,
  double minScaleFactor = kMinTextScaleFactor,
  double maxScaleFactor = kMaxTextScaleFactor,
}) {
  if (!kEnableResponsivePolish) {
    return child;
  }

  return MediaQuery.withClampedTextScaling(
    minScaleFactor: minScaleFactor,
    maxScaleFactor: maxScaleFactor,
    child: child,
  );
}
