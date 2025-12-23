import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/buttons/primary_button.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

void main() {
  testWidgets('PrimaryButton triggers onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PrimaryButton(label: 'Tap me', onPressed: () => pressed = true),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('PrimaryButton uses specified styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PrimaryButton(label: 'Styled', onPressed: dummy),
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    final style = button.style!;
    final context = tester.element(find.byType(ElevatedButton));

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
    expect(style.backgroundColor?.resolve({}), AppColors.primary);
    expect(style.foregroundColor?.resolve({}), AppColors.background);
    expect(
      style.textStyle?.resolve({}),
      Theme.of(context).textTheme.labelLarge,
    );
  });
}

void dummy() {}
