import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:saudiexim_mobile_app/components/ui/title_back_top_bar.dart';

void main() {
  testWidgets('BackTitleBar pops when overrideBackRoute is true', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/second',
          builder: (_, __) => const Scaffold(
            body: BackTitleBar(title: 'Title', overrideBackRoute: true),
          ),
        ),
        GoRoute(
          path: '/menu',
          builder: (_, __) => const Scaffold(body: Text('Menu')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.push('/second');
    await tester.pumpAndSettle();

    // Navigated to the second route.
    expect(find.text('Title'), findsOneWidget);

    // Tapping back should pop to the home route.
    await tester.tap(find.byIcon(Icons.arrow_forward_ios));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}
