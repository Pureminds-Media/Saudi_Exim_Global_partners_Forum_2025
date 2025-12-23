import 'package:flutter/foundation.dart';

/// Utility methods for determining the current platform.
class PlatformHelper {
  PlatformHelper._();

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
}
