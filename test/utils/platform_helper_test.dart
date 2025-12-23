import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/utils/platform_helper.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('isAndroid returns true when platform is android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(PlatformHelper.isAndroid, isTrue);
    expect(PlatformHelper.isIOS, isFalse);
  });

  test('isIOS returns true when platform is ios', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(PlatformHelper.isIOS, isTrue);
    expect(PlatformHelper.isAndroid, isFalse);
  });
}
