import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/agenda_view_model.dart'
    as page_vm; // ← مهم
import 'package:saudiexim_mobile_app/viewmodels/splash_page_view_model.dart';
import 'theme/light_theme.dart';
import 'theme/responsive_tokens.dart';

import 'viewmodels/home_view_model.dart';

import 'viewmodels/menu_view_model.dart';
import 'viewmodels/service_catalog_view_model.dart';
import 'viewmodels/app_locale_view_model.dart';
import 'router.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';

/// Global app router configured with GoRouter.
final GoRouter router = createRouter(initialLocation: '/splash');

/// App entry point.
///
/// - Sets up global providers (state objects)
/// - Boots the app with [MyApp]
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
  final supportedLocales = AppLocalizations.supportedLocales;
  final initialLocale = AppLocaleViewModel.determineInitialLocale(
    deviceLocales: platformDispatcher.locales,
    supportedLocales: supportedLocales,
  );

  // Register app-wide providers here. Keep this list focused.
  final List<SingleChildWidget> providers = [
    // Secure image cache (HTTPS-only, disk-backed)
    Provider<SecureImageCache>(create: (_) => SecureImageCache()),
    // Locale switching (AR/EN) used by MaterialApp.locale
    ChangeNotifierProvider(
      create: (_) => AppLocaleViewModel(initial: initialLocale),
    ),
    // Home and services related state
    ChangeNotifierProvider(create: (_) => HomeViewModel()),
    ChangeNotifierProvider(create: (_) => ServiceCatalogViewModel()..init()),
    // Agenda page view model (scoped again inside /agenda route as needed)
    ChangeNotifierProvider(create: (_) => page_vm.AgendaViewModel()),
    ChangeNotifierProvider(create: (_) => SplashPageViewModel()),
    ChangeNotifierProvider(create: (_) => MenuViewModel()),
  ];

  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Current app locale comes from AppLocaleViewModel
    final appLocale = context.watch<AppLocaleViewModel>().locale;

    // MaterialApp configured for routing + localization.
    // Tip for devs: To add new strings, edit ARB files under lib/l10n/ and rebuild.
    return MaterialApp.router(
      title: "Saudi EXIM Global Partners",
      routerConfig: router,
      theme: lightTheme,
      locale: appLocale,
      // Delegates and supported locales are provided by the generated l10n
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supported) {
        // Respect explicitly chosen locale from AppLocaleViewModel; otherwise fallback.
        if (supported.any((l) => l.languageCode == appLocale.languageCode)) {
          return appLocale;
        }
        return supported.first;
      },
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        return maybeClampTextScaling(
          context,
          child: child,
          minScaleFactor: kMinTextScaleFactor,
          maxScaleFactor: kMaxTextScaleFactor,
        );
      },
    );
  }
}
