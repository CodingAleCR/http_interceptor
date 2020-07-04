import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/http_interceptor.dart';

main() {
  RetryPolicy testObject;

  setUp(() {
    testObject = TestRetryPolicy();
  });

  group("maxRetryAttempts", () {
    test("defaults to 1", () {
      expect(testObject.maxRetryAttempts, 1);
    });
  });

  group("shouldAttemptRetryOnException", () {
    test("returns false by default", () {
      expect(testObject.shouldAttemptRetryOnException(null), false);
    });
  });

  group("shouldAttemptRetryOnResponse", () {
    test("returns false by default", () async {
      expect(await testObject.shouldAttemptRetryOnResponse(null), false);
    });
  });
}

class TestRetryPolicy extends RetryPolicy {}
