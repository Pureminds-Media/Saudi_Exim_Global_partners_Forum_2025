// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleHome => 'Home';

  @override
  String get titleServices => 'Support Services';

  @override
  String get titleAgenda => 'Forum Agenda';

  @override
  String get titleMenu => 'Menu';

  @override
  String get menuHeader => 'Menu';

  @override
  String get menuAgenda => 'Forum Agenda';

  @override
  String get menuLocationDate => 'Venue';

  @override
  String get menuAboutForum => 'About the Forum';

  @override
  String get menuWhoWeAre => 'Who We Are';

  @override
  String get menuSupportServices => 'Nearby Services';

  @override
  String get menuInspiringPartners => 'Inspiring Partnerships';

  @override
  String get menuForumCopies => 'Forum Editions';

  @override
  String get menuNews => 'News';

  @override
  String get menuSaudi => 'Saudi Arabia';

  @override
  String get menuSpeakers => 'Speakers';

  @override
  String get badgeNew10 => '+10 New';

  @override
  String get navHome => 'Home';

  @override
  String get navLocation => 'Venue';

  @override
  String get navMenu => 'Menu';

  @override
  String get servicesNearby => 'Nearby Services';

  @override
  String get menuRegisterNow => 'Register Now';

  @override
  String get cityAllSaudia => 'All Saudi Arabia';

  @override
  String get agendaDayOne => 'Day One';

  @override
  String get agendaDayTwo => 'Day Two';

  @override
  String get agendaDownload => 'Download';

  @override
  String agendaDownloadSuccess(String day) {
    return 'Agenda for $day ready to share.';
  }

  @override
  String get agendaDownloadFailed =>
      'Unable to generate the agenda PDF. Please try again.';

  @override
  String get agendaTime => 'Time';

  @override
  String get agendaSessionTopics => 'Session Topics';

  @override
  String get agendaDownloadComingSoon => 'Download link coming soon';

  @override
  String get agendaTitle => 'Agenda';

  @override
  String get agendaDayOneHeading =>
      'Global Transitions and Opportunities in the Saudi Economy';

  @override
  String get agendaDayTwoHeading =>
      'Innovation and Finance in the Global South';

  @override
  String get menuOverview => 'Overview';

  @override
  String get menuSponsorship => 'Sponsorship';

  @override
  String get sponsorTypeStrategic => 'Strategic Partner';

  @override
  String get sponsorTypeDiamond => 'Diamond Partner';

  @override
  String get sponsorTypeGold => 'Gold Partner';

  @override
  String get noServicesAvailable => 'No services available';

  @override
  String get serviceInfoTitle => 'Service Information';

  @override
  String get websiteTitle => 'Website';

  @override
  String get locationTitle => 'Venue';

  @override
  String get notFound => 'Not found';

  @override
  String get back => 'Back';

  @override
  String get cameraPermissionTitle => 'Camera access required';

  @override
  String get cameraPermissionRationale =>
      'The registration portal may ask you to scan your badge or identification. Allow camera access so the official Saudi EXIM team can verify your credentials.';

  @override
  String get cameraPermissionDenied =>
      'Camera access is required to continue registration.';

  @override
  String get cameraPermissionSettings => 'Open Settings';

  @override
  String get cameraPermissionNotNow => 'Not now';

  @override
  String get cameraPermissionLaunchFailed =>
      'We couldn\'t open the registration portal. Please try again.';

  @override
  String get googleMaps => 'Google Maps';

  @override
  String get openMap => 'Open Map';

  @override
  String get noNetworkTitle => 'You\'re offline';

  @override
  String get noNetworkSubtitle => 'Check your connection to continue';

  @override
  String get noNetworkDescription =>
      'We couldn\'t reach the forum servers. Please reconnect to Wi‑Fi or mobile data and try again.';

  @override
  String get noNetworkRetry => 'Retry';
}
