import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  late RetryPolicy testObject;

  setUp(() {
    testObject = TestRetryPolicy();
  });

  group("maxRetryAttempts", () {
    test("defaults to 1", () {
      expect(testObject.maxRetryAttempts, 1);
    });

    test("can be overridden", () {
      testObject = TestRetryPolicy(
        maxRetryAttempts: 5,
      );

      expect(testObject.maxRetryAttempts, 5);
    });

    test("base class default is 1", () {
      // Arrange
      final policy = MinimalRetryPolicy();

      // Act & Assert
      expect(policy.maxRetryAttempts, 1);
    });
  });

  group("delayRetryAttemptOnException", () {
    test("returns no delay by default", () async {
      // Act
      final result = testObject.delayRetryAttemptOnException(retryAttempt: 0);

      // Assert
      expect(result, Duration.zero);
    });
  });

  group("delayRetryAttemptOnResponse", () {
    test("returns no delay by default", () async {
      // Act
      final result = testObject.delayRetryAttemptOnResponse(retryAttempt: 0);

      // Assert
      expect(result, Duration.zero);
    });
  });

  group("shouldAttemptRetryOnException", () {
    test("returns false by default", () async {
      expect(
          await testObject.shouldAttemptRetryOnException(
            Exception("Test Exception."),
            Request(
              'GET',
              Uri(),
            ),
          ),
          false);
    });
  });

  group("shouldAttemptRetryOnResponse", () {
    test("returns false by default", () async {
      expect(
        await testObject.shouldAttemptRetryOnResponse(
          Response('', 200),
        ),
        false,
      );
    });
  });
}

class TestRetryPolicy extends RetryPolicy {
  TestRetryPolicy({
    int maxRetryAttempts = 1,
  }) : internalMaxRetryAttempts = maxRetryAttempts;

  final int internalMaxRetryAttempts;

  @override
  int get maxRetryAttempts => internalMaxRetryAttempts;
}

/// A minimal implementation of RetryPolicy that doesn't override any methods
/// Used to test the default implementations in the base class
class MinimalRetryPolicy extends RetryPolicy {
  // No overrides - uses all default implementations
}
