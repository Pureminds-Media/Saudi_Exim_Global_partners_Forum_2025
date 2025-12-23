import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:saudiexim_mobile_app/viewmodels/menuPages/agenda_view_model.dart';
import 'package:saudiexim_mobile_app/views/agenda_page.dart';

void main() {
  testWidgets('AgendaPage toggles between sessions, days, and speakers', (
    tester,
  ) async {
    final vm = AgendaViewModel();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: const MaterialApp(home: AgendaPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Default view shows day 1 session
    expect(
      find.text('تحولات التجارة العالمية وآفاق النمو في الاقتصاد السعودي'),
      findsOneWidget,
    );

    // Switch to day 2 and verify session updates
    await tester.tap(find.text('اليوم الثاني'));
    await tester.pumpAndSettle();
    expect(
      find.text('آفاق الابتكار والتمويل في بلدان الجنوب العالمي'),
      findsOneWidget,
    );

    // Switch to speakers tab and ensure a speaker appears
    await tester.tap(find.text('المتحدثين'));
    await tester.pumpAndSettle();
    expect(find.text('ياسر السامري'), findsOneWidget);
  });
}
