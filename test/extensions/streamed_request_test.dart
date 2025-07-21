import 'dart:async';
import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('StreamedRequest Extension', () {
    test('should copy streamed request without modifications', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] = 'application/octet-stream';
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
      expect(copiedRequest.followRedirects,
          equals(originalRequest.followRedirects));
      expect(copiedRequest.maxRedirects, equals(originalRequest.maxRedirects));
      expect(copiedRequest.persistentConnection,
          equals(originalRequest.persistentConnection));
    });

    test('should copy streamed request with different method', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith(method: HttpMethod.PUT);

      expect(copiedRequest.method, equals('PUT'));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with different URL', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final newUrl = Uri.parse('https://example.com/new-stream');
      final copiedRequest = originalRequest.copyWith(url: newUrl);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(newUrl));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with different headers', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] = 'application/octet-stream';
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final newHeaders = {'Authorization': 'Bearer token', 'X-Custom': 'value'};
      final copiedRequest = originalRequest.copyWith(headers: newHeaders);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(newHeaders));
    });

    test('should copy streamed request with different stream', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.sink.add(utf8.encode('original data'));
      originalRequest.sink.close();

      final newStream = Stream.fromIterable([utf8.encode('new data')]);
      final copiedRequest = originalRequest.copyWith(stream: newStream);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with different followRedirects', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.followRedirects = true;
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith(followRedirects: false);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
      expect(copiedRequest.followRedirects, equals(false));
    });

    test('should copy streamed request with different maxRedirects', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.maxRedirects = 5;
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith(maxRedirects: 10);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
      expect(copiedRequest.maxRedirects, equals(10));
    });

    test('should copy streamed request with different persistentConnection',
        () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.persistentConnection = true;
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest =
          originalRequest.copyWith(persistentConnection: false);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
      expect(copiedRequest.persistentConnection, equals(false));
    });

    test('should copy streamed request with multiple modifications', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] = 'application/octet-stream';
      originalRequest.followRedirects = true;
      originalRequest.maxRedirects = 5;
      originalRequest.persistentConnection = true;
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final newUrl = Uri.parse('https://example.com/new-stream');
      final newHeaders = {'Authorization': 'Bearer token'};
      final newStream = Stream.fromIterable([utf8.encode('new data')]);

      final copiedRequest = originalRequest.copyWith(
        method: HttpMethod.PUT,
        url: newUrl,
        headers: newHeaders,
        stream: newStream,
        followRedirects: false,
        maxRedirects: 10,
        persistentConnection: false,
      );

      expect(copiedRequest.method, equals('PUT'));
      expect(copiedRequest.url, equals(newUrl));
      expect(copiedRequest.headers, equals(newHeaders));
      expect(copiedRequest.followRedirects, equals(false));
      expect(copiedRequest.maxRedirects, equals(10));
      expect(copiedRequest.persistentConnection, equals(false));
    });

    test('should copy streamed request with large data', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] = 'text/plain';

      // Add large data in chunks
      final largeData = 'A' * 1024; // 1KB
      for (int i = 0; i < 10; i++) {
        originalRequest.sink.add(utf8.encode(largeData));
      }
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with different HTTP methods', () {
      final methods = [
        HttpMethod.GET,
        HttpMethod.POST,
        HttpMethod.PUT,
        HttpMethod.PATCH,
        HttpMethod.DELETE
      ];

      for (final method in methods) {
        final originalRequest = StreamedRequest(
            method.asString, Uri.parse('https://example.com/stream'));
        originalRequest.sink.add(utf8.encode('test data'));
        originalRequest.sink.close();

        final copiedRequest = originalRequest.copyWith();

        expect(copiedRequest.method, equals(method.asString));
        expect(copiedRequest.url, equals(originalRequest.url));
        expect(copiedRequest.headers, equals(originalRequest.headers));
      }
    });

    test('should copy streamed request with custom headers', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] =
          'application/octet-stream; charset=utf-8';
      originalRequest.headers['Authorization'] = 'Bearer custom-token';
      originalRequest.headers['X-Custom-Header'] = 'custom-value';
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with empty stream', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.sink.close(); // No data added

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with binary data', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] = 'application/octet-stream';

      // Add binary data
      final binaryData = List<int>.generate(1000, (i) => i % 256);
      originalRequest.sink.add(binaryData);
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with JSON data', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.headers['Content-Type'] = 'application/json';

      final jsonData = jsonEncode({'key': 'value', 'number': 42});
      originalRequest.sink.add(utf8.encode(jsonData));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should copy streamed request with special characters in URL', () {
      final originalRequest = StreamedRequest(
          'POST',
          Uri.parse(
              'https://example.com/stream/path with spaces?param=value with spaces'));
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
    });

    test('should not modify original request when using copyWith', () {
      final originalRequest =
          StreamedRequest('POST', Uri.parse('https://example.com/stream'));
      originalRequest.followRedirects = true;
      originalRequest.maxRedirects = 5;
      originalRequest.persistentConnection = true;
      originalRequest.sink.add(utf8.encode('test data'));
      originalRequest.sink.close();

      final copiedRequest = originalRequest.copyWith(
        method: HttpMethod.PUT,
        followRedirects: false,
        maxRedirects: 10,
        persistentConnection: false,
      );

      // Verify the copied request has the new values
      expect(copiedRequest.method, equals('PUT'));
      expect(copiedRequest.followRedirects, equals(false));
      expect(copiedRequest.maxRedirects, equals(10));
      expect(copiedRequest.persistentConnection, equals(false));

      // Verify the original request remains unchanged
      expect(originalRequest.method, equals('POST'));
      expect(originalRequest.followRedirects, equals(true));
      expect(originalRequest.maxRedirects, equals(5));
      expect(originalRequest.persistentConnection, equals(true));
    });
  });
}
