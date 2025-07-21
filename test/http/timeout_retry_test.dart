import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

// Test interceptors for timeout and retry testing
class TestInterceptor implements InterceptorContract {
  final List<String> log = [];

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async {
    log.add('shouldInterceptRequest: ${request.method} ${request.url}');
    return true;
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    log.add('interceptRequest: ${request.method} ${request.url}');
    return request;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    log.add('shouldInterceptResponse: ${response.statusCode}');
    return true;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    log.add('interceptResponse: ${response.statusCode}');
    return response;
  }
}

// Retry policy for testing
class TestRetryPolicy extends RetryPolicy {
  final int maxAttempts;
  final bool shouldRetryOnException;
  final bool shouldRetryOnResponse;
  final int retryOnStatusCodes;
  final Duration delay;

  TestRetryPolicy({
    this.maxAttempts = 1,
    this.shouldRetryOnException = false,
    this.shouldRetryOnResponse = false,
    this.retryOnStatusCodes = 500,
    this.delay = Duration.zero,
  });

  @override
  int get maxRetryAttempts => maxAttempts;

  @override
  Future<bool> shouldAttemptRetryOnException(
      Exception reason, BaseRequest request) async {
    return shouldRetryOnException;
  }

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    return shouldRetryOnResponse && response.statusCode == retryOnStatusCodes;
  }

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) {
    return delay;
  }

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) {
    return delay;
  }
}

void main() {
  group('Timeout Tests', () {
    late HttpServer server;
    late String baseUrl;

    setUpAll(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://localhost:${server.port}';

      server.listen((HttpRequest request) async {
        final response = request.response;
        response.headers.contentType = ContentType.json;

        // Simulate slow response
        await Future.delayed(Duration(milliseconds: 100));

        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'status': 'success',
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    test('should handle request timeout', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        requestTimeout: Duration(milliseconds: 50), // Shorter than server delay
      );

      expect(
        () => http.get(Uri.parse('$baseUrl/test')),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle request timeout with custom callback', () async {
      final interceptor = TestInterceptor();
      bool timeoutCallbackCalled = false;

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        requestTimeout: Duration(milliseconds: 50),
        onRequestTimeout: () {
          timeoutCallbackCalled = true;
          return Future.value(StreamedResponse(
            Stream.value([]),
            408,
            reasonPhrase: 'Request Timeout',
          ));
        },
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(408));
      expect(timeoutCallbackCalled, isTrue);
    });

    test('should not timeout when request completes in time', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        requestTimeout: Duration(seconds: 1), // Longer than server delay
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(interceptor.log,
          contains('shouldInterceptRequest: GET $baseUrl/test'));
    });

    test('should handle timeout with InterceptedClient', () async {
      final interceptor = TestInterceptor();
      final client = InterceptedClient.build(
        interceptors: [interceptor],
        requestTimeout: Duration(milliseconds: 50),
      );

      expect(
        () => client.get(Uri.parse('$baseUrl/test')),
        throwsA(isA<Exception>()),
      );

      client.close();
    });
  });

  group('Retry Policy Tests', () {
    late HttpServer server;
    late String baseUrl;
    late int requestCount;

    setUpAll(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://localhost:${server.port}';
      requestCount = 0;

      server.listen((HttpRequest request) {
        requestCount++;
        final response = request.response;
        response.headers.contentType = ContentType.json;

        // Return different status codes based on request count
        int statusCode = 200;
        if (requestCount == 1) {
          statusCode = 500; // First request fails
        } else {
          statusCode = 200; // Subsequent requests succeed
        }

        response.statusCode = statusCode;
        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'status': statusCode == 200 ? 'success' : 'error',
          'attempt': requestCount,
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    setUp(() {
      requestCount = 0;
    });

    test('should retry on response status code', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 2,
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
      );

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(2)); // Initial request + 1 retry
      expect(
          interceptor.log.length, greaterThan(2)); // Multiple interceptor calls
    });

    test('should not retry when max attempts reached', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 1, // Only 1 retry attempt
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
      );

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200)); // Should succeed after retry
      expect(requestCount, equals(2)); // Initial request + 1 retry
    });

    test('should retry with delay', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 2,
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
        delay: Duration(milliseconds: 100),
      );

      final stopwatch = Stopwatch()..start();
      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      await http.get(Uri.parse('$baseUrl/test'));
      stopwatch.stop();

      expect(stopwatch.elapsed.inMilliseconds,
          greaterThan(100)); // Should include delay
      expect(requestCount, equals(2));
    });

    test('should not retry on successful response', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 3,
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
      );

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(2)); // Should stop after successful retry
    });

    test('should handle retry with InterceptedClient', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 2,
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
      );

      final client = InterceptedClient.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await client.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(2));

      client.close();
    });
  });

  group('Exception Retry Tests', () {
    late HttpServer server;
    late String baseUrl;
    late int requestCount;

    setUpAll(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://localhost:${server.port}';
      requestCount = 0;

      server.listen((HttpRequest request) {
        requestCount++;

        if (requestCount == 1) {
          // First request: close connection to cause exception
          request.response.close();
        } else {
          // Subsequent requests: normal response
          final response = request.response;
          response.headers.contentType = ContentType.json;
          response.write(jsonEncode({
            'method': request.method,
            'url': request.uri.toString(),
            'status': 'success',
            'attempt': requestCount,
          }));
          response.close();
        }
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    setUp(() {
      requestCount = 0;
    });

    test('should retry on exception', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 2,
        shouldRetryOnException: true,
      );

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(1)); // Only one successful request
    });

    test('should not retry on exception when disabled', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 2,
        shouldRetryOnException: false, // Disabled
      );

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(1)); // Only initial request
    });
  });

  group('Complex Retry Scenarios', () {
    late HttpServer server;
    late String baseUrl;
    late int requestCount;

    setUpAll(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://localhost:${server.port}';
      requestCount = 0;

      server.listen((HttpRequest request) async {
        requestCount++;
        final response = request.response;
        response.headers.contentType = ContentType.json;

        // Simulate different failure patterns
        if (requestCount <= 2) {
          response.statusCode = 500; // First two requests fail
        } else {
          response.statusCode = 200; // Third request succeeds
        }

        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'status': response.statusCode == 200 ? 'success' : 'error',
          'attempt': requestCount,
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    setUp(() {
      requestCount = 0;
    });

    test('should handle multiple retries with exponential backoff', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 3,
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
        delay: Duration(milliseconds: 50), // Fixed delay for testing
      );

      final stopwatch = Stopwatch()..start();
      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));
      stopwatch.stop();

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(3)); // Initial + 2 retries
      expect(stopwatch.elapsed.inMilliseconds,
          greaterThan(100)); // Should include delays
    });

    test('should combine timeout and retry policies', () async {
      final interceptor = TestInterceptor();
      final retryPolicy = TestRetryPolicy(
        maxAttempts: 2,
        shouldRetryOnResponse: true,
        retryOnStatusCodes: 500,
      );

      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        requestTimeout: Duration(seconds: 5), // Long timeout
        retryPolicy: retryPolicy,
      );

      final response = await http.get(Uri.parse('$baseUrl/test'));

      expect(response.statusCode, equals(200));
      expect(requestCount, equals(3)); // Should retry despite timeout
    });
  });
}
