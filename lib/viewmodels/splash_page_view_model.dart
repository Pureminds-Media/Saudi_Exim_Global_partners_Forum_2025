import 'package:flutter/material.dart';

class SplashPageViewModel extends ChangeNotifier {
  bool isLoading = true;

  // Simulate loading process
  Future<void> loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    isLoading = false;
    notifyListeners();
  }
}
