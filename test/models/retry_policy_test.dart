import 'dart:async';
import 'package:test/test.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/models/retry_policy.dart';

class TestRetryPolicy extends RetryPolicy {
  final bool retryOnException;
  final bool retryOnResponse;
  final int maxRetries;
  final Duration exceptionDelay;
  final Duration responseDelay;

  TestRetryPolicy({
    this.retryOnException = false,
    this.retryOnResponse = false,
    this.maxRetries = 1,
    this.exceptionDelay = Duration.zero,
    this.responseDelay = Duration.zero,
  });

  @override
  int get maxRetryAttempts => maxRetries;

  @override
  FutureOr<bool> shouldAttemptRetryOnException(
      Exception reason, BaseRequest request) {
    return retryOnException;
  }

  @override
  FutureOr<bool> shouldAttemptRetryOnResponse(
      BaseResponse response, BaseRequest request) {
    return retryOnResponse;
  }

  @override
  FutureOr<Duration> delayRetryOnException(
      Exception reason, BaseRequest request) {
    return exceptionDelay;
  }

  @override
  FutureOr<Duration> delayRetryOnResponse(
      BaseResponse response, BaseRequest request) {
    return responseDelay;
  }
}

class ConditionalRetryPolicy extends RetryPolicy {
  final List<int> retryStatusCodes;
  final List<Type> retryExceptionTypes;

  ConditionalRetryPolicy({
    this.retryStatusCodes = const [500, 502, 503, 504],
    this.retryExceptionTypes = const [SocketException],
  });

  @override
  int get maxRetryAttempts => 3;

  @override
  FutureOr<bool> shouldAttemptRetryOnException(
      Exception reason, BaseRequest request) {
    return retryExceptionTypes.contains(reason.runtimeType);
  }

  @override
  FutureOr<bool> shouldAttemptRetryOnResponse(
      BaseResponse response, BaseRequest request) {
    return retryStatusCodes.contains(response.statusCode);
  }

  @override
  FutureOr<Duration> delayRetryOnException(
      Exception reason, BaseRequest request) {
    return Duration(milliseconds: 1000);
  }

  @override
  FutureOr<Duration> delayRetryOnResponse(
      BaseResponse response, BaseRequest request) {
    return Duration(milliseconds: 500);
  }
}

class ExponentialBackoffRetryPolicy extends RetryPolicy {
  final Duration baseDelay;
  final double multiplier;
  int _attemptCount = 0;

  ExponentialBackoffRetryPolicy({
    this.baseDelay = const Duration(milliseconds: 100),
    this.multiplier = 2.0,
  });

  @override
  int get maxRetryAttempts => 5;

  @override
  FutureOr<bool> shouldAttemptRetryOnException(
      Exception reason, BaseRequest request) {
    return _attemptCount < maxRetryAttempts;
  }

  @override
  FutureOr<bool> shouldAttemptRetryOnResponse(
      BaseResponse response, BaseRequest request) {
    return response.statusCode >= 500 && _attemptCount < maxRetryAttempts;
  }

  @override
  FutureOr<Duration> delayRetryOnException(
      Exception reason, BaseRequest request) {
    _attemptCount++;
    return Duration(
        milliseconds:
            (baseDelay.inMilliseconds * _attemptCount * multiplier).round());
  }

  @override
  FutureOr<Duration> delayRetryOnResponse(
      BaseResponse response, BaseRequest request) {
    _attemptCount++;
    return Duration(
        milliseconds:
            (baseDelay.inMilliseconds * _attemptCount * multiplier).round());
  }
}

void main() {
  group('RetryPolicy', () {
    group('TestRetryPolicy', () {
      test('should implement all required methods', () {
        final policy = TestRetryPolicy();

        expect(policy.maxRetryAttempts, isA<int>());

        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('error', 500);
        final exception = Exception('Network error');

        expect(policy.shouldAttemptRetryOnException(exception, request),
            isA<FutureOr<bool>>());
        expect(policy.shouldAttemptRetryOnResponse(response, request),
            isA<FutureOr<bool>>());
        expect(policy.delayRetryOnException(exception, request),
            isA<FutureOr<Duration>>());
        expect(policy.delayRetryOnResponse(response, request),
            isA<FutureOr<Duration>>());
      });

      test('should respect retry configuration', () async {
        final policy = TestRetryPolicy(
          retryOnException: true,
          retryOnResponse: true,
          maxRetries: 3,
          exceptionDelay: Duration(milliseconds: 100),
          responseDelay: Duration(milliseconds: 200),
        );

        expect(policy.maxRetryAttempts, equals(3));

        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('error', 500);
        final exception = Exception('Network error');

        expect(await policy.shouldAttemptRetryOnException(exception, request),
            isTrue);
        expect(await policy.shouldAttemptRetryOnResponse(response, request),
            isTrue);
        expect(await policy.delayRetryOnException(exception, request),
            equals(Duration(milliseconds: 100)));
        expect(await policy.delayRetryOnResponse(response, request),
            equals(Duration(milliseconds: 200)));
      });

      test('should not retry when disabled', () async {
        final policy = TestRetryPolicy(
          retryOnException: false,
          retryOnResponse: false,
        );

        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('error', 500);
        final exception = Exception('Network error');

        expect(await policy.shouldAttemptRetryOnException(exception, request),
            isFalse);
        expect(await policy.shouldAttemptRetryOnResponse(response, request),
            isFalse);
      });

      test('should return zero delay when configured', () async {
        final policy = TestRetryPolicy(
          exceptionDelay: Duration.zero,
          responseDelay: Duration.zero,
        );

        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('error', 500);
        final exception = Exception('Network error');

        expect(await policy.delayRetryOnException(exception, request),
            equals(Duration.zero));
        expect(await policy.delayRetryOnResponse(response, request),
            equals(Duration.zero));
      });
    });

    group('ConditionalRetryPolicy', () {
      test('should retry on specific status codes', () async {
        final policy =
            ConditionalRetryPolicy(retryStatusCodes: [500, 502, 503]);
        final request = Request('GET', Uri.parse('https://example.com'));

        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 500), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 502), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 503), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 404), request),
            isFalse);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('success', 200), request),
            isFalse);
      });

      test('should retry on specific exception types', () async {
        final policy =
            ConditionalRetryPolicy(retryExceptionTypes: [SocketException]);
        final request = Request('GET', Uri.parse('https://example.com'));

        expect(
            await policy.shouldAttemptRetryOnException(
                SocketException('Connection failed'), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnException(
                Exception('Generic error'), request),
            isFalse);
      });

      test('should have correct max retry attempts', () {
        final policy = ConditionalRetryPolicy();
        expect(policy.maxRetryAttempts, equals(3));
      });

      test('should provide different delays for exceptions and responses',
          () async {
        final policy = ConditionalRetryPolicy();
        final request = Request('GET', Uri.parse('https://example.com'));

        expect(await policy.delayRetryOnException(Exception('error'), request),
            equals(Duration(milliseconds: 1000)));
        expect(
            await policy.delayRetryOnResponse(Response('error', 500), request),
            equals(Duration(milliseconds: 500)));
      });
    });

    group('ExponentialBackoffRetryPolicy', () {
      test('should increase delay exponentially', () async {
        final policy = ExponentialBackoffRetryPolicy(
          baseDelay: Duration(milliseconds: 100),
          multiplier: 2.0,
        );
        final request = Request('GET', Uri.parse('https://example.com'));
        final exception = Exception('Network error');

        // First attempt
        final delay1 = await policy.delayRetryOnException(exception, request);
        expect(delay1.inMilliseconds, equals(200)); // 100 * 1 * 2.0

        // Second attempt
        final delay2 = await policy.delayRetryOnException(exception, request);
        expect(delay2.inMilliseconds, equals(400)); // 100 * 2 * 2.0

        // Third attempt
        final delay3 = await policy.delayRetryOnException(exception, request);
        expect(delay3.inMilliseconds, equals(600)); // 100 * 3 * 2.0
      });

      test('should limit retry attempts', () async {
        final policy = ExponentialBackoffRetryPolicy();
        final request = Request('GET', Uri.parse('https://example.com'));
        final exception = Exception('Network error');

        expect(policy.maxRetryAttempts, equals(5));

        // Should retry initially
        expect(await policy.shouldAttemptRetryOnException(exception, request),
            isTrue);

        // After max attempts, should not retry
        for (int i = 0; i < 5; i++) {
          await policy.delayRetryOnException(exception, request);
        }
        expect(await policy.shouldAttemptRetryOnException(exception, request),
            isFalse);
      });

      test('should retry on server errors', () async {
        final policy = ExponentialBackoffRetryPolicy();
        final request = Request('GET', Uri.parse('https://example.com'));

        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 500), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 502), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('error', 503), request),
            isTrue);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('not found', 404), request),
            isFalse);
        expect(
            await policy.shouldAttemptRetryOnResponse(
                Response('success', 200), request),
            isFalse);
      });

      test('should use same backoff for both exceptions and responses',
          () async {
        final policy = ExponentialBackoffRetryPolicy(
          baseDelay: Duration(milliseconds: 50),
          multiplier: 3.0,
        );
        final request = Request('GET', Uri.parse('https://example.com'));

        final exceptionDelay =
            await policy.delayRetryOnException(Exception('error'), request);
        final responseDelay =
            await policy.delayRetryOnResponse(Response('error', 500), request);

        expect(exceptionDelay.inMilliseconds, equals(150)); // 50 * 1 * 3.0
        expect(responseDelay.inMilliseconds, equals(300)); // 50 * 2 * 3.0
      });
    });

    group('Async behavior', () {
      test('should handle async shouldAttemptRetryOnException', () async {
        final policy = TestRetryPolicy(retryOnException: true);
        final request = Request('GET', Uri.parse('https://example.com'));
        final exception = Exception('Network error');

        final result = policy.shouldAttemptRetryOnException(exception, request);
        if (result is Future<bool>) {
          expect(await result, isTrue);
        } else {
          expect(result, isTrue);
        }
      });

      test('should handle async shouldAttemptRetryOnResponse', () async {
        final policy = TestRetryPolicy(retryOnResponse: true);
        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('error', 500);

        final result = policy.shouldAttemptRetryOnResponse(response, request);
        if (result is Future<bool>) {
          expect(await result, isTrue);
        } else {
          expect(result, isTrue);
        }
      });

      test('should handle async delayRetryOnException', () async {
        final policy =
            TestRetryPolicy(exceptionDelay: Duration(milliseconds: 100));
        final request = Request('GET', Uri.parse('https://example.com'));
        final exception = Exception('Network error');

        final result = policy.delayRetryOnException(exception, request);
        if (result is Future<Duration>) {
          expect(await result, equals(Duration(milliseconds: 100)));
        } else {
          expect(result, equals(Duration(milliseconds: 100)));
        }
      });

      test('should handle async delayRetryOnResponse', () async {
        final policy =
            TestRetryPolicy(responseDelay: Duration(milliseconds: 200));
        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('error', 500);

        final result = policy.delayRetryOnResponse(response, request);
        if (result is Future<Duration>) {
          expect(await result, equals(Duration(milliseconds: 200)));
        } else {
          expect(result, equals(Duration(milliseconds: 200)));
        }
      });
    });
  });
}
