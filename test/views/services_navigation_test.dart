import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:saudiexim_mobile_app/router.dart';
import 'package:saudiexim_mobile_app/components/service_card.dart';
import 'package:saudiexim_mobile_app/views/services/category_services_page.dart';
import 'package:saudiexim_mobile_app/viewmodels/service_catalog_view_model.dart';
import 'package:saudiexim_mobile_app/viewmodels/app_locale_view_model.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';
import 'package:saudiexim_mobile_app/models/service_category.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/gen/l10n/app_localizations.dart';

class _FakeServiceRepository extends ServiceRepository {
  @override
  Future<void> init({bool inMemory = false}) async {}

  @override
  Future<List<ServiceCategory>> fetchCategories() async => [
    ServiceCategory(
      id: 'transport',
      label: 'النقل والمواصلات',
      subtitle: 'نبذة',
      icon: '',
      cities: const ['كل السعودية'],
    ),
  ];

  @override
  Future<List<Service>> fetchServices() async => [
    const Service(
      id: 'careem',
      categoryId: 'transport',
      name: 'كريم',
      subtitle: 'خدمة تنقل',
      description: 'وصف قصير',
      image: '',
      emphasized: false,
      city: 'كل السعودية',
    ),
  ];
}

void main() {
  testWidgets('navigates from services to category to details', (tester) async {
    await mockNetworkImagesFor(() async {
      final router = createRouter(initialLocation: '/services/categories');
      final vm = ServiceCatalogViewModel(repository: _FakeServiceRepository());
      addTearDown(vm.dispose);
      await vm.init();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: vm),
            ChangeNotifierProvider(create: (_) => AppLocaleViewModel()),
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

      // Verify ServicesPage shows the category chip text.
      expect(find.text('النقل والمواصلات'), findsWidgets);

      // Tap the category to navigate to CategoryServicesPage.
      await tester.tap(find.text('النقل والمواصلات').first);
      await tester.pumpAndSettle();

      // Verify CategoryServicesPage header and service list.
      expect(
        find.descendant(
          of: find.byType(CategoryServicesPage),
          matching: find.text('النقل والمواصلات'),
        ),
        findsWidgets,
      );
      expect(find.byType(ServiceCard), findsWidgets);

      // Tap details within the service card to open ServiceDetailsPage.
      final card = find.ancestor(
        of: find.text('كريم'),
        matching: find.byType(ServiceCard),
      );
      final detailsButton = find.descendant(
        of: card,
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(detailsButton);
      await tester.tap(detailsButton);
      await tester.pumpAndSettle();

      // Verify service details are displayed.
      expect(find.text('كريم'), findsOneWidget);
    });
  });
}
