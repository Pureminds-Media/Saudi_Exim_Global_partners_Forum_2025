import 'package:flutter/material.dart';

/// Holds the current app [Locale] and exposes a simple toggle.
/// Note: This only flips the locale. Static strings remain as-is for now.
class AppLocaleViewModel extends ChangeNotifier {
  AppLocaleViewModel({Locale? initial})
    : _locale = initial ?? const Locale('ar');

  /// Chooses an appropriate initial locale from the device locales.
  ///
  /// Iterates through the provided [deviceLocales] looking for a matching
  /// language code in [supportedLocales]. The first match wins. Falls back to
  /// [fallback] (Arabic) if nothing matches or lists are empty.
  static Locale determineInitialLocale({
    Iterable<Locale>? deviceLocales,
    required Iterable<Locale> supportedLocales,
    Locale fallback = const Locale('ar'),
  }) {
    if (deviceLocales != null) {
      for (final device in deviceLocales) {
        final deviceLanguage = device.languageCode.toLowerCase();
        for (final supported in supportedLocales) {
          if (supported.languageCode.toLowerCase() == deviceLanguage) {
            return supported;
          }
        }
      }
    }

    return fallback;
  }

  Locale _locale;
  Locale get locale => _locale;

  set locale(Locale value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }

  void setLocale(Locale value) => locale = value;

  void toggle() {
    locale = _locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
  }
}
