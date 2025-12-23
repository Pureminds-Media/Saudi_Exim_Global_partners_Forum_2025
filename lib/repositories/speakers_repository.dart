import 'dart:async';

import 'package:dio/dio.dart';

import '../utils/api_endpoints.dart';

/// Contract for loading speaker sessions from a backend source.
abstract class SpeakersRepository {
  Future<List<Map<String, dynamic>>> fetchSessions();
}

/// Network implementation that hits the public speakers endpoint.
class NetworkSpeakersRepository implements SpeakersRepository {
  NetworkSpeakersRepository({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(speakersApiUrl);
    } on DioException catch (e) {
      throw Exception('Network error fetching speakers: ${e.message}');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch speakers: HTTP ${response.statusCode}');
    }

    final data = response.data;
    if (data is! List) {
      throw Exception('Unexpected payload shape (expected List)');
    }

    return data
        .map((dynamic item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }
}
