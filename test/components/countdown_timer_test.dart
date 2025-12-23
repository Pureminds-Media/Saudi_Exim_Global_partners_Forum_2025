import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/countdown_timer.dart';

void main() {
  testWidgets('CountdownTimer builds without layout errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CountdownTimer(target: DateTime(2030, 1, 1))),
      ),
    );

    // Ensure no exceptions were thrown during build/layout
    expect(tester.takeException(), isNull);
  });
}
