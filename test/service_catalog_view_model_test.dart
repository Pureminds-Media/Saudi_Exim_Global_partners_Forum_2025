import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/models/city.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/models/service_category.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';
import 'package:saudiexim_mobile_app/viewmodels/service_catalog_view_model.dart';

class _FakeServiceRepository extends ServiceRepository {
  final List<ServiceCategory> _cats;
  final List<Service> _services;
  final List<City> _cities;
  _FakeServiceRepository(this._cats, this._services, this._cities) : super();

  @override
  Future<void> init({bool inMemory = false}) async {}

  @override
  Future<List<ServiceCategory>> fetchCategories() async => _cats;

  @override
  Future<List<Service>> fetchServices() async => _services;

  @override
  Future<List<City>> fetchCities() async => _cities;

  @override
  Future<int?> cityIdForName(String name) async {
    final trimmed = name.trim();
    for (final city in _cities) {
      if (city.nameAr == trimmed || city.nameEn == trimmed) {
        return city.id;
      }
    }
    if (trimmed == ServiceCatalogViewModel.allSaudiAr ||
        trimmed == ServiceCatalogViewModel.allSaudiEn) {
      return null;
    }
    return null;
  }

  @override
  Future<Service?> getServiceById(String id) async {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

ServiceCategory _cat(
  String id,
  String label, {
  String subtitle = '',
  String icon = '',
  bool hasLocationFilter = true,
  List<String> cities = const [],
}) => ServiceCategory(
  id: id,
  label: label,
  subtitle: subtitle,
  icon: icon,
  hasLocationFilter: hasLocationFilter,
  cities: cities,
);

Service _svc(
  String id,
  String categoryId,
  String name, {
  String subtitle = '',
  String description = '',
  String image = '',
  bool emphasized = false,
  String city = 'كل السعودية',
  String? foodType,
  String? website,
}) => Service(
  id: id,
  categoryId: categoryId,
  name: name,
  subtitle: subtitle,
  description: description,
  image: image,
  emphasized: emphasized,
  city: city,
  foodType: foodType,
  website: website,
);

_FakeServiceRepository buildFakeRepo() {
  final cities = <City>[
    const City(id: 1, nameAr: 'الرياض', nameEn: 'Riyadh'),
    const City(id: 2, nameAr: 'مكة', nameEn: 'Makkah'),
    const City(id: 3, nameAr: 'المدينة المنورة', nameEn: 'Medina'),
    const City(id: 4, nameAr: 'جدة', nameEn: 'Jeddah'),
    const City(id: 5, nameAr: 'العلا', nameEn: 'AlUla'),
  ];
  // Cities in VM result: ['كل السعودية', ...]
  final cats = <ServiceCategory>[
    _cat('transport', 'السيارات والتنقل', cities: ['الرياض']),
    _cat('health', 'المستشفيات والخدمات الصحية', cities: ['الرياض']),
    _cat('food', 'المأكولات والمشروبات', cities: ['الرياض', 'مكة']),
    _cat(
      'stay',
      'خدمات فندقية وسكنية',
      hasLocationFilter: false,
      cities: ['مكة'],
    ),
    _cat(
      'mosques',
      'المساجد',
      cities: ['الرياض', 'مكة', 'المدينة المنورة', 'جدة', 'العلا'],
    ),
    _cat(
      'hajj',
      'الحج والعمرة',
      hasLocationFilter: false,
      cities: ['مكة', 'المدينة المنورة'],
    ),
    _cat('events', 'الفعاليات والمعارض والترفيه', cities: ['الرياض']),
  ];

  final services = <Service>[
    _svc(
      'careem',
      'transport',
      'كريم',
      subtitle: 'تنقل موثوق',
      description: 'خدمة تنقل',
      city: 'كل السعودية',
      website: 'https://example.com',
    ),
    _svc(
      'kfh_city',
      'health',
      'مدينة الملك فهد الطبية',
      subtitle: 'رعاية متقدمة',
      description: 'وصف',
      city: 'الرياض',
    ),
    _svc(
      'food_asian',
      'food',
      'مطعم آسيوي',
      foodType: ServiceCatalogViewModel.cuisines[0],
      description: 'وصف',
    ),
    _svc(
      'food_euro',
      'food',
      'مطعم أوروبي',
      foodType: ServiceCatalogViewModel.cuisines[1],
      description: 'وصف',
    ),
    _svc(
      'food_local',
      'food',
      'مطعم محلي',
      foodType: ServiceCatalogViewModel.cuisines[2],
      description: 'وصف',
    ),
  ];

  return _FakeServiceRepository(cats, services, cities);
}

void main() {
  test('selectCity updates selectedCityIndex', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    await vm.init();
    expect(vm.selectedCityIndex, 0);
    vm.selectCity(3);
    expect(vm.selectedCityIndex, 3);
  });

  test('categories are filtered by selected city', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    await vm.init();
    vm.selectCity(2); // مكة
    final selected = vm.selectedCity;
    expect(vm.categories, isNotEmpty);
    expect(
      vm.categories.every(
        (c) => c.cities.isEmpty || c.cities.contains(selected),
      ),
      isTrue,
    );
  });

  test(
    'servicesForCategory respects hasLocationFilter and city selection',
    () async {
      final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
      addTearDown(vm.dispose);
      await vm.init();
      final initial = vm.servicesForCategory('health');
      expect(initial.isNotEmpty, isTrue);

      vm.selectCity(2); // مكة
      final filtered = vm.servicesForCategory('health');
      expect(filtered, isEmpty);

      final stayBefore = vm.servicesForCategory('stay');
      vm.selectCity(1); // الرياض
      final stayAfter = vm.servicesForCategory('stay');
      expect(stayBefore.length, stayAfter.length);
    },
  );

  test('servicesForCategory filters food by selected cuisine', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    await vm.init();

    var services = vm.servicesForCategory('food');
    // default cuisine is cuisines.first
    expect(
      services.every(
        (s) => s.foodType == ServiceCatalogViewModel.cuisines.first,
      ),
      isTrue,
    );

    vm.selectCuisine(ServiceCatalogViewModel.cuisines[1]);
    services = vm.servicesForCategory('food');
    expect(
      services.every((s) => s.foodType == ServiceCatalogViewModel.cuisines[1]),
      isTrue,
    );
  });

  test('service exposes optional links fields', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    await vm.init();
    final service = vm.servicesForCategory('transport').first;
    expect(service.website, isA<String?>());
    expect(service.androidDownloadUrl, isA<String?>());
    expect(service.iosDownloadUrl, isA<String?>());
    expect(service.appDownloadUrl, isA<String?>());
    expect(service.mapLatLng, isA<String?>());
    expect(service.mapLink, isA<String?>());
  });

  test('categoryById returns null for unknown id', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    await vm.init();
    final cat = vm.categoryById('invalid');
    expect(cat, isNull);
    expect(vm.servicesForCategory('invalid'), isEmpty);
  });

  test('serviceById returns null for unknown id', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    await vm.init();
    final service = vm.serviceById('invalid');
    expect(service, isNull);
  });

  test('selectCity notifies listeners', () async {
    final vm = ServiceCatalogViewModel(repository: buildFakeRepo());
    addTearDown(vm.dispose);
    final controller = StreamController<void>();
    vm.addListener(() => controller.add(null));
    final future = expectLater(
      controller.stream,
      emitsInOrder([null, emitsDone]),
    );

    vm.selectCity(1);
    await controller.close();

    await future;
  });
}
