import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/buttons/app_outlined_button.dart';

void main() {
  testWidgets('AppOutlinedButton triggers onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AppOutlinedButton(
          label: 'Tap me',
          onPressed: () => pressed = true,
        ),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('AppOutlinedButton uses specified styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppOutlinedButton(label: 'Styled', onPressed: dummy),
      ),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final style = button.style!;

    expect(style.fixedSize?.resolve({}), isNull);
    expect(
      style.shape?.resolve({}),
      isA<RoundedRectangleBorder>().having(
        (s) => (s).borderRadius,
        'borderRadius',
        BorderRadius.circular(12),
      ),
    );
    expect(style.padding?.resolve({}), isNull);
    expect(style.side?.resolve({}), const BorderSide(width: 1.5));
    expect(style.foregroundColor?.resolve({}), Colors.black);
  });

  testWidgets('AppOutlinedButton accepts custom size and padding', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppOutlinedButton(
          label: 'Custom',
          onPressed: dummy,
          size: const Size(100, 40),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final style = button.style!;

    expect(style.fixedSize?.resolve({}), const Size(100, 40));
    expect(
      style.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 20),
    );
  });
}

void dummy() {}
