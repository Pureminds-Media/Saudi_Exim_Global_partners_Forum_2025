import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/components/buttons/segment_button.dart';
import 'package:saudiexim_mobile_app/theme/app_colors.dart';

void main() {
  testWidgets('SegmentButton toggles selection', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => SegmentButton(
            label: 'One',
            isSelected: selected,
            onTap: () => setState(() => selected = !selected),
          ),
        ),
      ),
    );

    final containerFinder = find.byType(AnimatedContainer);
    final textFinder = find.byType(AnimatedDefaultTextStyle);

    var container = tester.widget<AnimatedContainer>(containerFinder);
    var decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.transparent);
    expect(decoration.border!.top.color, AppColors.grayShade);

    await tester.tap(find.text('One'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    container = tester.widget<AnimatedContainer>(containerFinder);
    decoration = container.decoration as BoxDecoration;
    expect(decoration.color, AppColors.primary);
    expect(decoration.border!.top.color, AppColors.primary);

    final style = tester.widget<AnimatedDefaultTextStyle>(textFinder).style;
    expect(style.color, AppColors.background);
  });
}
