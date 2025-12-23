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

class _BootstrapServiceRepository extends ServiceRepository {
  _BootstrapServiceRepository();

  final List<City> _cities = const [
    City(id: 5, nameAr: 'الرياض', nameEn: 'Riyadh'),
    City(id: 3, nameAr: 'جدة', nameEn: 'Jeddah'),
  ];

  List<City> get citiesSnapshot => _cities;

  @override
  Future<void> init({bool inMemory = false}) async {}

  @override
  Future<List<ServiceCategory>> fetchCategories() async {
    return [
      const ServiceCategory(
        id: '16',
        label: 'Delivery Apps',
        subtitle: 'Instant delivery from popular restaurants.',
        labelAr: 'تطبيقات التوصيل',
        labelEn: 'Delivery Apps',
        subtitleAr: 'توصيل فوري من المطاعم الشهيرة.',
        subtitleEn: 'Instant delivery from popular restaurants.',
        iconUrl: 'https://example.com/delivery.svg',
        hasLocationFilter: false,
      ),
      const ServiceCategory(
        id: '7',
        label: 'Entertainment',
        subtitle: 'Events and attractions',
        labelAr: 'ترفيه',
        labelEn: 'Entertainment',
        subtitleAr: 'فعاليات ومعالم',
        subtitleEn: 'Events and attractions',
        iconUrl: 'https://example.com/entertainment.svg',
        hasLocationFilter: false,
      ),
    ];
  }

  @override
  Future<List<Service>> fetchServices() async {
    return const [
      Service(
        id: '200',
        categoryId: '16',
        name: 'HungerStation',
        subtitle: 'Deliveries across the city',
        description: 'HungerStation offers a huge selection of restaurants.',
        image: 'https://example.com/hungerstation.png',
        city: 'كل السعودية',
        website: 'https://hungerstation.example',
        nameEn: 'HungerStation',
        subtitleEn: 'Deliveries across the city',
        descriptionEn: 'HungerStation offers a huge selection of restaurants.',
        nameAr: 'هنقرستيشن',
        subtitleAr: 'خدمة توصيل شاملة',
        descriptionAr: 'هنقرستيشن يقدم خيارات توصيل متنوعة.',
      ),
    ];
  }

  @override
  Future<List<Service>> fetchServicesByCategory(
    String categoryId, {
    int? cityId,
  }) async {
    if (categoryId == '16') {
      return fetchServices();
    }
    return const [];
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ServicesPage automatically selects first category and renders its services',
    (tester) async {
      final repo = _BootstrapServiceRepository();
      final vm = ServiceCatalogViewModel(repository: repo);
      addTearDown(vm.dispose);
      await vm.init();

      final citiesVm = _ImmediateCitiesViewModel(repo.citiesSnapshot);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ServiceCatalogViewModel>.value(value: vm),
            ChangeNotifierProvider(create: (_) => AppLocaleViewModel()),
            Provider<ServiceRepository>.value(value: repo),
            ChangeNotifierProvider<CitiesViewModel>.value(value: citiesVm),
            Provider<SecureImageCache>.value(value: _FakeSecureImageCache()),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [
              ...AppLocalizations.supportedLocales,
            ],
            home: const ServicesPage(),
          ),
        ),
      );

      // Allow post-frame callbacks and animations to settle.
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      final chipFinder = find.widgetWithText(ChoiceChip, 'Delivery Apps');
      expect(chipFinder, findsOneWidget);
      final chip = tester.widget<ChoiceChip>(chipFinder);
      expect(chip.selected, isTrue, reason: 'First category should auto-select');

      expect(
        find.text('HungerStation'),
        findsWidgets,
        reason: 'Prefetched services should render without extra taps',
      );
    },
  );
}
