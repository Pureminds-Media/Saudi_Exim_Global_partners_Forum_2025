import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:saudiexim_mobile_app/models/sponsor.dart';
import 'package:saudiexim_mobile_app/utils/api_endpoints.dart';

class SponsorsRepository {
  final Dio _dio;

  SponsorsRepository({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
        responseType: ResponseType.json,
        validateStatus: (s) => s != null && s < 500,
      ),
    )..interceptors.add(LogInterceptor(responseBody: false));

    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 25);
      client.findProxy = (uri) => 'DIRECT';
      return client;
    };
    return dio;
  }

  Future<List<Sponsor>> fetchSponsors() async {
    final uri = Uri.parse(sponsorsApiUrl);
    try {
      // DNS sanity check for clearer errors
      try {
        final addresses = await InternetAddress.lookup(uri.host);
        if (addresses.isEmpty) {
          throw const SocketException('Empty DNS response');
        }
      } on SocketException catch (e) {
        throw Exception('DNS lookup failed for ${uri.host}: $e');
      }

      Response resp;
      DioException? lastError;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          resp = await _dio.get(sponsorsApiUrl);
          if (resp.statusCode == 200) {
            final data = resp.data as List<dynamic>;
            return data.map((e) => Sponsor.fromJson(e as Map<String, dynamic>)).toList();
          } else {
            throw Exception('Failed to fetch sponsors: ${resp.statusCode}');
          }
        } on DioException catch (e) {
          lastError = e;
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }
      throw Exception('Network error fetching sponsors: ${lastError?.message ?? 'Unknown error'}');
    } on DioException catch (e) {
      throw Exception('Network error fetching sponsors: ${e.message}');
    }
  }
}

