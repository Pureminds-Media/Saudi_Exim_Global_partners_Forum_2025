import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/city.dart';
import '../models/service.dart';
import '../models/service_category.dart';
import '../repositories/service_repository.dart';

/// A single source of truth for cities, categories, and services.
class ServiceCatalogViewModel extends ChangeNotifier {
  // ───── Cities
  static const String allSaudiAr = 'كل السعودية';
  static const String allSaudiEn = 'All Saudi Arabia';
  static const String allSaudiImage = 'assets/photos/services/all_saudi.png';

  List<City> _cities = const [];
  bool _initializing = false;
  String? _error;

  bool get initializing => _initializing;
  String? get error => _error;

  List<String> get cities {
    return [
      allSaudiAr,
      ..._cities.map((c) => (c.nameAr.isNotEmpty ? c.nameAr : c.nameEn).trim()),
    ];
  }

  List<String> get cityImages {
    return [allSaudiImage, ..._cities.map((c) => (c.photoUrl ?? '').trim())];
  }

  List<City> get availableCities => _cities;

  int _selectedCityIndex = 0;
  int get selectedCityIndex => _selectedCityIndex;
  String get selectedCity {
    if (_selectedCityIndex <= 0 || _cities.isEmpty) {
      return allSaudiAr;
    }
    final idx = _selectedCityIndex - 1;
    if (idx < 0 || idx >= _cities.length) {
      return allSaudiAr;
    }
    final city = _cities[idx];
    final label = city.nameAr.isNotEmpty ? city.nameAr : city.nameEn;
    return label.isNotEmpty ? label : allSaudiAr;
  }

  City? get selectedCityModel {
    if (_selectedCityIndex <= 0) return null;
    final idx = _selectedCityIndex - 1;
    if (idx < 0 || idx >= _cities.length) return null;
    return _cities[idx];
  }

  void selectCity(int index) {
    if (_cities.isEmpty) {
      if (_selectedCityIndex != 0) {
        _selectedCityIndex = 0;
        notifyListeners();
      }
      return;
    }
    var next = index;
    if (next < 0 || next > _cities.length) {
      next = 0;
    }
    if (_selectedCityIndex == next) return;
    _selectedCityIndex = next;
    notifyListeners();
  }

  int? indexForCityId(int id) {
    final idx = _cities.indexWhere((c) => c.id == id);
    if (idx == -1) return null;
    return idx + 1;
  }

  int? indexForCityName(String? name) {
    final value = (name ?? '').trim();
    if (value.isEmpty) return null;
    if (_isAllSaudiLabel(value)) return 0;
    final idx = _cities.indexWhere(
      (c) => c.nameAr == value || c.nameEn == value,
    );
    if (idx == -1) return null;
    return idx + 1;
  }

  bool _isAllSaudiLabel(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == allSaudiAr.toLowerCase() ||
        normalized == allSaudiEn.toLowerCase() ||
        normalized == 'saudi arabia';
  }

  // ───── Food cuisine filter
  static const List<String> cuisines = ['آسيوي', 'أوروبي', 'محلي'];
  String _selectedCuisine = cuisines.first;
  String get selectedCuisine => _selectedCuisine;

  void selectCuisine(String cuisine) {
    _selectedCuisine = cuisine;
    notifyListeners();
  }

  final ServiceRepository _repository;
  List<ServiceCategory> _allCategories = [];
  List<Service> _services = [];

  ServiceCatalogViewModel({ServiceRepository? repository})
    : _repository = repository ?? ServiceRepository();

  Future<void> init({bool inMemory = false}) async {
    if (_initializing) return;
    _initializing = true;
    _error = null;
    notifyListeners();
    await _repository.init(inMemory: inMemory);
    try {
      final categories = await _repository.fetchCategories();
      final services = await _repository.fetchServices();
      final cities = await _repository.fetchCities();
      _allCategories = categories;
      _services = services;
      _cities = cities;
      if (_selectedCityIndex > _cities.length) {
        _selectedCityIndex = 0;
      }
    } catch (error) {
      _error = error.toString();
      _allCategories = const [];
      _services = const [];
      _cities = const [];
      _selectedCityIndex = 0;
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  List<ServiceCategory> get categories {
    if (_selectedCityIndex == 0) return _allCategories;
    final city = selectedCity;
    return _allCategories
        .where((c) => c.cities.isEmpty || c.cities.contains(city))
        .toList();
  }

  ServiceCategory? categoryById(String id) {
    try {
      return _allCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Services filtered for a given category ID and current city selection.
  List<Service> servicesForCategory(String categoryId) {
    final cat = categoryById(categoryId);
    if (cat == null) return const [];

    var results = _services.where((s) => s.categoryId == categoryId).toList();

    if (categoryId == 'food') {
      results = results.where((s) => s.foodType == _selectedCuisine).toList();
    }

    if (cat.hasLocationFilter && _selectedCityIndex != 0) {
      final city = selectedCity;
      results = results
          .where((s) => s.city == city || s.city == 'كل السعودية')
          .toList();
    }

    // Ensure globally-available services are included regardless of city label
    if (cat.hasLocationFilter && _selectedCityIndex != 0) {
      final global = _services
          .where(
            (s) =>
                s.categoryId == categoryId &&
                (s.city.isEmpty || s.city == 'كل السعودية'),
          )
          .toList();
      if (global.isNotEmpty) {
        final seen = results.map((e) => e.id).toSet();
        for (final s in global) {
          if (!seen.contains(s.id)) results.add(s);
        }
      }
    }

    // If no local results for this category, attempt to fetch from the
    // per-category endpoint (async). Data appears after notifyListeners().
    if (results.isEmpty) {
      final catNum = int.tryParse(categoryId);
      if (catNum != null) {
        final shouldFilter = cat.hasLocationFilter && _selectedCityIndex != 0;
        unawaited(() async {
          final cityId = shouldFilter
              ? await _repository.cityIdForName(selectedCity)
              : null;
          final remote = await _repository.fetchServicesByCategory(
            categoryId,
            cityId: cityId,
          );
          if (remote.isEmpty) return;
          _services.removeWhere((s) => s.categoryId == categoryId);
          _services.addAll(remote);
          notifyListeners();
        }());
      }
    }

    return results;
  }

  Service? serviceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Replace all services for a given category with [remote] results
  /// (e.g., from the per-category API). This keeps details lookups in sync
  /// when the bootstrap endpoint lacks these items.
  void replaceServicesForCategory(String categoryId, List<Service> remote) {
    // Remove existing entries for this category
    _services.removeWhere((s) => s.categoryId == categoryId);
    if (remote.isNotEmpty) {
      // Insert the new set
      _services.addAll(remote);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_repository.close());
    super.dispose();
  }
}
