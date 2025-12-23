import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saudiexim_mobile_app/components/cached_url_image.dart';
import 'package:saudiexim_mobile_app/components/service_card.dart';
import 'package:saudiexim_mobile_app/models/service.dart';

void main() {
  testWidgets('ServiceCard shows placeholder when image is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ServiceCard(
            service: const Service(
              id: 'id',
              categoryId: 'cat',
              name: 'Name',
              subtitle: 'Subtitle',
              description: 'Description',
              image: '',
              emphasized: false,
              city: '',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
  });

  testWidgets('ServiceCard uses network icon placeholder without cache', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ServiceCard(
            service: const Service(
              id: 'id',
              categoryId: 'cat',
              name: 'Name',
              subtitle: 'Subtitle',
              description: 'Description',
              image: 'https://example.com/image.png',
              emphasized: false,
              city: '',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CachedUrlImage), findsNothing);
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });
}
