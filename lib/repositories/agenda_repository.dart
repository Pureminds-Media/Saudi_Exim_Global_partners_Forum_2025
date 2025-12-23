import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:saudiexim_mobile_app/models/lecture.dart';
import 'package:saudiexim_mobile_app/models/agenda_config.dart';

/// Repository fetching forum lectures (sessions) from the backend.
class AgendaRepository {
  final Dio _dio;

  AgendaRepository({Dio? dio}) : _dio = dio ?? _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://segpr.saudiexim.gov.sa/backend/public',
        connectTimeout: const Duration(seconds: 60), // DNS/TCP/TLS phase
        receiveTimeout: const Duration(seconds: 60), // after first byte
        sendTimeout: const Duration(seconds: 30),
        headers: const {'Accept': 'application/json'},
        responseType: ResponseType.json,
        validateStatus: (s) => s != null && s < 500,
      ),
    )..interceptors.add(LogInterceptor(responseBody: false));

    // Configure the underlying HttpClient (Android-specific improvements)
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 25);
      // Ensure we don't inherit any system proxy quirks
      client.findProxy = (uri) => 'DIRECT';
      return client;
    };
    return dio;
  }

  /// Fetch all lectures. Endpoint is public.
  Future<List<Lecture>> fetchLectures() async {
    const host = 'segpr.saudiexim.gov.sa';
    const url = 'https://$host/backend/public/api/lectures';
    try {
      // Quick DNS sanity check to provide a clearer message on failures
      try {
        final addresses = await InternetAddress.lookup(host);
        if (addresses.isEmpty) {
          throw const SocketException('Empty DNS response');
        }
      } on SocketException catch (e) {
        throw Exception('DNS lookup failed for $host: $e');
      }

      // Light retry to mitigate transient network stalls on some devices
      Response resp;
      DioException? lastError;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          resp = await _dio.get(url);
          // Success, break the retry loop
          if (resp.statusCode == 200) {
            final data = resp.data as List<dynamic>;
            return data
                .map((e) => Lecture.fromJson(e as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception('Failed to fetch lectures: ${resp.statusCode}');
          }
        } on DioException catch (e) {
          lastError = e;
          // Small delay before retry
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }
      // If we reached here, retries failed
      throw Exception(
        'Network error fetching lectures: ${lastError?.message ?? 'Unknown error'}',
      );
    } on DioException catch (e) {
      throw Exception('Network error fetching lectures: ${e.message}');
    }
  }

  /// Fetch agenda configuration: localized day titles and fixed items.
  /// Endpoint: /api/agenda-config/keys
  Future<AgendaConfig> fetchAgendaConfig() async {
    const host = 'segpr.saudiexim.gov.sa';
    const url = 'https://$host/backend/public/api/agenda-config/keys';
    try {
      // DNS sanity check
      try {
        final addresses = await InternetAddress.lookup(host);
        if (addresses.isEmpty) {
          throw const SocketException('Empty DNS response');
        }
      } on SocketException catch (e) {
        throw Exception('DNS lookup failed for $host: $e');
      }

      Response resp;
      DioException? lastError;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          resp = await _dio.get(url);
          if (resp.statusCode == 200) {
            final body = resp.data as Map<String, dynamic>;
            final data = (body['data'] ?? {}) as Map<String, dynamic>;
            return _parseAgendaConfigV2(data);
          } else {
            throw Exception('Failed to fetch agenda config: ${resp.statusCode}');
          }
        } on DioException catch (e) {
          lastError = e;
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }
      throw Exception(
        'Network error fetching agenda config: ${lastError?.message ?? 'Unknown error'}',
      );
    } on DioException catch (e) {
      throw Exception('Network error fetching agenda config: ${e.message}');
    }
  }

  // Robust parser using correct regex anchors for agenda-config keys.
  AgendaConfig _parseAgendaConfigV2(Map<String, dynamic> data) {
    final titlesEn = <int, String>{};
    final titlesAr = <int, String>{};
    final fixed = <int, Map<int, AgendaFixedItem>>{}; // day -> idx -> item

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      final titleMatch = RegExp(r'^days\.day\.(\d+)\.title_(en|ar)$').firstMatch(key);
      if (titleMatch != null) {
        final day = int.tryParse(titleMatch.group(1) ?? '');
        final lang = titleMatch.group(2);
        if (day != null) {
          if (lang == 'en') titlesEn[day] = (value ?? '').toString();
          if (lang == 'ar') titlesAr[day] = (value ?? '').toString();
        }
        continue;
      }

      final fixedMatch = RegExp(
        r'^days\.day\.(\d+)\.fixed\.(\d+)\.(start|end|title_en|title_ar|desc_en|desc_ar)$',
      ).firstMatch(key);
      if (fixedMatch != null) {
        final day = int.tryParse(fixedMatch.group(1) ?? '');
        final idx = int.tryParse(fixedMatch.group(2) ?? '');
        final prop = fixedMatch.group(3)!;
        if (day == null || idx == null) continue;
        final perDay = fixed[day] ??= {};
        final existing = perDay[idx];
        String start = existing?.start ?? '';
        String end = existing?.end ?? '';
        String titleEn = existing?.titleEn ?? '';
        String titleAr = existing?.titleAr ?? '';
        String? descEn = existing?.descEn;
        String? descAr = existing?.descAr;

        switch (prop) {
          case 'start':
            start = (value ?? '').toString();
            break;
          case 'end':
            end = (value ?? '').toString();
            break;
          case 'title_en':
            titleEn = (value ?? '').toString();
            break;
          case 'title_ar':
            titleAr = (value ?? '').toString();
            break;
          case 'desc_en':
            descEn = (value?.toString().isEmpty ?? true) ? null : value.toString();
            break;
          case 'desc_ar':
            descAr = (value?.toString().isEmpty ?? true) ? null : value.toString();
            break;
        }

        perDay[idx] = AgendaFixedItem(
          start: start,
          end: end,
          titleEn: titleEn,
          titleAr: titleAr,
          descEn: descEn,
          descAr: descAr,
        );
      }
    }

    final fixedByDay = <int, List<AgendaFixedItem>>{};
    for (final e in fixed.entries) {
      final items = e.value.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      fixedByDay[e.key] = items.map((e) => e.value).toList();
    }

    return AgendaConfig(
      dayTitleEn: titlesEn,
      dayTitleAr: titlesAr,
      fixedByDay: fixedByDay,
    );
  }
  AgendaConfig _parseAgendaConfig(Map<String, dynamic> data) {
    final titlesEn = <int, String>{};
    final titlesAr = <int, String>{};
    final fixed = <int, Map<int, AgendaFixedItem>>{}; // day -> idx -> item

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      // titles
      final titleMatch = RegExp(r'^days\.day\.(\d+)\.title_(en|ar)\$').firstMatch(key);
      if (titleMatch != null) {
        final day = int.tryParse(titleMatch.group(1) ?? '');
        final lang = titleMatch.group(2);
        if (day != null) {
          if (lang == 'en') titlesEn[day] = (value ?? '').toString();
          if (lang == 'ar') titlesAr[day] = (value ?? '').toString();
        }
        continue;
      }

      // fixed items: start/end/title/desc
      final fixedMatch = RegExp(
        r'^days\.day\.(\d+)\.fixed\.(\d+)\.(start|end|title_en|title_ar|desc_en|desc_ar)\$',
      ).firstMatch(key);
      if (fixedMatch != null) {
        final day = int.tryParse(fixedMatch.group(1) ?? '');
        final idx = int.tryParse(fixedMatch.group(2) ?? '');
        final prop = fixedMatch.group(3)!;
        if (day == null || idx == null) continue;
        final perDay = fixed[day] ??= {};
        final existing = perDay[idx];
        String start = existing?.start ?? '';
        String end = existing?.end ?? '';
        String titleEn = existing?.titleEn ?? '';
        String titleAr = existing?.titleAr ?? '';
        String? descEn = existing?.descEn;
        String? descAr = existing?.descAr;

        switch (prop) {
          case 'start':
            start = (value ?? '').toString();
            break;
          case 'end':
            end = (value ?? '').toString();
            break;
          case 'title_en':
            titleEn = (value ?? '').toString();
            break;
          case 'title_ar':
            titleAr = (value ?? '').toString();
            break;
          case 'desc_en':
            descEn = (value?.toString().isEmpty ?? true) ? null : value.toString();
            break;
          case 'desc_ar':
            descAr = (value?.toString().isEmpty ?? true) ? null : value.toString();
            break;
        }

        perDay[idx] = AgendaFixedItem(
          start: start,
          end: end,
          titleEn: titleEn,
          titleAr: titleAr,
          descEn: descEn,
          descAr: descAr,
        );
      }
    }

    // Convert index maps to sorted lists
    final fixedByDay = <int, List<AgendaFixedItem>>{};
    for (final e in fixed.entries) {
      final items = e.value.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      fixedByDay[e.key] = items.map((e) => e.value).toList();
    }

    return AgendaConfig(
      dayTitleEn: titlesEn,
      dayTitleAr: titlesAr,
      fixedByDay: fixedByDay,
    );
  }
}
