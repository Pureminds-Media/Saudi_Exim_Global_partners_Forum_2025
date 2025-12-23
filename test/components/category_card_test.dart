import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saudiexim_mobile_app/components/category_card.dart';

void main() {
  testWidgets('CategoryCard triggers onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryCard(
          label: 'Test',
          icon: 'https://example.com/icon.svg',
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(tapped, isTrue);
  }, skip: true);
}
