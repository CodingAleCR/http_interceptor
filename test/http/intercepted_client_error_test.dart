import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('InterceptedClient error interception', () {
    late _MockInterceptor mockInterceptor;
    late InterceptedClient client;

    setUp(() {
      mockInterceptor = _MockInterceptor();
      client = InterceptedClient.build(interceptors: [mockInterceptor]);
    });

    test(
      'interceptors are called when an error occurs',
      () async {
        final request = Request('GET', Uri.parse('https://example.com'));
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        mockInterceptor.shouldInterceptErrorResult = true;

        // Call the internal _interceptError method indirectly
        // by creating a scenario where it would be called
        await _callInterceptError(
          client: client,
          request: request,
          error: error,
          stackTrace: stackTrace,
        );

        expect(mockInterceptor.interceptErrorCalled, true);
        expect(mockInterceptor.lastRequest, isNotNull);
        expect(mockInterceptor.lastError, isNotNull);
        expect(mockInterceptor.lastStackTrace, isNotNull);
      },
    );

    test(
      'interceptors are not called when shouldInterceptError returns false',
      () async {
        final request = Request('GET', Uri.parse('https://example.com'));
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        mockInterceptor.shouldInterceptErrorResult = false;

        await _callInterceptError(
          client: client,
          request: request,
          error: error,
          stackTrace: stackTrace,
        );

        expect(mockInterceptor.interceptErrorCalled, false);
      },
    );

    test('multiple interceptors are called when an error occurs', () async {
      final request = Request('GET', Uri.parse('https://example.com'));
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      final mockInterceptor2 = _MockInterceptor();

      client = InterceptedClient.build(
        interceptors: [mockInterceptor, mockInterceptor2],
      );

      mockInterceptor.shouldInterceptErrorResult = true;
      mockInterceptor2.shouldInterceptErrorResult = true;

      await _callInterceptError(
        client: client,
        request: request,
        error: error,
        stackTrace: stackTrace,
      );

      expect(mockInterceptor.interceptErrorCalled, true);
      expect(mockInterceptor2.interceptErrorCalled, true);
    });

    test('interceptors receive the correct parameters', () async {
      final request = Request('GET', Uri.parse('https://example.com'));
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      mockInterceptor.shouldInterceptErrorResult = true;

      await _callInterceptError(
        client: client,
        request: request,
        error: error,
        stackTrace: stackTrace,
      );

      expect(mockInterceptor.lastRequest, isNotNull);
      expect(mockInterceptor.lastError.toString(), contains('Test error'));
      expect(mockInterceptor.lastStackTrace, isNotNull);
    });
  });
}

/// Helper function to indirectly call the _interceptError method
/// by simulating a scenario where it would be called
Future<void> _callInterceptError({
  required InterceptedClient client,
  required BaseRequest request,
  required Exception error,
  required StackTrace stackTrace,
}) async {
  // Create a custom interceptor that will call the _interceptError method
  // when its interceptRequest method is called
  final errorTriggeringInterceptor = _ErrorTriggeringInterceptor(
    request: request,
    error: error,
    stackTrace: stackTrace,
  );

  // Add the interceptor to the client
  final clientWithErrorInterceptor = InterceptedClient.build(
    interceptors: [errorTriggeringInterceptor, ...client.interceptors],
  );

  // Make a request that will trigger the error
  try {
    await clientWithErrorInterceptor.send(request);
    fail('Expected an exception to be thrown');
  } catch (e) {
    // Exception expected
  }
}

/// Custom interceptor that throws a controlled exception during request interception
class _ErrorTriggeringInterceptor implements InterceptorContract {
  final BaseRequest request;
  final Exception error;
  final StackTrace stackTrace;

  const _ErrorTriggeringInterceptor({
    required this.request,
    required this.error,
    required this.stackTrace,
  });

  @override
  BaseRequest interceptRequest({required BaseRequest request}) => throw error;

  @override
  BaseResponse interceptResponse({required BaseResponse response}) => response;

  @override
  bool shouldInterceptRequest({required BaseRequest request}) => true;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) => false;

  @override
  bool shouldInterceptError({BaseRequest? request, BaseResponse? response}) =>
      false;

  @override
  void interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) {
    // Do nothing
  }
}

/// Mock interceptor for testing
class _MockInterceptor implements InterceptorContract {
  bool shouldInterceptErrorResult = true;
  bool interceptErrorCalled = false;

  BaseRequest? lastRequest;
  BaseResponse? lastResponse;
  Exception? lastError;
  StackTrace? lastStackTrace;

  @override
  BaseRequest interceptRequest({required BaseRequest request}) => request;

  @override
  BaseResponse interceptResponse({required BaseResponse response}) => response;

  @override
  bool shouldInterceptError({BaseRequest? request, BaseResponse? response}) =>
      shouldInterceptErrorResult;

  @override
  void interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) {
    interceptErrorCalled = true;
    lastRequest = request;
    lastResponse = response;
    lastError = error;
    lastStackTrace = stackTrace;
  }

  @override
  bool shouldInterceptRequest({required BaseRequest request}) => true;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) => true;
}
