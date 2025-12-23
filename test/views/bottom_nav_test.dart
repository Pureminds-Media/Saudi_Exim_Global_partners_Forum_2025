import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/views/bottom_nav.dart';

Finder _navItemAt(int index) => find
    .byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_NavItemPill',
    )
    .at(index);

int _indexForPath(String path) {
  if (path == '/home') {
    return 0;
  }
  if (path == '/services') {
    return 1;
  }
  if (path == '/agenda') {
    return 2;
  }
  if (path == '/menu' || path == '/location') {
    return 3;
  }
  return 0;
}

GoRouter _createTestRouter({
  String initialLocation = '/home',
  required Widget Function(String path) buildPage,
}) {
  final paths = <String>['/home', '/services', '/agenda', '/menu', '/location'];
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final path = state.uri.path;
          return Scaffold(
            body: child,
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: _indexForPath(path),
              currentPath: path,
            ),
          );
        },
        routes: [
          for (final path in paths)
            GoRoute(
              path: path,
              pageBuilder: (_, __) =>
                  NoTransitionPage(key: ValueKey(path), child: buildPage(path)),
            ),
        ],
      ),
    ],
  );
}

String _currentPath(GoRouter router) {
  final matches = router.routerDelegate.currentConfiguration;
  if (matches.isNotEmpty) {
    return matches.last.matchedLocation;
  }
  return router.routeInformationProvider.value.uri.path;
}

Future<void> _pumpRouter(
  WidgetTester tester,
  GoRouter router, {
  Widget Function(Widget child)? wrap,
}) async {
  Widget app = MaterialApp.router(
    routerConfig: router,
    supportedLocales: const [...AppLocalizations.supportedLocales],
    localizationsDelegates: const [...AppLocalizations.localizationsDelegates],
    locale: const Locale('en'),
  );

  if (wrap != null) {
    app = wrap(app);
  }

  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

class _StubPage extends StatelessWidget {
  const _StubPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('stub $label'));
  }
}

class _CounterStore extends ChangeNotifier {
  int value = 0;

  void increment() {
    value += 1;
    notifyListeners();
  }
}

class _CountingPage extends StatefulWidget {
  const _CountingPage();

  @override
  State<_CountingPage> createState() => _CountingPageState();
}

class _CountingPageState extends State<_CountingPage> {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<_CounterStore>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('count: ${store.value}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: store.increment,
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('Bottom nav displays custom icons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [...AppLocalizations.supportedLocales],
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
        ],
        home: Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: 0,
            currentPath: '/home',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsNWidgets(4));
  });

  testWidgets('menu tab toggles back to previous route from home', (
    tester,
  ) async {
    final router = _createTestRouter(
      buildPage: (path) => _StubPage(label: path),
    );
    addTearDown(router.dispose);

    await _pumpRouter(tester, router);
    expect(_currentPath(router), '/home');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/menu');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/home');
  });

  testWidgets('menu tab restores services when closing menu', (tester) async {
    final router = _createTestRouter(
      initialLocation: '/services',
      buildPage: (path) => _StubPage(label: path),
    );
    addTearDown(router.dispose);

    await _pumpRouter(tester, router);
    expect(_currentPath(router), '/services');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/menu');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/services');
  });

  testWidgets('menu remembers the most recent non-menu path', (tester) async {
    final router = _createTestRouter(
      initialLocation: '/services',
      buildPage: (path) => _StubPage(label: path),
    );
    addTearDown(router.dispose);

    await _pumpRouter(tester, router);
    expect(_currentPath(router), '/services');

    // Switch to agenda and ensure the router updates.
    await tester.tap(_navItemAt(2));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/agenda');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/menu');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/agenda');
  });

  testWidgets('menu falls back to home when opened from menu route', (
    tester,
  ) async {
    final router = _createTestRouter(
      initialLocation: '/menu',
      buildPage: (path) => _StubPage(label: path),
    );
    addTearDown(router.dispose);

    await _pumpRouter(tester, router);
    expect(_currentPath(router), '/menu');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/home');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/menu');
  });

  testWidgets('menu button opens menu page from venue without jumping away', (
    tester,
  ) async {
    final router = _createTestRouter(
      initialLocation: '/location',
      buildPage: (path) => _StubPage(label: path),
    );
    addTearDown(router.dispose);

    await _pumpRouter(tester, router);
    expect(_currentPath(router), '/location');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/menu');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/location');
  });

  testWidgets('returning from menu preserves stateful page content', (
    tester,
  ) async {
    late _CounterStore store;
    final router = _createTestRouter(
      buildPage: (path) =>
          path == '/home' ? const _CountingPage() : _StubPage(label: path),
    );
    addTearDown(router.dispose);

    await _pumpRouter(
      tester,
      router,
      wrap: (child) => ChangeNotifierProvider<_CounterStore>(
        create: (_) {
          store = _CounterStore();
          return store;
        },
        child: child,
      ),
    );

    expect(_currentPath(router), '/home');
    expect(find.text('count: 0'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(store.value, 1);
    expect(find.text('count: 1'), findsOneWidget);

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/menu');

    await tester.tap(_navItemAt(3));
    await tester.pumpAndSettle();
    expect(_currentPath(router), '/home');

    expect(find.text('count: 1'), findsOneWidget);
  });
}
