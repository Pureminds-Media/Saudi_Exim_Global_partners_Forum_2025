import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'platform_helper.dart';

/// Provides a lightweight haptic feedback that works across supported
/// platforms. On Android we optimistically ask for a selection click and queue
/// a light impact fallback because some OEM builds silently ignore the
/// selection effect. If the platform channel itself is unavailable we swallow
/// the error and issue a coarse vibration instead of failing the gesture.
Future<void> triggerSelectionHaptic() async {
  if (kIsWeb) return;

  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        // Attempt the lighter "selection" effect first; some Android builds
        // simply no-op this request, so we queue a light impact as backup
        // without blocking the UI thread.
        await HapticFeedback.selectionClick();
        unawaited(HapticFeedback.lightImpact());
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await HapticFeedback.selectionClick();
        break;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        break;
    }
  } on PlatformException {
    // When haptics are unavailable (older Android builds, emulators, or when
    // the engine hasn't wired the channel yet) we ignore the error. Attempt a
    // coarser vibration on Android as a last resort.
    if (PlatformHelper.isAndroid) {
      await HapticFeedback.vibrate();
    }
  }
}
