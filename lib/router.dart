// lib/router.dart
// Application router and shared shell (AppBar + BottomNavigation).
//
// How it’s structured
// - A top-level [ShellRoute] wraps most pages with a [Scaffold].
// - The AppBar contains a left-aligned logo and a right-aligned language
//   chip. Positions are locked using an LTR [Row], so they don’t flip in RTL.
// - The bottom navigation appears on the four main routes only.
//
// Extending
// - To add a new main tab, first update `views/bottom_nav.dart`, then add a
//   matching [GoRoute] here and include its path in [titles] below so the
//   AppBar renders on that route.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:saudiexim_mobile_app/views/bottom_nav.dart';
import 'package:saudiexim_mobile_app/components/ui/language_chip.dart';
import 'package:saudiexim_mobile_app/views/home_page.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/viewmodels/app_locale_view_model.dart';
import 'package:saudiexim_mobile_app/views/services/services_page.dart';
import 'package:saudiexim_mobile_app/views/splash_screen.dart';
import 'package:saudiexim_mobile_app/views/menu_page.dart';

import 'package:saudiexim_mobile_app/views/menuPages/location_page.dart';

import 'package:saudiexim_mobile_app/views/menuPages/image_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/about_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/help_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/partners_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/sponsors_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/speakers_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/copies_page.dart';
import 'package:saudiexim_mobile_app/views/menuPages/edition_detail_page.dart';
import 'package:saudiexim_mobile_app/views/services/service_details_page.dart';
import 'package:saudiexim_mobile_app/views/agenda_page.dart';
import 'package:saudiexim_mobile_app/models/edition.dart';
import 'package:saudiexim_mobile_app/viewmodels/menuPages/agenda_view_model.dart'
    as page_vm;

/// Creates and configures the GoRouter used by the app.
GoRouter createRouter({String initialLocation = '/home'}) => GoRouter(
  initialLocation: initialLocation,

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (_, __) => const NoTransitionPage(child: SplashScreen()),
    ),

    // ---- Shared shell with AppBar + BottomNav ----
    ShellRoute(
      builder: (context, state, child) {
        final path = state.uri.path; // current path
        const menuPaths = {
          '/menu',
          '/image',
          '/about',
          '/help',
          '/partners',
          '/sponsors',
          '/speakers',
          '/copies',
          '/edition',
          '/saudi',
          // Treat Services routes as part of the Menu tab
          '/services',
          '/services/categories',
        };
        final int index;
        final bool isServiceDetails =
            path.startsWith('/category/') && path.contains('/service/');
        if (path == '/home') {
          index = 0;
        } else if (path == '/agenda') {
          index = 1;
        } else if (path == '/location') {
          // Venue tab
          index = 2;
        } else if (menuPaths.contains(path) || isServiceDetails) {
          index = 3;
        } else {
          index = 0;
        }
        final s = AppLocalizations.of(context)!;
        // Presence-check for top-level pages that should show the shared AppBar
        final titles = <String, String>{
          '/home': s.titleHome,
          '/services': s.titleServices,
          '/services/categories': s.titleServices,
          '/agenda': s.titleAgenda,
          '/menu': s.titleMenu,
          '/speakers': s.menuSpeakers,
          '/sponsors': s.menuSponsorship,
          '/location': s.locationTitle,
        };

        return Scaffold(
          appBar: titles[path] != null
              ? AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  // Lock positions: logo left, language chip right even in RTL
                  title: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Image.asset(
                            'assets/saudi-exim-logo-dark.png',
                            height: 40,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Builder(
                            builder: (context) {
                              final localeVm = Provider.of<AppLocaleViewModel>(
                                context,
                              );
                              final code = localeVm.locale.languageCode
                                  .toUpperCase();
                              return LanguageChip(
                                label: code,
                                onPressed: localeVm.toggle,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AppBar visual tuning
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent, // no M3 overlay tint
                  elevation: 4, // base shadow
                  scrolledUnderElevation:
                      4, // keep the same shadow when scrolled
                  shadowColor: Colors.black26,
                )
              : null,

          body: child,
          // Bottom navigation for the 4 main sections
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: index,
            currentPath: path,
          ),
          drawerDragStartBehavior: DragStartBehavior.start,
        );
      },

      // ---- Inner pages ----
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (_, __) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/services',
          name: 'services',
          pageBuilder: (_, __) => const NoTransitionPage(child: ServicesPage()),
        ),
        GoRoute(
          path: '/services/categories',
          name: 'services_categories',
          pageBuilder: (_, __) => const NoTransitionPage(child: ServicesPage()),
        ),

        // Agenda page with a local provider override (scoped)
        GoRoute(
          path: '/agenda',
          name: 'agenda',
          pageBuilder: (context, state) => NoTransitionPage(
            child: ChangeNotifierProvider<page_vm.AgendaViewModel>(
              create: (_) => page_vm.AgendaViewModel(),
              child: const AgendaPage(),
            ),
          ),
        ),

        GoRoute(
          path: '/location',
          name: 'location',
          pageBuilder: (_, __) => NoTransitionPage(child: LocationPage()),
        ),
        GoRoute(
          path: '/image',
          name: 'image',
          pageBuilder: (_, __) => const NoTransitionPage(child: ImagePage()),
        ),
        GoRoute(
          path: '/about',
          name: 'about',
          pageBuilder: (_, __) => const NoTransitionPage(child: AboutPage()),
        ),
        GoRoute(
          path: '/help',
          name: 'help',
          pageBuilder: (_, __) => const NoTransitionPage(child: HelpPage()),
        ),
        GoRoute(
          path: '/partners',
          name: 'partners',
          pageBuilder: (_, __) => const NoTransitionPage(child: PartnersPage()),
        ),
        GoRoute(
          path: '/sponsors',
          name: 'sponsors',
          pageBuilder: (_, __) => const NoTransitionPage(child: SponsorsPage()),
        ),
        GoRoute(
          path: '/speakers',
          name: 'speakers',
          pageBuilder: (_, __) => const NoTransitionPage(child: SpeakersPage()),
        ),
        GoRoute(
          path: '/copies',
          name: 'copies',
          pageBuilder: (_, __) => const NoTransitionPage(child: CopiesPage()),
        ),
        GoRoute(
          path: '/edition',
          name: 'edition',
          builder: (context, state) {
            final edition = state.extra as Edition;
            return EditionDetailPage(edition: edition);
          },
        ),
        GoRoute(
          path: '/category/:categoryId/service/:serviceId',
          name: 'service_details',
          builder: (context, state) {
            final serviceId = state.pathParameters['serviceId']!;
            return ServiceDetailsPage(serviceId: serviceId);
          },
        ),

        // Menu page with a slide-in transition
        GoRoute(
          path: '/menu',
          name: 'menu',
          pageBuilder: (_, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const MenuPage(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (context, animation, secondary, child) {
                final textDirection = Directionality.of(context);
                final beginOffset = textDirection == TextDirection.rtl
                    ? const Offset(-1, 0)
                    : const Offset(1, 0);
                final tween = Tween(
                  begin: beginOffset,
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: Container(color: Colors.white, child: child),
                );
              },
            );
          },
        ),
      ],
    ),
  ],
);
