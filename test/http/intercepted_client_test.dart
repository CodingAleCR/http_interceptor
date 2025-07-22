import 'dart:async';
import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('InterceptedClient', () {
    late _MockClient mockClient;
    late _MockInterceptor mockInterceptor;
    late InterceptedClient client;

    setUp(() {
      mockClient = _MockClient();
      mockInterceptor = _MockInterceptor();
      client = InterceptedClient.build(
        interceptors: [mockInterceptor],
        client: mockClient,
      );
    });

    group('build factory method', () {
      test('creates instance with provided interceptors', () {
        final interceptor1 = _MockInterceptor();
        final interceptor2 = _MockInterceptor();

        final client = InterceptedClient.build(
          interceptors: [interceptor1, interceptor2],
        );

        expect(client.interceptors, contains(interceptor1));
        expect(client.interceptors, contains(interceptor2));
        expect(client.interceptors.length, 2);
      });

      test('creates instance with provided timeout', () {
        final timeout = Duration(seconds: 30);

        final client = InterceptedClient.build(
          interceptors: [mockInterceptor],
          requestTimeout: timeout,
        );

        expect(client.requestTimeout, equals(timeout));
      });

      test('creates instance with provided retry policy', () {
        final retryPolicy = _MockRetryPolicy();

        final client = InterceptedClient.build(
          interceptors: [mockInterceptor],
          retryPolicy: retryPolicy,
        );

        expect(client.retryPolicy, equals(retryPolicy));
      });

      test('creates instance with provided client', () async {
        final client = InterceptedClient.build(
          interceptors: [mockInterceptor],
          client: mockClient,
        );

        // We can't directly check _inner as it's private,
        // but we can verify it's used by making a request
        await client.get(Uri.parse('https://example.com'));
        expect(mockClient.requestCount, 1);
      });
    });

    group('HTTP methods', () {
      setUp(() {
        mockClient._responseBody = utf8.encode('{"success": true}');
        mockClient._responseStatusCode = 200;
        mockClient._responseHeaders = {'content-type': 'application/json'};
      });

      test('GET method sends correct request', () async {
        final url = Uri.parse('https://example.com');
        final headers = {'Authorization': 'Bearer token'};
        final params = {'query': 'test'};

        await client.get(url, headers: headers, params: params);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://example.com?query=test');
        expect(request.headers['Authorization'], 'Bearer token');
      });

      test('POST method sends correct request with string body', () async {
        final url = Uri.parse('https://example.com');
        final headers = {'Content-Type': 'application/json'};
        final body = '{"name": "test"}';

        await client.post(url, headers: headers, body: body);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://example.com');
        expect(request.headers['Content-Type'], contains('application/json'));

        // Verify the body was set correctly in our mock client
        expect(mockClient.lastRequestBody, '{"name": "test"}');
      });

      test('POST method sends correct request with map body', () async {
        final url = Uri.parse('https://example.com');
        final body = {'name': 'test'};

        await client.post(url, body: body);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://example.com');
        expect(mockClient.lastRequestFields, {'name': 'test'});
      });

      test('PUT method sends correct request', () async {
        final url = Uri.parse('https://example.com');
        final headers = {'Content-Type': 'application/json'};
        final body = '{"name": "test"}';

        await client.put(url, headers: headers, body: body);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'PUT');
        expect(request.url.toString(), 'https://example.com');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(mockClient.lastRequestBody, '{"name": "test"}');
      });

      test('PATCH method sends correct request', () async {
        final url = Uri.parse('https://example.com');
        final headers = {'Content-Type': 'application/json'};
        final body = '{"name": "test"}';

        await client.patch(url, headers: headers, body: body);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'PATCH');
        expect(request.url.toString(), 'https://example.com');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(mockClient.lastRequestBody, '{"name": "test"}');
      });

      test('DELETE method sends correct request', () async {
        final url = Uri.parse('https://example.com');
        final headers = {'Authorization': 'Bearer token'};

        await client.delete(url, headers: headers);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'DELETE');
        expect(request.url.toString(), 'https://example.com');
        expect(request.headers['Authorization'], 'Bearer token');
      });

      test('HEAD method sends correct request', () async {
        final url = Uri.parse('https://example.com');
        final headers = {'Authorization': 'Bearer token'};

        await client.head(url, headers: headers);

        expect(mockClient.requests.length, 1);
        final request = mockClient.requests.first;
        expect(request.method, 'HEAD');
        expect(request.url.toString(), 'https://example.com');
        expect(request.headers['Authorization'], 'Bearer token');
      });

      test('read method returns response body as string', () async {
        final url = Uri.parse('https://example.com');

        // Set up the response with the expected body
        mockClient._responseBody = utf8.encode('response body');
        mockClient._responseStatusCode = 200;

        final result = await client.read(url);

        expect(result, 'response body');
      });

      test('readBytes method returns response body as bytes', () async {
        final url = Uri.parse('https://example.com');
        final bytes = utf8.encode('response body');

        // Set up the response with the expected body
        mockClient._responseBody = bytes;
        mockClient._responseStatusCode = 200;

        final result = await client.readBytes(url);

        expect(result, bytes);
      });

      test('read method throws exception for error response', () async {
        final url = Uri.parse('https://example.com');
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('error')),
          404,
          reasonPhrase: 'Not Found',
        );

        expect(
          () => client.read(url),
          throwsA(isA<ClientException>()),
        );
      });

      test('send method returns StreamedResponse', () async {
        final request = Request('GET', Uri.parse('https://example.com'));
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('response body')),
          200,
        );

        final response = await client.send(request);

        expect(response, isA<StreamedResponse>());
        expect(response.statusCode, 200);
      });
    });

    group('request interception', () {
      setUp(() {
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('{"success": true}')),
          200,
        );
      });

      test('interceptors are called for requests', () async {
        final url = Uri.parse('https://example.com');
        mockInterceptor.shouldInterceptRequestResult = true;

        await client.get(url);

        expect(mockInterceptor.interceptRequestCalled, true);
      });

      test(
        'interceptors are not called when shouldInterceptRequest returns false',
        () async {
          final url = Uri.parse('https://example.com');
          mockInterceptor.shouldInterceptRequestResult = false;

          await client.get(url);

          expect(mockInterceptor.interceptRequestCalled, false);
        },
      );

      test('multiple interceptors are called in order', () async {
        final url = Uri.parse('https://example.com');
        final interceptor1 = _OrderTrackingInterceptor(1);
        final interceptor2 = _OrderTrackingInterceptor(2);

        client = InterceptedClient.build(
          interceptors: [interceptor1, interceptor2],
          client: mockClient,
        );

        await client.get(url);

        expect(_OrderTrackingInterceptor.callOrder, [1, 2]);
      });

      test('request modifications are applied', () async {
        final url = Uri.parse('https://example.com');
        mockInterceptor.requestModification = (request) {
          request.headers['X-Modified'] = 'true';
          return request;
        };

        await client.get(url);

        expect(mockClient.requests.first.headers['X-Modified'], 'true');
      });
    });

    group('response interception', () {
      setUp(() {
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('{"success": true}')),
          200,
        );
      });

      test('interceptors are called for responses', () async {
        final url = Uri.parse('https://example.com');
        mockInterceptor.shouldInterceptResponseResult = true;

        await client.get(url);

        expect(mockInterceptor.interceptResponseCalled, true);
      });

      test(
        'interceptors are not called when shouldInterceptResponse returns false',
        () async {
          final url = Uri.parse('https://example.com');
          mockInterceptor.shouldInterceptResponseResult = false;

          await client.get(url);

          expect(mockInterceptor.interceptResponseCalled, false);
        },
      );

      test('multiple interceptors are called in order for responses', () async {
        final url = Uri.parse('https://example.com');
        final interceptor1 = _OrderTrackingInterceptor(1);
        final interceptor2 = _OrderTrackingInterceptor(2);

        // Clear both tracking lists
        _OrderTrackingInterceptor.callOrder.clear();
        _OrderTrackingInterceptor.responseCallOrder.clear();

        client = InterceptedClient.build(
          interceptors: [interceptor1, interceptor2],
          client: mockClient,
        );

        await client.get(url);

        expect(_OrderTrackingInterceptor.responseCallOrder, [1, 2]);
      });

      test('response modifications are applied', () async {
        final url = Uri.parse('https://example.com');
        mockInterceptor.responseModification = (response) {
          return Response('modified body', 200);
        };

        final response = await client.get(url);

        expect(response.body, 'modified body');
      });
    });

    group('retry policy', () {
      late _MockRetryPolicy retryPolicy;

      setUp(() {
        retryPolicy = _MockRetryPolicy();
        client = InterceptedClient.build(
          interceptors: [mockInterceptor],
          client: mockClient,
          retryPolicy: retryPolicy,
        );
      });

      test('retries on response when policy allows', () async {
        final url = Uri.parse('https://example.com');
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('error')),
          500,
        );

        retryPolicy.shouldRetryOnResponse = true;
        retryPolicy.maxRetryAttempts = 1;

        await client.get(url);

        expect(mockClient.requestCount, 2); // Original + 1 retry
      });

      test('retries on exception when policy allows', () async {
        final url = Uri.parse('https://example.com');
        mockClient.shouldThrow = true;
        mockClient.exceptionToThrow = Exception('Network error');

        retryPolicy.shouldRetryOnException = true;
        retryPolicy.maxRetryAttempts = 1;

        await expectLater(
          () => client.get(url),
          throwsException,
        );

        expect(mockClient.requestCount, 2); // Original + 1 retry
      });

      test('respects max retry attempts', () async {
        final url = Uri.parse('https://example.com');
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('error')),
          500,
        );

        retryPolicy.shouldRetryOnResponse = true;
        retryPolicy.maxRetryAttempts = 3;

        await client.get(url);

        expect(mockClient.requestCount, 4); // Original + 3 retries
      });

      test('uses delay from retry policy', () async {
        final url = Uri.parse('https://example.com');
        mockClient.response = StreamedResponse(
          Stream.value(utf8.encode('error')),
          500,
        );

        retryPolicy.shouldRetryOnResponse = true;
        retryPolicy.maxRetryAttempts = 1;
        retryPolicy.delay = Duration(milliseconds: 100);

        final stopwatch = Stopwatch()..start();
        await client.get(url);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('timeout handling', () {
      setUp(() {
        client = InterceptedClient.build(
          interceptors: [mockInterceptor],
          client: mockClient,
          requestTimeout: Duration(milliseconds: 100),
        );
      });

      test('throws exception on timeout when no callback provided', () async {
        final url = Uri.parse('https://example.com');
        mockClient.delayResponse = Duration(milliseconds: 200);

        expect(
          () => client.get(url),
          throwsA(isA<Exception>()),
        );
      });

      test('uses timeout callback when provided', () async {
        final url = Uri.parse('https://example.com');
        mockClient.delayResponse = Duration(milliseconds: 200);

        bool callbackCalled = false;
        client = InterceptedClient.build(
          interceptors: [mockInterceptor],
          client: mockClient,
          requestTimeout: Duration(milliseconds: 100),
          onRequestTimeout: () {
            callbackCalled = true;
            return StreamedResponse(
              Stream.value(utf8.encode('timeout response')),
              408,
            );
          },
        );

        final response = await client.get(url);

        expect(callbackCalled, true);
        expect(response.statusCode, 408);
        expect(response.body, 'timeout response');
      });
    });

    test('close method closes the inner client', () {
      client.close();

      expect(mockClient.closeCalled, true);
    });
  });
}

class _MockClient extends BaseClient {
  final List<BaseRequest> requests = [];
  int requestCount = 0;
  int _responseStatusCode = 200;
  Map<String, String> _responseHeaders = {};
  List<int> _responseBody = [];
  Duration? delayResponse;
  bool shouldThrow = false;
  Exception exceptionToThrow = Exception('Test exception');
  bool closeCalled = false;
  String? lastRequestBody;
  Map<String, String>? lastRequestFields;

  StreamedResponse get response => StreamedResponse(
        Stream.value(_responseBody),
        _responseStatusCode,
        headers: _responseHeaders,
      );

  set response(StreamedResponse resp) {
    _responseStatusCode = resp.statusCode;
    _responseHeaders = resp.headers;
    // Capture the body bytes
    resp.stream.toBytes().then((bytes) {
      _responseBody = bytes;
    });
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    requests.add(request);
    requestCount++;

    // Capture the request body if available
    if (request is Request) {
      lastRequestBody = request.body;

      // For form fields - only access if content type is appropriate
      if (request.headers['content-type']
              ?.contains('application/x-www-form-urlencoded') ??
          false) {
        try {
          lastRequestFields = request.bodyFields;
        } catch (e) {
          // Ignore errors accessing bodyFields
        }
      }
    }

    if (delayResponse != null) {
      await Future.delayed(delayResponse!);
    }

    if (shouldThrow) {
      throw exceptionToThrow;
    }

    return response;
  }

  @override
  void close() {
    closeCalled = true;
    super.close();
  }
}

class _MockInterceptor implements InterceptorContract {
  bool shouldInterceptRequestResult = true;
  bool shouldInterceptResponseResult = true;
  bool interceptRequestCalled = false;
  bool interceptResponseCalled = false;

  Function(BaseRequest)? requestModification;
  Function(BaseResponse)? responseModification;

  @override
  BaseRequest interceptRequest({required BaseRequest request}) {
    interceptRequestCalled = true;

    return requestModification?.call(request) ?? request;
  }

  @override
  BaseResponse interceptResponse({required BaseResponse response}) {
    interceptResponseCalled = true;

    return responseModification?.call(response) ?? response;
  }

  @override
  bool shouldInterceptRequest({required BaseRequest request}) =>
      shouldInterceptRequestResult;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) =>
      shouldInterceptResponseResult;

  @override
  bool shouldInterceptError({BaseRequest? request, BaseResponse? response}) =>
      true;

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

class _OrderTrackingInterceptor implements InterceptorContract {
  static List<int> callOrder = [];
  static List<int> responseCallOrder = [];

  final int order;

  _OrderTrackingInterceptor(this.order);

  @override
  BaseRequest interceptRequest({required BaseRequest request}) {
    callOrder.add(order);
    return request;
  }

  @override
  BaseResponse interceptResponse({required BaseResponse response}) {
    responseCallOrder.add(order);
    return response;
  }

  @override
  bool shouldInterceptRequest({required BaseRequest request}) => true;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) => true;

  @override
  bool shouldInterceptError({BaseRequest? request, BaseResponse? response}) =>
      true;

  @override
  void interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) async {
    // Do nothing
  }
}

class _MockRetryPolicy extends RetryPolicy {
  bool shouldRetryOnResponse = false;
  bool shouldRetryOnException = false;
  int _maxRetryAttempts = 1;
  Duration delay = Duration.zero;

  @override
  int get maxRetryAttempts => _maxRetryAttempts;

  // Add setter for maxRetryAttempts
  set maxRetryAttempts(int value) {
    _maxRetryAttempts = value;
  }

  @override
  bool shouldAttemptRetryOnResponse(BaseResponse response) =>
      shouldRetryOnResponse;

  @override
  bool shouldAttemptRetryOnException(
    Exception exception,
    BaseRequest request,
  ) =>
      shouldRetryOnException;

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) => delay;

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) => delay;
}
