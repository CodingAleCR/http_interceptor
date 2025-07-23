import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('InterceptedHttp', () {
    late MockInterceptor mockInterceptor;
    late MockClient mockClient;
    late InterceptedHttp http;

    setUp(() {
      mockInterceptor = MockInterceptor();
      mockClient = MockClient();
      http = InterceptedHttp.build(
        interceptors: [mockInterceptor],
        client: mockClient,
      );
    });

    group('build factory method', () {
      test('creates instance with provided interceptors', () {
        // Arrange
        final interceptor1 = MockInterceptor();
        final interceptor2 = MockInterceptor();

        // Act
        final http = InterceptedHttp.build(
          interceptors: [interceptor1, interceptor2],
        );

        // Assert
        expect(http.interceptors, contains(interceptor1));
        expect(http.interceptors, contains(interceptor2));
        expect(http.interceptors.length, 2);
      });

      test('creates instance with provided timeout', () {
        // Arrange
        final timeout = Duration(seconds: 30);

        // Act
        final http = InterceptedHttp.build(
          interceptors: [mockInterceptor],
          requestTimeout: timeout,
        );

        // Assert
        expect(http.requestTimeout, equals(timeout));
      });

      test('creates instance with provided retry policy', () {
        // Arrange
        final retryPolicy = MockRetryPolicy();

        // Act
        final http = InterceptedHttp.build(
          interceptors: [mockInterceptor],
          retryPolicy: retryPolicy,
        );

        // Assert
        expect(http.retryPolicy, equals(retryPolicy));
      });

      test('creates instance with provided client', () {
        // Arrange & Act
        final http = InterceptedHttp.build(
          interceptors: [mockInterceptor],
          client: mockClient,
        );

        // Assert
        expect(http.client, equals(mockClient));
      });
    });

    group('HTTP methods', () {
      setUp(() {
        mockClient.response = Response('{"success": true}', 200);
      });

      test('GET method creates a new client and closes it after use', () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final headers = {'Authorization': 'Bearer token'};
        final params = {'query': 'test'};

        // Act
        await http.get(url, headers: headers, params: params);

        // Assert
        expect(mockClient.closeCalled, true);
        expect(mockClient.requestCount, 1);
        expect(mockClient.lastRequest?.method, 'GET');
        expect(mockClient.lastRequest?.url.toString(), contains('query=test'));
        expect(
            mockClient.lastRequest?.headers['Authorization'], 'Bearer token');
      });

      test('POST method creates a new client and closes it after use',
          () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final headers = {'Content-Type': 'application/json'};
        final body = '{"name": "test"}';

        // Act
        await http.post(url, headers: headers, body: body);

        // Assert
        expect(mockClient.closeCalled, true);
        expect(mockClient.requestCount, 1);
        expect(mockClient.lastRequest?.method, 'POST');
        expect(mockClient.lastRequest?.headers['Content-Type'],
            contains('application/json'));
      });

      test('PUT method creates a new client and closes it after use', () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final headers = {'Content-Type': 'application/json'};
        final body = '{"name": "test"}';

        // Act
        await http.put(url, headers: headers, body: body);

        // Assert
        expect(mockClient.closeCalled, true);
        expect(mockClient.requestCount, 1);
        expect(mockClient.lastRequest?.method, 'PUT');
        expect(mockClient.lastRequest?.headers['Content-Type'],
            contains('application/json'));
      });

      test('PATCH method creates a new client and closes it after use',
          () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final headers = {'Content-Type': 'application/json'};
        final body = '{"name": "test"}';

        // Act
        await http.patch(url, headers: headers, body: body);

        // Assert
        expect(mockClient.closeCalled, true);
        expect(mockClient.requestCount, 1);
        expect(mockClient.lastRequest?.method, 'PATCH');
        expect(mockClient.lastRequest?.headers['Content-Type'],
            contains('application/json'));
      });

      test('DELETE method creates a new client and closes it after use',
          () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final headers = {'Authorization': 'Bearer token'};

        // Act
        await http.delete(url, headers: headers);

        // Assert
        expect(mockClient.closeCalled, true);
        expect(mockClient.requestCount, 1);
        expect(mockClient.lastRequest?.method, 'DELETE');
        expect(
            mockClient.lastRequest?.headers['Authorization'], 'Bearer token');
      });

      test('HEAD method creates a new client and closes it after use',
          () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final headers = {'Authorization': 'Bearer token'};

        // Act
        await http.head(url, headers: headers);

        // Assert
        expect(mockClient.closeCalled, true);
        expect(mockClient.requestCount, 1);
        expect(mockClient.lastRequest?.method, 'HEAD');
        expect(
            mockClient.lastRequest?.headers['Authorization'], 'Bearer token');
      });

      test('read method returns response body as string', () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        mockClient.response = Response('response body', 200);

        // Act
        final result = await http.read(url);

        // Assert
        expect(result, 'response body');
        expect(mockClient.closeCalled, true);
      });

      test('readBytes method returns response body as bytes', () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        final bytes = utf8.encode('response body');
        // Create a response with the body text
        mockClient.response = Response('response body', 200);
        // Override the readBytes method to return our bytes
        mockClient.bytesToReturn = bytes;

        // Act
        final result = await http.readBytes(url);

        // Assert
        expect(result, bytes);
        expect(mockClient.closeCalled, true);
      });
    });

    group('error handling', () {
      test('client is closed even when request throws an exception', () async {
        // Arrange
        final url = Uri.parse('https://example.com');
        mockClient.shouldThrow = true;
        mockClient.exceptionToThrow = Exception('Network error');

        // Act & Assert
        await expectLater(
          () => http.get(url),
          throwsException,
        );
        expect(mockClient.closeCalled, true);
      });
    });

    test('_withClient creates a new client with the same parameters', () async {
      // Arrange
      final timeout = Duration(seconds: 30);
      final retryPolicy = MockRetryPolicy();
      StreamedResponse onTimeout() => StreamedResponse(Stream.value([]), 408);

      http = InterceptedHttp.build(
        interceptors: [mockInterceptor],
        client: mockClient,
        requestTimeout: timeout,
        retryPolicy: retryPolicy,
        onRequestTimeout: onTimeout,
      );

      // Act
      await http.get(Uri.parse('https://example.com'));

      // Assert
      // We can't directly check the internal client, but we can verify
      // the request was made with the mockClient
      expect(mockClient.requestCount, 1);
      expect(mockClient.closeCalled, true);
    });
  });
}

class MockInterceptor implements InterceptorContract {
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
    return true;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    return true;
  }

  @override
  Future<bool> shouldInterceptError({
    BaseRequest? request,
    BaseResponse? response,
  }) async {
    return true;
  }

  @override
  Future<void> interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) async {
    // Do nothing
  }
}

class MockClient implements Client {
  int requestCount = 0;
  bool closeCalled = false;
  bool shouldThrow = false;
  Exception exceptionToThrow = Exception('Test exception');
  Response response = Response('', 200);
  BaseRequest? lastRequest;
  Uint8List bytesToReturn = Uint8List(0);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    requestCount++;
    lastRequest = request;

    if (shouldThrow) {
      throw exceptionToThrow;
    }

    // Convert Response to StreamedResponse
    return StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      request: response.request,
    );
  }

  @override
  void close() {
    closeCalled = true;
  }

  // Implement required methods from Client interface
  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    return response;
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return response;
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return response;
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return response;
  }

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return response;
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) async {
    return response;
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    return bytesToReturn;
  }
}

class MockRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 1;
}
