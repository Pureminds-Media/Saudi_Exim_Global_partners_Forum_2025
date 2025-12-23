import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/viewmodels/service_details_view_model.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';

class _FakeUrlLauncher extends UrlLauncherPlatform {
  String? launchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
}

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('openMap launches Google Maps on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    const service = Service(
      id: 's1',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      mapLatLng: '24.7136,46.6753',
    );
    final vm = ServiceDetailsViewModel(service: service);
    final fake = _FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fake;
    await vm.openMap();
    expect(
      fake.launchedUrl,
      'https://www.google.com/maps/search/?q=24.7136,46.6753',
    );
    UrlLauncherPlatform.instance = original;
  });

  test('openMap launches Apple Maps on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const service = Service(
      id: 's1',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      mapLatLng: '24.7136,46.6753',
    );
    final vm = ServiceDetailsViewModel(service: service);
    final fake = _FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fake;
    await vm.openMap();
    expect(fake.launchedUrl, 'https://maps.apple.com/?q=24.7136,46.6753');
    UrlLauncherPlatform.instance = original;
  });

  test('openMap uses mapLink when provided', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    const service = Service(
      id: 's3',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      mapLatLng: '24.7136,46.6753',
      mapLink: 'https://maps.google.com/?q=Diriyah+Museum',
    );
    final vm = ServiceDetailsViewModel(service: service);
    final fake = _FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fake;
    await vm.openMap();
    expect(fake.launchedUrl, service.mapLink);
    UrlLauncherPlatform.instance = original;
  });

  test('openAppDownload launches Android URL on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    const service = Service(
      id: 's2',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      androidDownloadUrl: 'https://example.com/android',
      iosDownloadUrl: 'https://example.com/ios',
    );
    final vm = ServiceDetailsViewModel(service: service);
    final fake = _FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fake;
    await vm.openAppDownload();
    expect(fake.launchedUrl, 'https://example.com/android');
    UrlLauncherPlatform.instance = original;
  });

  test('openAppDownload launches iOS URL on iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const service = Service(
      id: 's2',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      androidDownloadUrl: 'https://example.com/android',
      iosDownloadUrl: 'https://example.com/ios',
    );
    final vm = ServiceDetailsViewModel(service: service);
    final fake = _FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fake;
    await vm.openAppDownload();
    expect(fake.launchedUrl, 'https://example.com/ios');
    UrlLauncherPlatform.instance = original;
  });

  test('appDownloadUrl is null on iOS when only Android link exists', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    const service = Service(
      id: 's3',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      androidDownloadUrl: 'https://example.com/android',
    );
    final vm = ServiceDetailsViewModel(service: service);
    expect(vm.appDownloadUrl, isNull);
  });

  test('appDownloadUrl is null on Android when only iOS link exists', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    const service = Service(
      id: 's4',
      categoryId: 'transport',
      name: 'Test',
      subtitle: '',
      description: 'desc',
      image: '',
      emphasized: false,
      city: 'الرياض',
      iosDownloadUrl: 'https://example.com/ios',
    );
    final vm = ServiceDetailsViewModel(service: service);
    expect(vm.appDownloadUrl, isNull);
  });
}
