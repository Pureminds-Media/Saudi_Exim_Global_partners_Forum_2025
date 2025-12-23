import 'package:flutter/foundation.dart';
import '../models/page_model.dart';

class Page3ViewModel extends ChangeNotifier {
  final PageModel _page = const PageModel(
    title: 'الصفحة ٣',
    message: 'محتوى الصفحة ٣',
  );

  String get title => _page.title;
  String get message => _page.message;
}
