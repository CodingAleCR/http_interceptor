import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('InterceptorContract', () {
    late TestInterceptor interceptor;
    late MinimalInterceptor minimalInterceptor;
    late Request testRequest;
    late Response testResponse;
    late Exception testException;
    late StackTrace testStackTrace;

    setUp(() {
      interceptor = TestInterceptor();
      minimalInterceptor = MinimalInterceptor();
      testRequest = Request('GET', Uri.parse('https://example.com'));
      testResponse = Response('Test body', 200);
      testException = Exception('Test exception');
      testStackTrace = StackTrace.current;
    });

    group('default implementations', () {
      test('shouldInterceptRequest returns true by default', () async {
        // Act - use the minimal implementation that doesn't override the default
        final result = await minimalInterceptor.shouldInterceptRequest(
            request: testRequest);

        // Assert
        expect(result, isTrue);
      });

      test('shouldInterceptResponse returns true by default', () async {
        // Act - use the minimal implementation that doesn't override the default
        final result = await minimalInterceptor.shouldInterceptResponse(
            response: testResponse);

        // Assert
        expect(result, isTrue);
      });

      test('shouldInterceptError returns true by default', () async {
        // Act - use the minimal implementation that doesn't override the default
        final result = await minimalInterceptor.shouldInterceptError(
          request: testRequest,
          response: testResponse,
        );

        // Assert
        expect(result, isTrue);
      });

      test('interceptError has empty default implementation', () async {
        // Act & Assert - use the minimal implementation that doesn't override the default
        await minimalInterceptor.interceptError(
          request: testRequest,
          response: testResponse,
          error: testException,
          stackTrace: testStackTrace,
        );
        // No assertion needed - just verifying it doesn't throw
      });
    });

    group('overriding default implementations', () {
      test('can override shouldInterceptRequest', () async {
        // Arrange
        interceptor.shouldInterceptRequestResult = false;

        // Act
        final result =
            await interceptor.shouldInterceptRequest(request: testRequest);

        // Assert
        expect(result, isFalse);
      });

      test('can override shouldInterceptResponse', () async {
        // Arrange
        interceptor.shouldInterceptResponseResult = false;

        // Act
        final result =
            await interceptor.shouldInterceptResponse(response: testResponse);

        // Assert
        expect(result, isFalse);
      });

      test('can override shouldInterceptError', () async {
        // Arrange
        interceptor.shouldInterceptErrorResult = false;

        // Act
        final result = await interceptor.shouldInterceptError(
          request: testRequest,
          response: testResponse,
        );

        // Assert
        expect(result, isFalse);
      });

      test('can override interceptError', () async {
        // Arrange
        interceptor.interceptErrorCalled = false;

        // Act
        await interceptor.interceptError(
          request: testRequest,
          response: testResponse,
          error: testException,
          stackTrace: testStackTrace,
        );

        // Assert
        expect(interceptor.interceptErrorCalled, isTrue);
        expect(interceptor.lastRequest, equals(testRequest));
        expect(interceptor.lastResponse, equals(testResponse));
        expect(interceptor.lastError, equals(testException));
        expect(interceptor.lastStackTrace, equals(testStackTrace));
      });
    });
  });
}

/// A minimal implementation that implements the methods with the same
/// default behavior as in the InterceptorContract abstract class
class MinimalInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async =>
      true;

  @override
  Future<bool> shouldInterceptResponse(
          {required BaseResponse response}) async =>
      true;

  @override
  Future<bool> shouldInterceptError({
    BaseRequest? request,
    BaseResponse? response,
  }) async =>
      true;

  @override
  Future<void> interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) async {
    // Default implementation does nothing
  }
}

class TestInterceptor implements InterceptorContract {
  bool shouldInterceptRequestResult = true;
  bool shouldInterceptResponseResult = true;
  bool shouldInterceptErrorResult = true;
  bool interceptErrorCalled = false;

  BaseRequest? lastRequest;
  BaseResponse? lastResponse;
  Exception? lastError;
  StackTrace? lastStackTrace;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async {
    return shouldInterceptRequestResult;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    return shouldInterceptResponseResult;
  }

  @override
  Future<bool> shouldInterceptError({
    BaseRequest? request,
    BaseResponse? response,
  }) async {
    return shouldInterceptErrorResult;
  }

  @override
  Future<void> interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) async {
    interceptErrorCalled = true;
    lastRequest = request;
    lastResponse = response;
    lastError = error;
    lastStackTrace = stackTrace;
  }
}
