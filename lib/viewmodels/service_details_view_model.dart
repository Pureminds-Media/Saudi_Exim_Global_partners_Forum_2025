import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/service.dart';
import '../utils/platform_helper.dart';

/// ViewModel for [ServiceDetailsPage] handling link actions.
class ServiceDetailsViewModel extends ChangeNotifier {
  final Service service;
  ServiceDetailsViewModel({required this.service});

  /* ───────────── LINKS / INTENTS ───────────── */

  Future<void> openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @visibleForTesting
  Uri mapUri(String latLng) {
    if (PlatformHelper.isIOS) {
      return Uri.parse('https://maps.apple.com/?q=$latLng');
    }
    return Uri.parse('https://www.google.com/maps/search/?q=$latLng');
  }

  Future<void> openMap() async {
    final link = service.mapLink;
    if (link != null && link.isNotEmpty) {
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
      return;
    }
    final latLng = service.mapLatLng;
    if (latLng != null && latLng.isNotEmpty) {
      await launchUrl(mapUri(latLng), mode: LaunchMode.externalApplication);
    }
  }

  /* ───────────── GETTERS ───────────── */

  String? get website => service.website;

  String? get appDownloadUrl {
    if (PlatformHelper.isIOS) {
      return service.iosDownloadUrl;
    }
    if (PlatformHelper.isAndroid) {
      return service.androidDownloadUrl;
    }
    return service.iosDownloadUrl ?? service.androidDownloadUrl;
  }

  Future<void> openAppDownload() async {
    final url = appDownloadUrl;
    if (url != null) {
      await openUrl(url);
    }
  }

  String? get mapLatLng => service.mapLatLng;
  String? get mapLink => service.mapLink;
  bool get hasMap => ((mapLink ?? '').trim().isNotEmpty) || ((mapLatLng ?? '').trim().isNotEmpty);
}
