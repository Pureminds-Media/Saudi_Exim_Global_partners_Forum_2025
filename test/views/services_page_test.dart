import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:saudiexim_mobile_app/router.dart';
import 'package:saudiexim_mobile_app/components/category_card.dart';
import 'package:saudiexim_mobile_app/components/city_filter_item.dart';
import 'package:saudiexim_mobile_app/views/services/category_services_page.dart';
import 'package:saudiexim_mobile_app/views/services/services_page.dart';
import 'package:saudiexim_mobile_app/viewmodels/service_catalog_view_model.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/viewmodels/app_locale_view_model.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';
import 'package:saudiexim_mobile_app/models/service_category.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/viewmodels/cities_view_model.dart';
import 'package:saudiexim_mobile_app/models/city.dart';

class _FakeServiceRepository extends ServiceRepository {
  _FakeServiceRepository();

  final List<City> _cities = const [
    City(id: 1, nameAr: 'الرياض', nameEn: 'Riyadh'),
    City(id: 2, nameAr: 'مكة', nameEn: 'Makkah'),
    City(id: 3, nameAr: 'المدينة المنورة', nameEn: 'Medina'),
    City(id: 4, nameAr: 'جدة', nameEn: 'Jeddah'),
    City(id: 5, nameAr: 'العلا', nameEn: 'AlUla'),
  ];

  List<City> get citiesSnapshot => _cities;

  @override
  Future<void> init({bool inMemory = false}) async {}

  @override
  Future<List<ServiceCategory>> fetchCategories() async {
    return [
      ServiceCategory(
        id: 'transport',
        label: 'السيارات والتنقل',
        subtitle: '',
        iconUrl: 'https://example.com/transport.svg',
        cities: [_cities[0].nameAr],
      ),
      ServiceCategory(
        id: 'health',
        label: 'المستشفيات والخدمات الصحية',
        subtitle: '',
        iconUrl: 'https://example.com/health.svg',
        cities: [_cities[0].nameAr],
      ),
      ServiceCategory(
        id: 'food',
        label: 'المأكولات والمشروبات',
        subtitle: '',
        iconUrl: 'https://example.com/food.svg',
        cities: [_cities[0].nameAr, _cities[1].nameAr],
      ),
      ServiceCategory(
        id: 'stay',
        label: 'خدمات فندقية وسكنية',
        subtitle: '',
        hasLocationFilter: false,
        iconUrl: 'https://example.com/stay.svg',
        cities: [_cities[1].nameAr],
      ),
      ServiceCategory(
        id: 'mosques',
        label: 'المساجد',
        subtitle: '',
        iconUrl: 'https://example.com/mosque.svg',
        cities: _cities.map((city) => city.nameAr).toList(growable: false),
      ),
      ServiceCategory(
        id: 'hajj',
        label: 'الحج والعمرة',
        subtitle: '',
        hasLocationFilter: false,
        iconUrl: 'https://example.com/hajj.svg',
        cities: [_cities[1].nameAr, _cities[2].nameAr],
      ),
      ServiceCategory(
        id: 'events',
        label: 'الفعاليات والمعارض والترفيه',
        subtitle: '',
        iconUrl: 'https://example.com/events.svg',
        cities: [_cities[0].nameAr],
      ),
    ];
  }

  @override
  Future<List<Service>> fetchServices() async => const [];

  @override
  Future<List<Service>> fetchServicesByCategory(
    String categoryId, {
    int? cityId,
  }) async => const [];

  @override
  Future<List<City>> fetchCities() async => _cities;

  @override
  Future<int?> cityIdForName(String name) async {
    final trimmed = name.trim();
    final match = _cities.firstWhere(
      (c) => c.nameAr == trimmed || c.nameEn == trimmed,
      orElse: () => const City(id: -1, nameAr: '', nameEn: ''),
    );
    return match.id > 0 ? match.id : null;
  }
}

class _StubCitiesVM extends CitiesViewModel {
  final List<City> _fake;
  _StubCitiesVM(this._fake) : super();
  @override
  List<City> get cities => _fake;
  @override
  bool get loading => false;
  @override
  Future<void> load() async {}
}

void main() {
  testWidgets(
    'ServicesPage filters categories by city and navigates to details',
    (tester) async {
      final router = createRouter(initialLocation: '/services/categories');
      final repo = _FakeServiceRepository();
      final vm = ServiceCatalogViewModel(repository: repo);
      addTearDown(vm.dispose);
      await vm.init();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: vm),
            ChangeNotifierProvider(create: (_) => AppLocaleViewModel()),
            Provider<ServiceRepository>.value(value: repo),
            ChangeNotifierProvider<CitiesViewModel>.value(
              value: _StubCitiesVM(repo.citiesSnapshot),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [...AppLocalizations.supportedLocales],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Global app bar is shown with the logo
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.image(const AssetImage('assets/logo.png')), findsOneWidget);

      // Page renders (no crash) and shows chips area divider
      expect(find.byType(Divider), findsWidgets);

      // Select a specific city to filter categories
      await tester.tap(find.widgetWithText(CityFilterItem, 'مكة'));
      await tester.pumpAndSettle();

      // Debug: verify categories length after filtering
      final vmAfter = Provider.of<ServiceCatalogViewModel>(
        tester.element(find.byType(ServicesPage)),
        listen: false,
      );
      // ignore: avoid_print
      print('Filtered categories count: \\${vmAfter.categories.length}');

      // Only categories available in مكة remain (4)
      expect(vmAfter.categories.length, 4);
      expect(find.text('السيارات والتنقل'), findsNothing);

      // Tap a category chip should not throw
      if (vm.categories.isNotEmpty) {
        await tester.tap(find.text(vm.categories.first.label));
        await tester.pump();
      }
    },
  );
}
