import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/accordion/accordion_section.dart';

void main() {
  testWidgets('AccordionSection expands and collapses', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccordionSection(
            index: 1,
            title: 'Test',
            body: Text('content'),
          ),
        ),
      ),
    );

    final crossFadeFinder = find.byType(AnimatedCrossFade);
    expect(
      tester.widget<AnimatedCrossFade>(crossFadeFinder).crossFadeState,
      CrossFadeState.showFirst,
    );

    await tester.tap(find.text('1- Test'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AnimatedCrossFade>(crossFadeFinder).crossFadeState,
      CrossFadeState.showSecond,
    );

    await tester.tap(find.text('1- Test'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<AnimatedCrossFade>(crossFadeFinder).crossFadeState,
      CrossFadeState.showFirst,
    );
  });
}
