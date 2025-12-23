import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/views/menuPages/image_page.dart';

void main() {
  testWidgets('ImagePage displays header, button, and stats', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImagePage()));

    expect(find.text('العودة'), findsOneWidget);
    expect(find.text('الشعار اللفظي للمنتدى'), findsOneWidget);
    expect(find.text('نبذة عن المنتدى'), findsOneWidget);
    expect(find.text('سجل الان'), findsOneWidget);
    expect(find.text('الزوار'), findsOneWidget);
  });
}
