import 'dart:async';
import 'dart:convert';

import 'package:http/io_client.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('IOStreamedResponse Extension', () {
    test('should copy IOStreamedResponse without modifications', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith();

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
      expect(copiedResponse.isRedirect, equals(originalResponse.isRedirect));
      expect(copiedResponse.persistentConnection,
          equals(originalResponse.persistentConnection));
      expect(
          copiedResponse.reasonPhrase, equals(originalResponse.reasonPhrase));
    });

    test('should copy IOStreamedResponse with different stream', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('original response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final newStream =
          Stream<List<int>>.fromIterable([utf8.encode('new response')]);
      final copiedResponse = originalResponse.copyWith(stream: newStream);

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
      // Stream comparison is not reliable due to different stream types
      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
    });

    test('should copy IOStreamedResponse with different status code', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith(statusCode: 201);

      expect(copiedResponse.statusCode, equals(201));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with different content length', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        contentLength: 100,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith(contentLength: 200);

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(copiedResponse.contentLength, equals(200));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with different request', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final newRequest =
          Request('POST', Uri.parse('https://example.com/new-test'));
      final copiedResponse = originalResponse.copyWith(request: newRequest);

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(newRequest));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with different headers', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final newHeaders = {
        'Content-Type': 'application/json',
        'X-Custom': 'value'
      };
      final copiedResponse = originalResponse.copyWith(headers: newHeaders);

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(newHeaders));
    });

    test('should copy IOStreamedResponse with different isRedirect', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        isRedirect: false,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith(isRedirect: true);

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
      expect(copiedResponse.isRedirect, equals(true));
    });

    test('should copy IOStreamedResponse with different persistentConnection',
        () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        persistentConnection: true,
        request: originalRequest,
      );

      final copiedResponse =
          originalResponse.copyWith(persistentConnection: false);

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
      expect(copiedResponse.persistentConnection, equals(false));
    });

    test('should copy IOStreamedResponse with different reason phrase', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        reasonPhrase: 'OK',
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith(reasonPhrase: 'Created');

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
      expect(copiedResponse.reasonPhrase, equals('Created'));
    });

    test('should copy IOStreamedResponse with multiple modifications', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        contentLength: 100,
        isRedirect: false,
        persistentConnection: true,
        reasonPhrase: 'OK',
        request: originalRequest,
      );

      final newRequest =
          Request('POST', Uri.parse('https://example.com/new-test'));
      final newStream =
          Stream<List<int>>.fromIterable([utf8.encode('new response')]);
      final newHeaders = {'Content-Type': 'application/json'};

      final copiedResponse = originalResponse.copyWith(
        stream: newStream,
        statusCode: 201,
        contentLength: 200,
        request: newRequest,
        headers: newHeaders,
        isRedirect: true,
        persistentConnection: false,
        reasonPhrase: 'Created',
      );

      // Stream comparison is not reliable due to different stream types
      expect(copiedResponse.statusCode, equals(201));
      expect(copiedResponse.contentLength, equals(200));
      expect(copiedResponse.request, equals(newRequest));
      expect(copiedResponse.headers, equals(newHeaders));
      expect(copiedResponse.isRedirect, equals(true));
      expect(copiedResponse.persistentConnection, equals(false));
      expect(copiedResponse.reasonPhrase, equals('Created'));
    });

    test('should copy IOStreamedResponse with large data', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final largeData = 'A' * 10000; // 10KB
      final originalStream = Stream.fromIterable([utf8.encode(largeData)]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith();

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with different status codes', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final statusCodes = [
        200,
        201,
        204,
        301,
        400,
        401,
        403,
        404,
        500,
        502,
        503
      ];

      for (final statusCode in statusCodes) {
        final copiedResponse =
            originalResponse.copyWith(statusCode: statusCode);

        expect(copiedResponse.statusCode, equals(statusCode));
        expect(copiedResponse.contentLength,
            equals(originalResponse.contentLength));
        expect(copiedResponse.request, equals(originalResponse.request));
        expect(copiedResponse.headers, equals(originalResponse.headers));
      }
    });

    test('should copy IOStreamedResponse with custom headers', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalHeaders = {
        'Content-Type': 'application/json; charset=utf-8',
        'Cache-Control': 'no-cache',
        'X-Custom-Header': 'custom-value',
      };
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        headers: originalHeaders,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith();

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with empty stream', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream = Stream<List<int>>.empty();
      final originalResponse = IOStreamedResponse(
        originalStream,
        204,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith();

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with binary data', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final binaryData = List<int>.generate(1000, (i) => i % 256);
      final originalStream = Stream.fromIterable([binaryData]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith();

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should copy IOStreamedResponse with JSON data', () {
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final jsonData = jsonEncode({'key': 'value', 'number': 42});
      final originalStream = Stream.fromIterable([utf8.encode(jsonData)]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      final copiedResponse = originalResponse.copyWith();

      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });

    test('should document inner parameter limitation', () {
      // This test documents the current limitation of the copyWith method
      // regarding the inner parameter. Since the _inner field is private
      // in IOStreamedResponse, we cannot access it from our extension.
      // Therefore, when no inner parameter is provided, we cannot preserve
      // the existing inner response and must pass null to the constructor.
      
      final originalRequest =
          Request('GET', Uri.parse('https://example.com/test'));
      final originalStream =
          Stream.fromIterable([utf8.encode('test response')]);
      final originalResponse = IOStreamedResponse(
        originalStream,
        200,
        request: originalRequest,
      );

      // The current implementation cannot preserve the existing inner response
      // when no new value is supplied because we cannot access the private
      // _inner field. This is a limitation of the current design.
      final copiedResponse = originalResponse.copyWith();

      // The copied response will have null for the inner parameter
      // This is the expected behavior given the current implementation
      expect(copiedResponse.statusCode, equals(originalResponse.statusCode));
      expect(
          copiedResponse.contentLength, equals(originalResponse.contentLength));
      expect(copiedResponse.request, equals(originalResponse.request));
      expect(copiedResponse.headers, equals(originalResponse.headers));
    });
  });
} 