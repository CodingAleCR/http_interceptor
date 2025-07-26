import 'dart:convert';

import 'package:http/io_client.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  group('BaseResponse.copyWith: ', () {
    test('Response is copied from BaseResponse', () {
      // Arrange
      final BaseResponse baseResponse = Response("{'foo': 'bar'}", 200);

      // Act
      final copiedBaseResponse = baseResponse.copyWith();
      final copied = copiedBaseResponse as Response;

      // Assert
      final response = baseResponse as Response;
      expect(copied.hashCode, isNot(equals(response.hashCode)));
      expect(copied.statusCode, equals(response.statusCode));
      expect(copied.body, equals(response.body));
      expect(copied.headers, equals(response.headers));
      expect(copied.isRedirect, equals(response.isRedirect));
      expect(copied.reasonPhrase, equals(response.reasonPhrase));
      expect(
          copied.persistentConnection, equals(response.persistentConnection));
    });

    test('IOStreamedResponse is copied from BaseResponse', () {
      // Arrange
      final testRequest = Request('GET', Uri.parse('https://example.com'));
      final testHeaders = {'Content-Type': 'application/json'};
      final testStream = Stream.value(utf8.encode('test data'));
      final testStatusCode = 200;
      final testContentLength = 9; // 'test data'.length
      final testIsRedirect = false;
      final testPersistentConnection = true;
      final testReasonPhrase = 'OK';

      final BaseResponse baseResponse = IOStreamedResponse(
        testStream,
        testStatusCode,
        contentLength: testContentLength,
        request: testRequest,
        headers: testHeaders,
        isRedirect: testIsRedirect,
        persistentConnection: testPersistentConnection,
        reasonPhrase: testReasonPhrase,
      );

      // Act
      final copiedBaseResponse = baseResponse.copyWith();

      // Assert
      final copied = copiedBaseResponse as IOStreamedResponse;
      final response = baseResponse as IOStreamedResponse;
      expect(copied.hashCode, isNot(equals(response.hashCode)));
      expect(copied.statusCode, equals(response.statusCode));
      expect(copied.contentLength, equals(response.contentLength));
      expect(copied.request, equals(response.request));
      expect(copied.headers, equals(response.headers));
      expect(copied.isRedirect, equals(response.isRedirect));
      expect(
          copied.persistentConnection, equals(response.persistentConnection));
      expect(copied.reasonPhrase, equals(response.reasonPhrase));
    });

    test('throws UnsupportedError for unsupported response type', () {
      // Arrange
      final unsupportedResponse = _UnsupportedResponse();

      // Act & Assert
      expect(
        () => unsupportedResponse.copyWith(),
        throwsA(isA<UnsupportedError>().having(
          (e) => e.message,
          'message',
          'Cannot copy unsupported type of response _UnsupportedResponse',
        )),
      );
    });
  });
}

// Custom response type that doesn't extend any of the supported types
class _UnsupportedResponse extends BaseResponse {
  _UnsupportedResponse() : super(200);
}
