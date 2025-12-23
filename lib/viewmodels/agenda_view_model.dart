import 'package:flutter/foundation.dart';

class AgendaViewModel extends ChangeNotifier {
  // 0 = المتحدثين, 1 = الجلسات
  int _selectedIndex = 1; // ابدأ بـ "الجلسات" مثل التصميم
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int i) {
    if (_selectedIndex == i) return;
    _selectedIndex = i;
    notifyListeners();
  }
}
