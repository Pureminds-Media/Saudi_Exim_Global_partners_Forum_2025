import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:saudiexim_mobile_app/views/menu_page.dart';
import 'package:saudiexim_mobile_app/views/bottom_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:saudiexim_mobile_app/router.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';

Future<SlideTransition> _pumpMenuRoute(
  WidgetTester tester,
  Locale locale,
) async {
  final GoRouter router = createRouter(initialLocation: '/menu');

  await tester.pumpWidget(
    MaterialApp.router(
      locale: locale,
      supportedLocales: const [...AppLocalizations.supportedLocales],
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
      ],
      routerConfig: router,
    ),
  );

  // Ensure the first frame completes so the SlideTransition is available.
  await tester.pump();

  final slideFinder = find.byType(SlideTransition);
  expect(slideFinder, findsOneWidget);
  return tester.widget<SlideTransition>(slideFinder);
}

void main() {
  testWidgets('MenuPage displays items in RTL', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: MenuPage()),
      ),
    );

    expect(
      Directionality.of(tester.element(find.byType(MenuPage))),
      TextDirection.rtl,
    );
    expect(find.text('أجندة المنتدى'), findsOneWidget);
    // The label can appear multiple times depending on layout.
    expect(find.text('+10 جديدة'), findsWidgets);
  });

  testWidgets('MenuPage animates content only', (WidgetTester tester) async {
    final GoRouter router = createRouter(initialLocation: '/menu');

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );

    // Animation starts at offset -1, so pump to begin and settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Ensure SlideTransition exists for page content.
    final slideFinder = find.byType(SlideTransition);
    expect(slideFinder, findsOneWidget);

    // Bottom navigation bar should not be a descendant of SlideTransition.
    final navBarFinder = find.byType(AppBottomNavBar);
    expect(navBarFinder, findsOneWidget);
    expect(
      find.descendant(of: slideFinder, matching: navBarFinder),
      findsNothing,
    );
  });

  testWidgets('Menu route slides from right in English', (
    WidgetTester tester,
  ) async {
    final slide = await _pumpMenuRoute(tester, const Locale('en'));
    expect(slide.position.value.dx, greaterThan(0));
  });

  testWidgets('Menu route slides from left in Arabic', (
    WidgetTester tester,
  ) async {
    final slide = await _pumpMenuRoute(tester, const Locale('ar'));
    expect(slide.position.value.dx, lessThan(0));
  });
}
