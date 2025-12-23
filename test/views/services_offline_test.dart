import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';
import 'package:saudiexim_mobile_app/router.dart';
import 'package:saudiexim_mobile_app/viewmodels/service_catalog_view_model.dart';
import 'package:saudiexim_mobile_app/viewmodels/app_locale_view_model.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';
import 'package:saudiexim_mobile_app/components/ui/no_network_placeholder.dart';
import 'package:saudiexim_mobile_app/viewmodels/cities_view_model.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/models/service_category.dart';
import 'package:saudiexim_mobile_app/models/city.dart';

// Repository that simulates offline network failures
class _OfflineErrorRepo extends ServiceRepository {
  @override
  Future<void> init({bool inMemory = false}) async {}

  Exception _err() => Exception('Network error: connection timeout');

  @override
  Future<List<Service>> fetchServices() async => throw _err();

  @override
  Future<List<ServiceCategory>> fetchCategories() async => throw _err();

  @override
  Future<List<City>> fetchCities() async => throw _err();
}

// Cities VM stub returning no data (so initialDataMissing is true)
class _EmptyCitiesVM extends CitiesViewModel {
  @override
  bool get loading => false;
  @override
  List get cities => const [];
  @override
  Future<void> load() async {}
}

void main() {
  testWidgets('ServicesPage shows offline placeholder on network failure', (tester) async {
    final router = createRouter(initialLocation: '/services/categories');
    final vm = ServiceCatalogViewModel(repository: _OfflineErrorRepo());
    addTearDown(vm.dispose);
    await vm.init();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: vm),
          ChangeNotifierProvider(create: (_) => AppLocaleViewModel()),
          // Ensure CitiesViewModel is present but empty so initialDataMissing holds
          ChangeNotifierProvider<CitiesViewModel>.value(value: _EmptyCitiesVM()),
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

    // Kick a frame
    await tester.pump(const Duration(milliseconds: 50));

    // With network failure simulated, the offline placeholder should appear
    expect(find.byType(NoNetworkPlaceholder), findsOneWidget);
  });
}
