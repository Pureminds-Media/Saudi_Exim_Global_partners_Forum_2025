import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/models/city.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/models/service_category.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';
import 'package:saudiexim_mobile_app/utils/secure_image_cache.dart';
import 'package:saudiexim_mobile_app/viewmodels/app_locale_view_model.dart';
import 'package:saudiexim_mobile_app/viewmodels/cities_view_model.dart';
import 'package:saudiexim_mobile_app/viewmodels/service_catalog_view_model.dart';
import 'package:saudiexim_mobile_app/views/services/services_page.dart';

class _FakeSecureImageCache implements SecureImageCache {
  @override
  Future<void> clear() async {}

  @override
  Future<ImageProvider?> getCached(String url) async => null;

  @override
  Future<Uint8List?> getCachedSvgBytes(String url) async => null;

  @override
  Stream<ImageProvider> imageStream(String url, {bool refresh = true}) =>
      const Stream<ImageProvider>.empty();

  @override
  Stream<Uint8List> svgBytesStream(String url, {bool refresh = true}) =>
      const Stream<Uint8List>.empty();
}

class _ImmediateCitiesViewModel extends CitiesViewModel {
  final List<City> _fake;
  _ImmediateCitiesViewModel(this._fake) : super();

  @override
  List<City> get cities => _fake;

  @override
  bool get loading => false;

  @override
  Future<void> load() async {}
}

class _CityAwareRepository extends ServiceRepository {
  _CityAwareRepository();

  static const _deliveryCategory = ServiceCategory(
    id: '16',
    label: 'Delivery Apps',
    subtitle: 'Instant delivery from popular restaurants.',
    labelAr: 'تطبيقات التوصيل',
    labelEn: 'Delivery Apps',
    subtitleAr: 'توصيل فوري من المطاعم الشهيرة.',
    subtitleEn: 'Instant delivery from popular restaurants.',
    hasLocationFilter: true,
  );

  static const _bootstrapService = Service(
    id: '200',
    categoryId: '16',
    name: 'HungerStation',
    subtitle: 'Deliveries across the city',
    description: 'HungerStation offers a huge selection of restaurants.',
    image: 'https://example.com/hungerstation.png',
    city: 'العلا',
    website: 'https://hungerstation.example',
    nameEn: 'HungerStation',
    subtitleEn: 'Deliveries across the city',
    descriptionEn: 'HungerStation offers a huge selection of restaurants.',
    nameAr: 'هنقرستيشن',
    subtitleAr: 'خدمة توصيل شاملة',
    descriptionAr: 'هنقرستيشن يقدم خيارات توصيل متنوعة.',
  );

  static const _cities = [
    City(id: 5, nameAr: 'الرياض', nameEn: 'Riyadh'),
    City(id: 3, nameAr: 'جدة', nameEn: 'Jeddah'),
  ];

  @override
  Future<void> init({bool inMemory = false}) async {}

  @override
  Future<List<ServiceCategory>> fetchCategories() async => [_deliveryCategory];

  @override
  Future<List<Service>> fetchServices() async => const [_bootstrapService];

  @override
  Future<List<Service>> fetchServicesByCategory(String categoryId,
      {int? cityId}) async {
    // Simulate async delay to mirror network.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (cityId == 3) {
      return const [
        Service(
          id: '201',
          categoryId: '16',
          name: 'Jahez',
          subtitle: 'Fast delivery in Jeddah',
          description: 'A curated list of restaurants in Jeddah.',
          image: 'https://example.com/jahez.png',
          city: 'جدة',
          cityAr: 'جدة',
          cityEn: 'Jeddah',
          website: 'https://jahez.example',
          nameEn: 'Jahez',
          subtitleEn: 'Fast delivery in Jeddah',
          descriptionEn: 'A curated list of restaurants in Jeddah.',
          nameAr: 'جاهز',
          subtitleAr: 'توصيل سريع في جدة',
          descriptionAr: 'قائمة من المطاعم في جدة.',
        ),
      ];
    }
    return const [_bootstrapService];
  }

  @override
  Future<List<City>> fetchCities() async => _cities;

  @override
  Future<int?> cityIdForName(String name) async {
    final normalized = name.trim();
    final match = _cities.firstWhere(
      (c) => c.nameAr == normalized || c.nameEn == normalized,
      orElse: () => const City(id: -1, nameAr: '', nameEn: ''),
    );
    return match.id > 0 ? match.id : null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Selecting a city keeps services visible after remote fetch completes',
    (tester) async {
      final repo = _CityAwareRepository();
      final vm = ServiceCatalogViewModel(repository: repo);
      addTearDown(vm.dispose);
      await vm.init();

      // Pretend the user already selected Jeddah from the cities list page.
      vm.selectCity(2);

      final citiesVm = _ImmediateCitiesViewModel(_CityAwareRepository._cities);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ServiceCatalogViewModel>.value(value: vm),
            ChangeNotifierProvider(create: (_) => AppLocaleViewModel()),
            Provider<ServiceRepository>.value(value: repo),
            ChangeNotifierProvider<CitiesViewModel>.value(value: citiesVm),
            Provider<SecureImageCache>.value(value: _FakeSecureImageCache()),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ServicesPage(),
          ),
        ),
      );

      // Initial pump schedules auto-selection and kicks off async fetch.
      await tester.pump();
      // Allow async fetch + animations to complete.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.text('Jahez'), findsWidgets);
      expect(find.text('No services available'), findsNothing);
    },
  );
}
