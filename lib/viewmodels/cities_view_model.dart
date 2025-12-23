import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../repositories/service_repository.dart';

class CitiesViewModel extends ChangeNotifier {
  final ServiceRepository _repository;
  List<City> _cities = const [];
  bool _loading = false;
  String? _error;

  List<City> get cities => _cities;
  bool get loading => _loading;
  String? get error => _error;

  CitiesViewModel({ServiceRepository? repository})
    : _repository = repository ?? ServiceRepository();

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _cities = await _repository.fetchCities();
    } catch (error) {
      _error = error.toString();
      _cities = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
