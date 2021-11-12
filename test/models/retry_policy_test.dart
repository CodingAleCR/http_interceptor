import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:http_interceptor/http_interceptor.dart';

main() {
  late RetryPolicy testObject;

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
      expect(
          testObject
              .shouldAttemptRetryOnException(Exception("Test Exception.")),
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

class TestRetryPolicy extends RetryPolicy {}
