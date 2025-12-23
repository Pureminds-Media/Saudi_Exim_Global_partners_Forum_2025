import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/viewmodels/app_locale_view_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppLocaleViewModel', () {
    test('defaults to Arabic and toggles to English', () {
      final vm = AppLocaleViewModel();
      expect(vm.locale, const Locale('ar'));

      vm.toggle();
      expect(vm.locale, const Locale('en'));

      vm.toggle();
      expect(vm.locale, const Locale('ar'));
    });

    test('setLocale sets provided locale', () {
      final vm = AppLocaleViewModel();
      vm.setLocale(const Locale('en'));
      expect(vm.locale, const Locale('en'));
    });

    group('determineInitialLocale', () {
      const supported = [Locale('ar'), Locale('en')];

      test('matches English device locale variant', () {
        final locale = AppLocaleViewModel.determineInitialLocale(
          deviceLocales: const [Locale('en', 'US')],
          supportedLocales: supported,
        );

        expect(locale, const Locale('en'));
      });

      test('matches Arabic device locale with region', () {
        final locale = AppLocaleViewModel.determineInitialLocale(
          deviceLocales: const [Locale('ar', 'EG')],
          supportedLocales: supported,
        );

        expect(locale, const Locale('ar'));
      });

      test('prefers next supported locale when first unsupported', () {
        final locale = AppLocaleViewModel.determineInitialLocale(
          deviceLocales: const [Locale('fr'), Locale('en')],
          supportedLocales: supported,
        );

        expect(locale, const Locale('en'));
      });

      test('uses fallback when nothing matches', () {
        final locale = AppLocaleViewModel.determineInitialLocale(
          deviceLocales: const [Locale('fr'), Locale('de')],
          supportedLocales: supported,
        );

        expect(locale, const Locale('ar'));
      });

      test('uses fallback when device locales are unavailable', () {
        final locale = AppLocaleViewModel.determineInitialLocale(
          deviceLocales: null,
          supportedLocales: supported,
        );

        expect(locale, const Locale('ar'));
      });
    });
  });
}
