import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  group('StreamedRequest.copyWith:', () {
    test('copies followRedirects to cloned request', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'))
            ..followRedirects = true;

      // Act
      final copied = request.copyWith(followRedirects: false);

      // Assert
      expect(copied.followRedirects, equals(false));
    });

    test('copies maxRedirects to cloned request', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'))
            ..maxRedirects = 5;

      // Act
      final copied = request.copyWith(maxRedirects: 10);

      // Assert
      expect(copied.maxRedirects, equals(10));
    });

    test('copies persistentConnection to cloned request', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'))
            ..persistentConnection = true;

      // Act
      final copied = request.copyWith(persistentConnection: false);

      // Assert
      expect(copied.persistentConnection, equals(false));
    });

    test('does not mutate original request properties', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'))
            ..followRedirects = true
            ..maxRedirects = 5
            ..persistentConnection = true;

      // Act
      request.copyWith(
        followRedirects: false,
        maxRedirects: 10,
        persistentConnection: false,
      );

      // Assert - original should be unchanged
      expect(request.followRedirects, equals(true));
      expect(request.maxRedirects, equals(5));
      expect(request.persistentConnection, equals(true));
    });

    test('preserves original values when no overrides provided', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'))
            ..followRedirects = false
            ..maxRedirects = 3
            ..persistentConnection = false;

      // Act
      final copied = request.copyWith();

      // Assert
      expect(copied.followRedirects, equals(false));
      expect(copied.maxRedirects, equals(3));
      expect(copied.persistentConnection, equals(false));
    });

    test('copies method and url', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'));

      // Act
      final copied = request.copyWith(
        method: HttpMethod.POST,
        url: Uri.https('www.example.com', '/other'),
      );

      // Assert
      expect(copied.method, equals('POST'));
      expect(copied.url, equals(Uri.https('www.example.com', '/other')));
    });

    test('copies headers', () {
      // Arrange
      final request =
          StreamedRequest('GET', Uri.https('www.example.com', '/test'))
            ..headers.addAll({'Authorization': 'Bearer token'});

      // Act
      final copied = request.copyWith();

      // Assert
      expect(copied.headers['Authorization'], equals('Bearer token'));
    });

    test('copies stream data', () async {
      // Arrange
      final data = utf8.encode('hello world');
      final stream = Stream.value(data);

      final request =
          StreamedRequest('POST', Uri.https('www.example.com', '/test'));

      // Act
      final copied = request.copyWith(stream: stream);

      // Assert - read the stream from the copied request
      final response = await copied.finalize().toList();
      expect(response.expand((e) => e).toList(), equals(data));
    });
  });
}
