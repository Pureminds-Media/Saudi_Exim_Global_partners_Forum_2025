import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final firstGroup = const [
    {'label': 'يوم', 'value': '01'},
    {'label': 'ساعة', 'value': '12'},
    {'label': 'دقيقة', 'value': '10'},
    {'label': 'ثانية', 'value': '05'},
  ];

  final secondGroup = const [
    {'label': 'الورش', 'value': '530'},
    {'label': 'الجلسات الدورية', 'value': '200'},
    {'label': 'المتحدثين', 'value': '50'},
    {'label': 'جهات المشاركة ', 'value': '25'},
    {'label': 'المعارض', 'value': '100'},
  ];
}
