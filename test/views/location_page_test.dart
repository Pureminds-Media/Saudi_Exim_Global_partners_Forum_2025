import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/views/menuPages/location_page.dart';

void main() {
  testWidgets('LocationPage displays header and button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocationPage()));

    expect(find.text('العودة'), findsOneWidget);
    expect(find.text('تاريخ و موعد انعقاد المنتدى'), findsOneWidget);
    expect(find.text('سجل الان'), findsOneWidget);
  }, skip: true);
}
