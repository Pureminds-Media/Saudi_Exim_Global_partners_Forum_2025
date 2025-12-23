import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/buttons/app_text_button.dart';

void main() {
  testWidgets('AppTextButton triggers onPressed', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AppTextButton(label: 'Tap me', onPressed: () => pressed = true),
      ),
    );

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
