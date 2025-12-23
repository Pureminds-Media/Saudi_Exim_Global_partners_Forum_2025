import 'package:flutter/foundation.dart';

class CountdownItem {
  final String value;
  final String label;
  const CountdownItem({required this.value, required this.label});
}

class StatItem {
  final String value;
  final String label;
  const StatItem({required this.value, required this.label});
}

class ImageViewModel extends ChangeNotifier {
  final String introText =
      'منتدى التصدير السعودي يجمع القادة والخبراء لبحث آفاق التجارة الدولية وتعزيز مكانة المملكة.';
  final String aboutForum =
      'يُقام المنتدى سنوياً لدعم المصدرين وتبادل الخبرات وعقد الشراكات مع أسواق جديدة.';
  final List<CountdownItem> countdown = const [
    CountdownItem(value: '30', label: 'يوم'),
    CountdownItem(value: '12', label: 'ساعة'),
    CountdownItem(value: '45', label: 'دقائق'),
    CountdownItem(value: '00', label: 'ثواني'),
  ];
  final List<StatItem> stats = const [
    StatItem(value: '500', label: 'زائر'),
    StatItem(value: '10', label: 'متحدث'),
    StatItem(value: '150', label: 'دولة'),
    StatItem(value: '50', label: 'شريك'),
    StatItem(value: '25', label: 'ورشة'),
    StatItem(value: '11', label: 'جلسة'),
  ];
}
