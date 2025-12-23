import 'package:flutter/foundation.dart';
import '../models/page_model.dart';

class MenuViewModel extends ChangeNotifier {
  final PageModel _page = const PageModel(
    title: 'القائمة',
    message: 'محتوى القائمة',
  );

  String get title => _page.title;
  String get message => _page.message;
}
