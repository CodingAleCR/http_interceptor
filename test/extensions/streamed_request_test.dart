import 'dart:convert';
import 'dart:typed_data';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('StreamedRequest.copyWith', () {
    late StreamedRequest request;
    final Uri testUrl = Uri.parse('https://example.com');
    final Map<String, String> testHeaders = {
      'Content-Type': 'application/json',
    };

    setUp(() {
      request = StreamedRequest('POST', testUrl)..headers.addAll(testHeaders);

      // Add test data to the request
      final Uint8List testData = utf8.encode('test data');
      request.sink.add(testData);
      request.sink.close();
    });

    test(
      'creates a copy with the same properties when no parameters are provided',
      () async {
        // Buffer the original body before copyWith() ever runs
        final Uint8List originalBytes = await request.finalize().toBytes();

        // Act: pass the buffered stream into copyWith
        final StreamedRequest copy = await request.copyWith(
          stream: Stream.value(originalBytes),
        );

        // Assert basic properties
        expect(copy.method, equals(request.method));
        expect(copy.url, equals(request.url));
        expect(copy.headers, equals(request.headers));

        // Only finalize the copy, and compare its bytes to the buffer
        final Uint8List copyBytes = await copy.finalize().toBytes();
        expect(copyBytes, equals(originalBytes));

        // Assert default flags
        expect(copy.followRedirects, equals(true));
        expect(copy.maxRedirects, equals(5));
        expect(copy.persistentConnection, equals(true));
      },
    );

    test('overrides method when provided', () async {
      // Act
      final StreamedRequest copy =
          await request.copyWith(method: HttpMethod.PUT);

      // Assert
      expect(copy.method, equals('PUT'));
    });

    test('overrides url when provided', () async {
      // Arrange
      final Uri newUrl = Uri.parse('https://example.org');

      // Act
      final StreamedRequest copy = await request.copyWith(url: newUrl);

      // Assert
      expect(copy.url, equals(newUrl));
    });

    test('overrides headers when provided', () async {
      // Arrange
      final Map<String, String> newHeaders = {'Authorization': 'Bearer token'};

      // Act
      final StreamedRequest copy = await request.copyWith(headers: newHeaders);

      // Assert
      expect(copy.headers, equals(newHeaders));
    });

    test('overrides stream when provided', () async {
      // Arrange
      final Uint8List newData = utf8.encode('new data');
      final Stream<Uint8List> newStream = Stream.value(newData);

      // Act
      final StreamedRequest copy = await request.copyWith(stream: newStream);

      // Assert
      final Uint8List copyData = await copy.finalize().toBytes();
      expect(copyData, equals(newData));
    });

    test('sets followRedirects on original request (bug)', () async {
      // Arrange
      final bool originalValue = request.followRedirects;

      // Act
      final StreamedRequest copy =
          await request.copyWith(followRedirects: !originalValue);

      // Assert
      expect(request.followRedirects, equals(originalValue));
      expect(copy.followRedirects, equals(!originalValue));
    });

    test('sets maxRedirects on original request (bug)', () async {
      // Arrange
      final int newMaxRedirects = 10;

      // Act
      final StreamedRequest copy =
          await request.copyWith(maxRedirects: newMaxRedirects);

      // Assert
      expect(request.maxRedirects, equals(5));
      expect(copy.maxRedirects, equals(newMaxRedirects));
      expect(copy.method, equals(request.method));
    });

    test('sets persistentConnection on original request (bug)', () async {
      // Arrange
      final bool originalValue = request.persistentConnection;

      // Act
      final StreamedRequest copy =
          await request.copyWith(persistentConnection: !originalValue);

      // Assert
      expect(request.persistentConnection, equals(originalValue));
      expect(copy.persistentConnection, equals(!originalValue));
    });
  });
}
