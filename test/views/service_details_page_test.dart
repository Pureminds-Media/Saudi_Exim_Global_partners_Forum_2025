import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:saudiexim_mobile_app/viewmodels/service_catalog_view_model.dart';
import 'package:saudiexim_mobile_app/views/services/service_details_page.dart';
import 'package:saudiexim_mobile_app/models/service.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';
import 'package:saudiexim_mobile_app/models/service_category.dart';

class _FakeServiceRepository extends ServiceRepository {
  @override
  Future<void> init({bool inMemory = false}) async {}

  @override
  Future<List<ServiceCategory>> fetchCategories() async => [
    ServiceCategory(
      id: 'transport',
      label: 'السيارات والتنقل',
      subtitle: '',
      icon: '',
      cities: const ['كل السعودية'],
    ),
  ];

  @override
  Future<List<Service>> fetchServices() async => [
    Service(
      id: 'careem',
      categoryId: 'transport',
      name: 'كريم',
      subtitle: 'تنقل موثوق',
      description: 'خدمة تنقل',
      image: '',
      emphasized: false,
      city: 'كل السعودية',
      website: 'https://example.com',
    ),
  ];
}

void main() {
  testWidgets('ServiceDetailsPage shows service info and optional sections', (
    tester,
  ) async {
    final vm = ServiceCatalogViewModel(repository: _FakeServiceRepository());
    addTearDown(vm.dispose);
    await vm.init();
    final service = vm.serviceById('careem')!;

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ServiceCatalogViewModel>.value(
          value: vm,
          child: MaterialApp(home: ServiceDetailsPage(serviceId: service.id)),
        ),
      );

      expect(find.text(service.name), findsOneWidget);
      expect(find.text(service.city), findsOneWidget);
      if (service.website != null) {
        // Just assert the link text exists
        expect(find.text(service.website!), findsOneWidget);
      }
      if (service.androidDownloadUrl != null ||
          service.iosDownloadUrl != null) {
        expect(find.textContaining('تحميل'), findsOneWidget);
      }
      if (service.mapLatLng != null || service.mapLink != null) {
        expect(find.textContaining('الموقع'), findsOneWidget);
      }
    });
  });

  testWidgets('ServiceDetailsPage shows not found for invalid id', (
    tester,
  ) async {
    final vm = ServiceCatalogViewModel(repository: _FakeServiceRepository());
    addTearDown(vm.dispose);
    await vm.init();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: const MaterialApp(
          home: ServiceDetailsPage(serviceId: 'invalid'),
        ),
      ),
    );

    expect(find.text('Not found'), findsOneWidget);
  });
}
