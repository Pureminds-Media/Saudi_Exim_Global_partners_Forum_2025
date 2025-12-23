import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/views/menuPages/partners_page.dart';

void main() {
  testWidgets('PartnersPage toggles between sponsors and participants', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PartnersPage()));

    // Initially sponsors are shown.
    expect(find.text('وزارة الاستثمار'), findsOneWidget);
    expect(find.text('شركة الاتصالات السعودية'), findsNothing);

    // Tap on participants segment.
    await tester.tap(find.text('مشاركين'));
    await tester.pumpAndSettle();

    expect(find.text('شركة الاتصالات السعودية'), findsOneWidget);
    expect(find.text('وزارة الاستثمار'), findsNothing);
  });
}
