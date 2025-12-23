import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/buttons/secondary_button.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

void main() {
  testWidgets('SecondaryButton triggers onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SecondaryButton(label: 'Tap me', onPressed: () => pressed = true),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('SecondaryButton uses specified styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SecondaryButton(label: 'Styled', onPressed: dummy),
      ),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    final style = button.style!;
    final context = tester.element(find.byType(OutlinedButton));

    expect(style.minimumSize?.resolve({}), const Size(64, 48));
    expect(
      style.shape?.resolve({}),
      isA<RoundedRectangleBorder>().having(
        (s) => (s).borderRadius,
        'borderRadius',
        BorderRadius.circular(12),
      ),
    );
    expect(
      style.padding?.resolve({}),
      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
    expect(style.backgroundColor?.resolve({}), AppColors.background);
    expect(style.foregroundColor?.resolve({}), AppColors.primary);
    expect(
      style.textStyle?.resolve({}),
      Theme.of(context).textTheme.labelLarge,
    );
  });
}

void dummy() {}
