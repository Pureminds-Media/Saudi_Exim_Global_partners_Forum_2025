import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// AppBar presence check label for the Home route
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get titleHome;

  /// AppBar presence check label for the Services route
  ///
  /// In en, this message translates to:
  /// **'Support Services'**
  String get titleServices;

  /// AppBar presence check label for the Agenda route
  ///
  /// In en, this message translates to:
  /// **'Forum Agenda'**
  String get titleAgenda;

  /// AppBar presence check label for the Menu route
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get titleMenu;

  /// Header text at the top of the Menu screen
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuHeader;

  /// Menu item: forum agenda
  ///
  /// In en, this message translates to:
  /// **'Forum Agenda'**
  String get menuAgenda;

  /// Menu item: venue and date
  ///
  /// In en, this message translates to:
  /// **'Venue & Date'**
  String get menuLocationDate;

  /// Menu item: about the forum (image page)
  ///
  /// In en, this message translates to:
  /// **'About the Forum'**
  String get menuAboutForum;

  /// Menu item: who we are (about)
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get menuWhoWeAre;

  /// Menu item: support services
  ///
  /// In en, this message translates to:
  /// **'Support Services'**
  String get menuSupportServices;

  /// Menu item: inspiring partners
  ///
  /// In en, this message translates to:
  /// **'Inspiring Partnerships'**
  String get menuInspiringPartners;

  /// Menu item: forum editions/copies
  ///
  /// In en, this message translates to:
  /// **'Forum Editions'**
  String get menuForumCopies;

  /// Menu item: news
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get menuNews;

  /// Menu item: Saudi Arabia section
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get menuSaudi;

  /// Menu item: speakers
  ///
  /// In en, this message translates to:
  /// **'Speakers'**
  String get menuSpeakers;

  /// Badge next to certain menu items indicating new items
  ///
  /// In en, this message translates to:
  /// **'+10 New'**
  String get badgeNew10;

  /// Bottom nav label: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav label: Services
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navServices;

  /// Bottom nav label: Agenda
  ///
  /// In en, this message translates to:
  /// **'Agenda'**
  String get navAgenda;

  /// Bottom nav label: Menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// Agenda tab: first day label
  ///
  /// In en, this message translates to:
  /// **'Day One'**
  String get agendaDayOne;

  /// Agenda tab: second day label
  ///
  /// In en, this message translates to:
  /// **'Day Two'**
  String get agendaDayTwo;

  /// Download agenda button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get agendaDownload;

  /// Label for time gutter in session card
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get agendaTime;

  /// Header above bullet list of session topics
  ///
  /// In en, this message translates to:
  /// **'Session Topics'**
  String get agendaSessionTopics;

  /// No description provided for @agendaDownloadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Download link coming soon'**
  String get agendaDownloadComingSoon;

  /// Menu item linking to regulatory disclosures
  ///
  /// In en, this message translates to:
  /// **'Service Providers & Data'**
  String get menuRegulatoryInfo;

  /// Page title for the regulatory disclosure page
  ///
  /// In en, this message translates to:
  /// **'Service Providers & Data'**
  String get regulatoryDisclosureTitle;

  /// Introductory copy for the regulatory disclosure page
  ///
  /// In en, this message translates to:
  /// **'This page explains who delivers the services in the Saudi EXIM Global Partners Forum app and how sensitive information is handled.'**
  String get regulatoryDisclosureIntro;

  /// Heading describing the service providers section
  ///
  /// In en, this message translates to:
  /// **'Who provides the services in this app?'**
  String get regulatoryDisclosureServiceProvidersTitle;

  /// Bullet describing the Saudi EXIM provider
  ///
  /// In en, this message translates to:
  /// **'Saudi Export-Import Bank (Saudi EXIM) – a government-owned export credit agency licensed in Saudi Arabia. It sponsors, funds, and supervises all services and logistics listed in the app.'**
  String get regulatoryDisclosureProviderSaudiExim;

  /// Bullet describing delivery partners
  ///
  /// In en, this message translates to:
  /// **'Forum delivery partners – official contractors engaged by Saudi EXIM to operate on-site logistics, registration, and hospitality during the Global Partners Forum.'**
  String get regulatoryDisclosureProviderForum;

  /// Heading for the data handling section
  ///
  /// In en, this message translates to:
  /// **'How we handle sensitive information'**
  String get regulatoryDisclosureDataHandlingTitle;

  /// Body text explaining data handling
  ///
  /// In en, this message translates to:
  /// **'Registration forms and document uploads open Saudi EXIM-hosted web portals secured with HTTPS. The mobile app never stores ID documents, signatures, or payment details on the device.'**
  String get regulatoryDisclosureDataHandlingBody;

  /// Heading explaining Mohamed Zaiter's relationship
  ///
  /// In en, this message translates to:
  /// **'Role of Mohamed Zaiter'**
  String get regulatoryDisclosureRelationshipTitle;

  /// Body text describing Mohamed Zaiter's relationship to the providers
  ///
  /// In en, this message translates to:
  /// **'Mohamed Zaiter serves as the digital product lead contracted by Saudi EXIM to manage and maintain this application. He does not provide independent financial services and does not collect or store attendee data outside of Saudi EXIM’s secured systems.'**
  String get regulatoryDisclosureRelationshipBody;

  /// Dialog title when requesting camera permission
  ///
  /// In en, this message translates to:
  /// **'Camera access required'**
  String get cameraPermissionTitle;

  /// Dialog body explaining why camera access is needed
  ///
  /// In en, this message translates to:
  /// **'The registration portal may ask you to scan your badge or identification. Allow camera access so the official Saudi EXIM team can verify your credentials.'**
  String get cameraPermissionRationale;

  /// Message shown when the user denies the camera permission
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to continue registration.'**
  String get cameraPermissionDenied;

  /// Button label to open the device settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get cameraPermissionSettings;

  /// Button label to dismiss the camera permission dialog
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get cameraPermissionNotNow;

  /// Error shown when launchUrl fails
  ///
  /// In en, this message translates to:
  /// **'We couldn't open the registration portal. Please try again.'**
  String get cameraPermissionLaunchFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
