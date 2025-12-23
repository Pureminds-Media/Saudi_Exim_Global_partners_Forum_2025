import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:saudiexim_mobile_app/repositories/service_repository.dart';

void main() {
  test(
    'ServiceRepository maps categories and services from API payload',
    () async {
      final payload = {
        'cities': [
          {'id': 1, 'name_ar': 'الرياض', 'name_en': 'Riyadh'},
          {'id': 2, 'name_ar': 'مكة', 'name_en': 'Makkah'},
        ],
        'service_categories': [
          {
            'id': 1,
            'name_ar': 'السيارات والتنقل',
            'name_en': 'Automotive and Mobility',
            'des_ar': 'x',
            'des_en': 'x',
          },
        ],
        'first_category': {
          'id': 1,
          'name_ar': 'السيارات والتنقل',
          'name_en': 'Automotive and Mobility',
        },
        'first_category_items': [
          {
            'id': 10,
            'service_category_id': 1,
            'name_ar': 'هواي لتأجير السيارات',
            'name_en': 'Huai Car Rental',
            'short_des_ar': 'اختصار',
            'short_des_en': 'Short',
            'des_ar': 'وصف',
            'des_en': 'Desc',
            'website': 'https://example.com',
            'cities': [
              {'id': 1, 'name_ar': 'الرياض', 'name_en': 'Riyadh'},
            ],
          },
        ],
      };

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: payload),
            );
          },
        ),
      );

      final repo = ServiceRepository(dio: dio);
      addTearDown(repo.close);
      await repo.init();
      final cats = await repo.fetchCategories();
      final services = await repo.fetchServices();

      expect(cats, isNotEmpty);
      expect(cats.first.id, '1');
      expect(cats.first.label, isNotEmpty);
      expect(services, isNotEmpty);
      expect(services.first.categoryId, '1');
      expect(services.first.city, isNotEmpty);
    },
  );

  test(
    'fetchServicesByCategory labels services with the requested city when available',
    () async {
      final bootstrapPayload = {
        'cities': [
          {
            'id': 1,
            'name_ar': 'العلا',
            'name_en': 'AlUla',
          },
          {
            'id': 3,
            'name_ar': 'جدة',
            'name_en': 'Jeddah',
          },
        ],
        'service_categories': [
          {
            'id': 16,
            'name_ar': 'تطبيقات التوصيل',
            'name_en': 'Delivery Apps',
            'des_ar': 'N/A',
            'des_en': 'N/A',
          },
        ],
        'first_category': {
          'id': 16,
          'name_ar': 'تطبيقات التوصيل',
          'name_en': 'Delivery Apps',
        },
        'first_category_items': [
          {
            'id': 200,
            'service_category_id': 16,
            'name_ar': 'هنقرستيشن',
            'name_en': 'HungerStation',
            'short_des_ar': 'N/A',
            'short_des_en': 'N/A',
            'des_ar': 'خدمة توصيل',
            'des_en': 'Delivery service',
            'cities': [
              {'id': 1},
              {'id': 3},
            ],
          },
        ],
      };

      final categoryPayload = {
        'service_items': [
          {
            'id': 201,
            'service_category_id': 16,
            'name_ar': 'جاهز',
            'name_en': 'Jahez',
            'short_des_ar': 'N/A',
            'short_des_en': 'N/A',
            'des_ar': 'منصة توصيل',
            'des_en': 'Delivery platform',
            'cities': [
              {'id': 1},
              {'id': 3},
            ],
          },
        ],
      };

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            if (options.path.contains('/services-data/all')) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: bootstrapPayload,
                ),
              );
            } else if (options.path.contains('/services/16')) {
              expect(options.queryParameters['city_id'], equals(3));
              // Simulate async network delay.
              await Future<void>.delayed(const Duration(milliseconds: 10));
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: categoryPayload,
                ),
              );
            } else {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Unexpected URL: ${options.path}',
                ),
              );
            }
          },
        ),
      );

      final repo = ServiceRepository(dio: dio);
      addTearDown(repo.close);
      await repo.init();

      final results = await repo.fetchServicesByCategory('16', cityId: 3);

      expect(results, hasLength(1));
      final service = results.first;
      expect(service.city, 'جدة');
      expect(service.cityAr, 'جدة');
      expect(service.cityEn, 'Jeddah');
    },
  );
}
