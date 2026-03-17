import 'package:http/http.dart';
import 'package:http_interceptor/src/retry/retry_executor.dart';
import 'package:http_interceptor/src/retry/retry_policy.dart';
import 'package:test/test.dart';

void main() {
  group('executeWithRetry', () {
    test(
      'returns response when policy says do not retry on response',
      () async {
        // arrange
        var attempts = 0;

        // act
        final result = await executeWithRetry(
          policy: _Policy(maxRetryAttempts: 2, onResponse: (_) => false),
          request: Request('GET', Uri.parse('https://example.com/')),
          attempt: () async {
            attempts++;
            return StreamedResponse(
              Stream.empty(),
              200,
              request: Request('GET', Uri.parse('https://example.com/')),
            );
          },
        );

        // assert
        expect(result.statusCode, 200);
        expect(attempts, 1);
      },
    );

    test(
      'retries when policy says retry on response until maxAttempts',
      () async {
        // arrange
        var attempts = 0;

        // act
        final result = await executeWithRetry(
          policy: _Policy(
            maxRetryAttempts: 2,
            onResponse: (r) => r.statusCode == 500,
          ),
          request: Request('GET', Uri.parse('https://example.com/')),
          attempt: () async {
            attempts++;
            if (attempts < 3) {
              return StreamedResponse(
                Stream.empty(),
                500,
                request: Request('GET', Uri.parse('https://example.com/')),
              );
            }
            return StreamedResponse(
              Stream.empty(),
              200,
              request: Request('GET', Uri.parse('https://example.com/')),
            );
          },
        );

        // assert
        expect(result.statusCode, 200);
        expect(attempts, 3);
      },
    );

    test('retries on exception when policy says so', () async {
      // arrange
      var attempts = 0;

      // act
      final result = await executeWithRetry(
        policy: _Policy(maxRetryAttempts: 2, onException: () => true),
        request: Request('GET', Uri.parse('https://example.com/')),
        attempt: () async {
          attempts++;
          if (attempts < 2) throw Exception('network');
          return StreamedResponse(
            Stream.empty(),
            200,
            request: Request('GET', Uri.parse('https://example.com/')),
          );
        },
      );

      // assert
      expect(result.statusCode, 200);
      expect(attempts, 2);
    });

    test('rethrows when policy says do not retry on exception', () async {
      // arrange
      var attempts = 0;

      // act
      Future<StreamedResponse> act() => executeWithRetry(
        policy: _Policy(maxRetryAttempts: 1, onException: () => false),
        request: Request('GET', Uri.parse('https://example.com/')),
        attempt: () async {
          attempts++;
          throw Exception('network');
        },
      );

      // assert
      expect(act, throwsA(isA<Exception>()));
      expect(attempts, 1);
    });
  });
}

class _Policy implements RetryPolicy {
  _Policy({
    required this.maxRetryAttempts,
    bool Function(BaseResponse)? onResponse,
    bool Function()? onException,
  }) : _onResponse = onResponse ?? ((_) => false),
       _onException = onException ?? (() => false);

  @override
  final int maxRetryAttempts;
  final bool Function(BaseResponse) _onResponse;
  final bool Function() _onException;

  @override
  bool shouldAttemptRetryOnException(Exception reason, BaseRequest request) =>
      _onException();

  @override
  bool shouldAttemptRetryOnResponse(BaseResponse response) =>
      _onResponse(response);

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) =>
      Duration.zero;

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) =>
      Duration.zero;
}
