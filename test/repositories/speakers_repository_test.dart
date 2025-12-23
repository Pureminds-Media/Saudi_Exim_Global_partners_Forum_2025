import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saudiexim_mobile_app/repositories/speakers_repository.dart';
import 'package:saudiexim_mobile_app/utils/api_endpoints.dart';

void main() {
  test('NetworkSpeakersRepository uses configured endpoint without token', () async {
    final recordedRequests = <RequestOptions>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            recordedRequests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                data: const <Map<String, dynamic>>[],
                statusCode: 200,
              ),
            );
          },
        ),
      );

    final repository = NetworkSpeakersRepository(dio: dio);
    await repository.fetchSessions();

    expect(recordedRequests, hasLength(1));
    final uri = recordedRequests.single.uri;
    expect(uri.toString(), speakersApiUrl);
    expect(uri.queryParameters.containsKey('token'), isFalse);
  });

  test('NetworkSpeakersRepository throws when payload is not a list', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: <String, dynamic>{'unexpected': true},
                statusCode: 200,
              ),
            );
          },
        ),
      );

    final repository = NetworkSpeakersRepository(dio: dio);

    await expectLater(
      repository.fetchSessions(),
      throwsA(isA<Exception>()),
    );
  });
}
