import 'package:dio/dio.dart';

import '../models/service.dart';
import '../models/service_category.dart';
import '../models/city.dart' as model;

/// Repository fetching services data from remote API (no local DB).
class ServiceRepository {
  static const String _baseUrl =
      'https://segpr.saudiexim.gov.sa/backend/public/api/services-data/all';
  static const String _categoryBaseUrl =
      'https://segpr.saudiexim.gov.sa/backend/public/api/services';

  final Dio _dio;

  // In-memory caches for the latest fetch.
  List<ServiceCategory>? _cachedCategories;
  List<Service>? _cachedServices;
  List<_City> _cities = const [];
  // categoryId -> (cityId|null -> services)
  final Map<String, Map<int?, List<Service>>> _categoryCityCache = {};

  ServiceRepository({Dio? dio}) : _dio = dio ?? Dio();

  // Cleans incoming text values from the API. We treat "N/A" (any case)
  // and empty strings as missing values.
  static String _cleanText(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    final lower = v.toLowerCase();
    if (lower == 'n/a') return '';
    return v;
  }

  /// No-op initializer kept for API compatibility with ViewModel.
  Future<void> init({bool inMemory = false}) async {}

  Future<void> _ensureFetched() async {
    if (_cachedCategories != null && _cachedServices != null) return;
    final response = await _dio.get(
      _baseUrl,
      options: Options(responseType: ResponseType.json),
    );
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final parsed = _parseResponse(response.data as Map<String, dynamic>);
      _cachedCategories = parsed.$1;
      _cachedServices = parsed.$2;
      // Capture cities for id/name mapping
      _cities = _extractCities(response.data as Map<String, dynamic>);
    } else {
      // Fall back to empty lists on errors.
      _cachedCategories = const [];
      _cachedServices = const [];
      _cities = const [];
    }
  }

  /// Fetches categories from the API (cached in memory).
  Future<List<ServiceCategory>> fetchCategories() async {
    await _ensureFetched();
    return _cachedCategories ?? const [];
  }

  /// Fetches services from the API (cached in memory).
  Future<List<Service>> fetchServices() async {
    await _ensureFetched();
    return _cachedServices ?? const [];
  }

  Future<Service?> getServiceById(String id) async {
    await _ensureFetched();
    try {
      return _cachedServices!.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Release any in-memory caches.
  Future<void> close() async {
    _cachedCategories = null;
    _cachedServices = null;
    _cities = const [];
    _categoryCityCache.clear();
  }

  /// Parses API payload into app models. Exposed for tests.
  /// Returns (categories, services).
  (List<ServiceCategory>, List<Service>) _parseResponse(
    Map<String, dynamic> json,
  ) {
    final cities = _extractCities(json);
    final cityById = {for (final c in cities) c.id: c};

    final rawCategories = (json['service_categories'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    final categories = rawCategories.map((cat) {
      final id = (cat['id'] as num?)?.toInt() ?? 0;
      final nameAr = (cat['name_ar'] as String?)?.trim() ?? '';
      final nameEn = (cat['name_en'] as String?)?.trim() ?? '';
      final desAr = _cleanText(cat['des_ar'] as String?);
      final desEn = _cleanText(cat['des_en'] as String?);
      final iconUrl = (cat['photo_url'] as String?)?.trim() ?? '';
      return ServiceCategory(
        id: id.toString(),
        label: nameAr.isNotEmpty ? nameAr : nameEn,
        subtitle: desAr.isNotEmpty ? desAr : desEn,
        labelAr: nameAr.isNotEmpty ? nameAr : null,
        labelEn: nameEn.isNotEmpty ? nameEn : null,
        subtitleAr: desAr.isNotEmpty ? desAr : null,
        subtitleEn: desEn.isNotEmpty ? desEn : null,
        icon: '',
        iconUrl: iconUrl.isNotEmpty ? iconUrl : null,
        hasLocationFilter: _hasLocationFilter(nameEn, nameAr),
        // Unknown at category level; leaving empty shows everywhere.
        cities: const [],
      );
    }).toList();

    // Services: API only returns items for `first_category` in this endpoint.
    final items = (json['first_category_items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    const allSaudiAr = 'كل السعودية';
    final services = items.map((item) {
      final id = (item['id'] as num?)?.toInt() ?? 0;
      final categoryId =
          (item['service_category_id'] as num?)?.toInt() ??
          (item['service_category'] is Map
              ? (item['service_category']['id'] as num?)?.toInt() ?? 0
              : 0);
      final nameAr = (item['name_ar'] as String?)?.trim() ?? '';
      final nameEn = (item['name_en'] as String?)?.trim() ?? '';
      final shortAr = _cleanText(item['short_des_ar'] as String?);
      final shortEn = _cleanText(item['short_des_en'] as String?);
      final desAr = _cleanText(item['des_ar'] as String?);
      final desEn = _cleanText(item['des_en'] as String?);
      final website = _cleanText(item['website'] as String?);
      final locationLink = _cleanText(item['location_link'] as String?);

      // Map city by taking the first associated city name (Arabic preferred).
      final citiesArr = (item['cities'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      String cityName = '';
      String cityNameAr = '';
      String cityNameEn = '';
      if (citiesArr.isNotEmpty) {
        final firstCityId = (citiesArr.first['id'] as num?)?.toInt();
        if (firstCityId != null && cityById.containsKey(firstCityId)) {
          cityNameAr = cityById[firstCityId]!.nameAr;
          cityNameEn = cityById[firstCityId]!.nameEn;
          cityName = cityNameAr.isNotEmpty ? cityNameAr : cityNameEn;
        }
      }

      if (cityName.isEmpty) {
        cityNameAr = allSaudiAr;
        const allSaudiEn = 'All Saudi Arabia';
        cityNameEn = allSaudiEn;
        cityName = cityNameAr;
      }

      final thumb = (item['thumbnail_url'] as String?)?.trim();
      final photo = (item['photo_url'] as String?)?.trim();
      return Service(
        id: id.toString(),
        categoryId: categoryId.toString(),
        name: nameAr.isNotEmpty ? nameAr : nameEn,
        subtitle: shortAr.isNotEmpty ? shortAr : shortEn,
        description: desAr.isNotEmpty ? desAr : desEn,
        image: (thumb?.isNotEmpty ?? false) ? thumb! : (photo ?? ''),
        photoUrl: (photo?.isNotEmpty ?? false) ? photo : null,
        emphasized: false,
        city: cityName,
        cityAr: cityNameAr.isNotEmpty ? cityNameAr : null,
        cityEn: cityNameEn.isNotEmpty ? cityNameEn : null,
        foodType: null,
        website: website.isNotEmpty ? website : null,
        androidDownloadUrl: null,
        iosDownloadUrl: null,
        mapLatLng: null,
        mapLink: locationLink.isNotEmpty ? locationLink : null,
        nameAr: nameAr.isNotEmpty ? nameAr : null,
        nameEn: nameEn.isNotEmpty ? nameEn : null,
        subtitleAr: shortAr.isNotEmpty ? shortAr : null,
        subtitleEn: shortEn.isNotEmpty ? shortEn : null,
        descriptionAr: desAr.isNotEmpty ? desAr : null,
        descriptionEn: desEn.isNotEmpty ? desEn : null,
      );
    }).toList();

    return (categories, services);
  }

  List<_City> _extractCities(Map<String, dynamic> json) {
    return (json['cities'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (c) => _City(
            id: (c['id'] as num?)?.toInt() ?? 0,
            nameAr: (c['name_ar'] as String?)?.trim() ?? '',
            nameEn: (c['name_en'] as String?)?.trim() ?? '',
            photoUrl: (c['photo_url'] as String?)?.trim(),
            desAr: _cleanText(c['des_ar'] as String?),
            desEn: _cleanText(c['des_en'] as String?),
          ),
        )
        .toList();
  }

  /// Returns the backend city id for the given display name (ar/en).
  Future<int?> cityIdForName(String name) async {
    if (_cities.isEmpty) {
      await _ensureFetched();
    }

    final n = name.trim();
    if (n.isEmpty) return null;

    final found = _cities.firstWhere(
      (c) => c.nameAr == n || c.nameEn == n,
      orElse: () => const _City(id: -1, nameAr: '', nameEn: ''),
    );
    return found.id > 0 ? found.id : null;
  }

  /// Public API: list cities with backend photos (from bootstrap response).
  Future<List<model.City>> fetchCities() async {
    await _ensureFetched();
    return _cities
        .map(
          (c) => model.City(
            id: c.id,
            nameAr: c.nameAr,
            nameEn: c.nameEn,
            photoUrl: c.photoUrl,
            desAr: (c.desAr ?? '').isNotEmpty ? c.desAr : null,
            desEn: (c.desEn ?? '').isNotEmpty ? c.desEn : null,
          ),
        )
        .toList();
  }

  /// Fetch services for a specific category, optionally filtered by city id.
  Future<List<Service>> fetchServicesByCategory(
    String categoryId, {
    int? cityId,
  }) async {
    await _ensureFetched();

    // Serve from cache first
    final cityKey = cityId; // null is allowed
    final byCity = _categoryCityCache[categoryId];
    if (byCity != null && byCity.containsKey(cityKey)) {
      return byCity[cityKey]!;
    }

    final idNum = int.tryParse(categoryId);
    if (idNum == null) {
      // Category id isn't numeric (likely test data) → empty list.
      return const [];
    }

    final url = '$_categoryBaseUrl/$idNum';
    final response = await _dio.get(
      url,
      queryParameters: cityId != null ? {'city_id': cityId} : null,
      options: Options(responseType: ResponseType.json),
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final cityById = {for (final c in _cities) c.id: c};
      final items = (data['service_items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      final services = items.map((item) {
        final id = (item['id'] as num?)?.toInt() ?? 0;
        final catId = (item['service_category'] is Map)
            ? ((item['service_category']['id'] as num?)?.toInt() ?? idNum)
            : idNum;
        final nameAr = (item['name_ar'] as String?)?.trim() ?? '';
        final nameEn = (item['name_en'] as String?)?.trim() ?? '';
        final shortAr = _cleanText(item['short_des_ar'] as String?);
        final shortEn = _cleanText(item['short_des_en'] as String?);
        final desAr = _cleanText(item['des_ar'] as String?);
        final desEn = _cleanText(item['des_en'] as String?);
        final website = _cleanText(item['website'] as String?);
        final locationLink = _cleanText(item['location_link'] as String?);

        final citiesArr = (item['cities'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        String cityName = '';
        String cityNameAr = '';
        String cityNameEn = '';
        if (cityId != null) {
          final selected = cityById[cityId];
          if (selected != null) {
            cityNameAr = selected.nameAr;
            cityNameEn = selected.nameEn;
            cityName = cityNameAr.isNotEmpty ? cityNameAr : cityNameEn;
          }
        }
        if (cityName.isEmpty && citiesArr.isNotEmpty) {
          final firstCityId = (citiesArr.first['id'] as num?)?.toInt();
          if (firstCityId != null && cityById.containsKey(firstCityId)) {
            final c = cityById[firstCityId]!;
            cityNameAr = c.nameAr;
            cityNameEn = c.nameEn;
            cityName = cityNameAr.isNotEmpty ? cityNameAr : cityNameEn;
          }
        }
        if (cityName.isEmpty) cityName = 'كل السعودية';

        final thumb = (item['thumbnail_url'] as String?)?.trim();
        final photo = (item['photo_url'] as String?)?.trim();
        return Service(
          id: id.toString(),
          categoryId: catId.toString(),
          name: nameAr.isNotEmpty ? nameAr : nameEn,
          subtitle: shortAr.isNotEmpty ? shortAr : shortEn,
          description: desAr.isNotEmpty ? desAr : desEn,
          image: (thumb?.isNotEmpty ?? false) ? thumb! : (photo ?? ''),
          photoUrl: (photo?.isNotEmpty ?? false) ? photo : null,
          emphasized: false,
          city: cityName,
          cityAr: cityNameAr.isNotEmpty ? cityNameAr : null,
          cityEn: cityNameEn.isNotEmpty ? cityNameEn : null,
          foodType: null,
          website: website.isNotEmpty ? website : null,
          androidDownloadUrl: null,
          iosDownloadUrl: null,
          mapLatLng: null,
          mapLink: locationLink.isNotEmpty ? locationLink : null,
          nameAr: nameAr.isNotEmpty ? nameAr : null,
          nameEn: nameEn.isNotEmpty ? nameEn : null,
          subtitleAr: shortAr.isNotEmpty ? shortAr : null,
          subtitleEn: shortEn.isNotEmpty ? shortEn : null,
          descriptionAr: desAr.isNotEmpty ? desAr : null,
          descriptionEn: desEn.isNotEmpty ? desEn : null,
        );
      }).toList();

      _categoryCityCache.putIfAbsent(categoryId, () => {});
      _categoryCityCache[categoryId]![cityKey] = services;
      return services;
    }

    return const [];
  }
}

class _City {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? photoUrl;
  final String? desAr;
  final String? desEn;
  const _City({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.photoUrl,
    this.desAr,
    this.desEn,
  });
}

bool _hasLocationFilter(String nameEn, String nameAr) {
  final n = (nameEn.isNotEmpty ? nameEn : nameAr).toLowerCase();
  if (n.contains('hospitality') ||
      n.contains('residential') ||
      n.contains('hajj') ||
      n.contains('umrah')) {
    return false;
  }
  return true;
}
