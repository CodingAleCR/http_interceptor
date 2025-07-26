import 'dart:convert';

import 'package:http/io_client.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('IOStreamedResponse.copyWith', () {
    late IOStreamedResponse response;
    final testRequest = Request('GET', Uri.parse('https://example.com'));
    final testHeaders = {'Content-Type': 'application/json'};
    final testStream = Stream.value(utf8.encode('test data'));
    final testStatusCode = 200;
    final testContentLength = 9; // 'test data'.length
    final testIsRedirect = false;
    final testPersistentConnection = true;
    final testReasonPhrase = 'OK';

    setUp(() {
      response = IOStreamedResponse(
        testStream,
        testStatusCode,
        contentLength: testContentLength,
        request: testRequest,
        headers: testHeaders,
        isRedirect: testIsRedirect,
        persistentConnection: testPersistentConnection,
        reasonPhrase: testReasonPhrase,
      );
    });

    test(
        'creates a copy with the same properties when no parameters are provided',
        () {
      // Act
      final copy = response.copyWith();

      // Assert
      expect(copy.statusCode, equals(testStatusCode));
      expect(copy.contentLength, equals(testContentLength));
      expect(copy.request, equals(testRequest));
      expect(copy.headers, equals(testHeaders));
      expect(copy.isRedirect, equals(testIsRedirect));
      expect(copy.persistentConnection, equals(testPersistentConnection));
      expect(copy.reasonPhrase, equals(testReasonPhrase));
    });

    test('overrides statusCode when provided', () {
      // Arrange
      final newStatusCode = 201;

      // Act
      final copy = response.copyWith(statusCode: newStatusCode);

      // Assert
      expect(copy.statusCode, equals(newStatusCode));
      expect(copy.contentLength,
          equals(testContentLength)); // Other properties remain the same
    });

    test('overrides contentLength when provided', () {
      // Arrange
      final newContentLength = 100;

      // Act
      final copy = response.copyWith(contentLength: newContentLength);

      // Assert
      expect(copy.contentLength, equals(newContentLength));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('overrides request when provided', () {
      // Arrange
      final newRequest = Request('POST', Uri.parse('https://example.org'));

      // Act
      final copy = response.copyWith(request: newRequest);

      // Assert
      expect(copy.request, equals(newRequest));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('overrides headers when provided', () {
      // Arrange
      final newHeaders = {'Authorization': 'Bearer token'};

      // Act
      final copy = response.copyWith(headers: newHeaders);

      // Assert
      expect(copy.headers, equals(newHeaders));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('overrides isRedirect when provided', () {
      // Act
      final copy = response.copyWith(isRedirect: !testIsRedirect);

      // Assert
      expect(copy.isRedirect, equals(!testIsRedirect));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('overrides persistentConnection when provided', () {
      // Act
      final copy =
          response.copyWith(persistentConnection: !testPersistentConnection);

      // Assert
      expect(copy.persistentConnection, equals(!testPersistentConnection));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('overrides reasonPhrase when provided', () {
      // Arrange
      final newReasonPhrase = 'Created';

      // Act
      final copy = response.copyWith(reasonPhrase: newReasonPhrase);

      // Assert
      expect(copy.reasonPhrase, equals(newReasonPhrase));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('overrides stream when provided', () async {
      // Arrange
      final newData = utf8.encode('new data');
      final newStream = Stream.value(newData);

      // Act
      final copy = response.copyWith(stream: newStream);

      // Assert
      final copyData = await copy.stream.toList();
      final flattenedCopyData = copyData.expand((x) => x).toList();
      expect(flattenedCopyData, equals(newData));
      expect(copy.statusCode,
          equals(testStatusCode)); // Other properties remain the same
    });

    test('can override multiple properties at once', () {
      // Arrange
      final newStatusCode = 201;
      final newHeaders = {'Authorization': 'Bearer token'};
      final newReasonPhrase = 'Created';

      // Act
      final copy = response.copyWith(
        statusCode: newStatusCode,
        headers: newHeaders,
        reasonPhrase: newReasonPhrase,
      );

      // Assert
      expect(copy.statusCode, equals(newStatusCode));
      expect(copy.headers, equals(newHeaders));
      expect(copy.reasonPhrase, equals(newReasonPhrase));
      expect(copy.contentLength,
          equals(testContentLength)); // Unchanged properties remain the same
    });
  });
}
