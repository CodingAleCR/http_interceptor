import 'dart:async';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'intercepted_client_test.mocks.dart';

@GenerateMocks([http.Client, InterceptorContract, RetryPolicy])
void main() {
  group('InterceptedClient', () {
    late MockClient mockClient;
    late MockInterceptorContract mockInterceptor;
    late MockRetryPolicy mockRetryPolicy;

    setUp(() {
      mockClient = MockClient();
      mockInterceptor = MockInterceptorContract();
      mockRetryPolicy = MockRetryPolicy();
    });

    group('Constructor', () {
      test('should create with default client when none provided', () {
        final client = InterceptedClient.build(interceptors: []);

        expect(client, isA<InterceptedClient>());
      });

      test('should create with provided client', () {
        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
        );

        expect(client, isA<InterceptedClient>());
      });

      test('should create with interceptors', () {
        final client = InterceptedClient.build(
          interceptors: [mockInterceptor],
        );

        expect(client, isA<InterceptedClient>());
      });

      test('should create with retry policy', () {
        final client = InterceptedClient.build(
          interceptors: [],
          retryPolicy: mockRetryPolicy,
        );

        expect(client, isA<InterceptedClient>());
      });
    });

    group('HTTP Methods', () {
      late InterceptedClient client;

      setUp(() {
        client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
        );
      });

      test('should call get method', () async {
        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.get(uri);

        expect(response.body, equals('response body'));
        expect(response.statusCode, equals(200));
        verify(mockClient.get(uri, headers: anyNamed('headers'))).called(1);
      });

      test('should call post method', () async {
        final uri = Uri.parse('https://example.com');
        const body = 'request body';
        final expectedResponse = http.Response('response body', 201);

        when(mockClient.post(uri,
                headers: anyNamed('headers'),
                body: anyNamed('body'),
                encoding: anyNamed('encoding')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.post(uri, body: body);

        expect(response.body, equals('response body'));
        expect(response.statusCode, equals(201));
        verify(mockClient.post(uri,
                headers: anyNamed('headers'),
                body: body,
                encoding: anyNamed('encoding')))
            .called(1);
      });

      test('should call put method', () async {
        final uri = Uri.parse('https://example.com');
        const body = 'request body';
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.put(uri,
                headers: anyNamed('headers'),
                body: anyNamed('body'),
                encoding: anyNamed('encoding')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.put(uri, body: body);

        expect(response.body, equals('response body'));
        expect(response.statusCode, equals(200));
        verify(mockClient.put(uri,
                headers: anyNamed('headers'),
                body: body,
                encoding: anyNamed('encoding')))
            .called(1);
      });

      test('should call patch method', () async {
        final uri = Uri.parse('https://example.com');
        const body = 'request body';
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.patch(uri,
                headers: anyNamed('headers'),
                body: anyNamed('body'),
                encoding: anyNamed('encoding')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.patch(uri, body: body);

        expect(response.body, equals('response body'));
        expect(response.statusCode, equals(200));
        verify(mockClient.patch(uri,
                headers: anyNamed('headers'),
                body: body,
                encoding: anyNamed('encoding')))
            .called(1);
      });

      test('should call delete method', () async {
        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('', 204);

        when(mockClient.delete(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.delete(uri);

        expect(response.body, equals(''));
        expect(response.statusCode, equals(204));
        verify(mockClient.delete(uri, headers: anyNamed('headers'))).called(1);
      });

      test('should call head method', () async {
        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('', 200);

        when(mockClient.head(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.head(uri);

        expect(response.body, equals(''));
        expect(response.statusCode, equals(200));
        verify(mockClient.head(uri, headers: anyNamed('headers'))).called(1);
      });

      test('should call send method', () async {
        final request = http.Request('GET', Uri.parse('https://example.com'));
        final expectedResponse = http.StreamedResponse(
          Stream.fromIterable([utf8.encode('response body')]),
          200,
        );

        when(mockClient.send(request))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.send(request);

        expect(response.statusCode, equals(200));
        verify(mockClient.send(request)).called(1);
      });
    });

    group('Interceptor Integration', () {
      test('should call interceptor shouldInterceptRequest', () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => true);
        when(mockInterceptor.interceptRequest(request: anyNamed('request')))
            .thenAnswer((_) async =>
                http.Request('GET', Uri.parse('https://example.com')));
        when(mockInterceptor.shouldInterceptResponse())
            .thenAnswer((_) async => false);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
        );

        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        await client.get(uri);

        verify(mockInterceptor.shouldInterceptRequest()).called(1);
        verify(mockInterceptor.interceptRequest(request: anyNamed('request')))
            .called(1);
      });

      test('should call interceptor shouldInterceptResponse', () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => false);
        when(mockInterceptor.shouldInterceptResponse())
            .thenAnswer((_) async => true);
        when(mockInterceptor.interceptResponse(response: anyNamed('response')))
            .thenAnswer(
                (_) async => http.Response('intercepted response', 200));

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
        );

        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('original response', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        final response = await client.get(uri);

        expect(response.body, equals('intercepted response'));
        verify(mockInterceptor.shouldInterceptResponse()).called(1);
        verify(mockInterceptor.interceptResponse(
                response: anyNamed('response')))
            .called(1);
      });

      test('should skip interceptor when shouldInterceptRequest returns false',
          () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => false);
        when(mockInterceptor.shouldInterceptResponse())
            .thenAnswer((_) async => false);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
        );

        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        await client.get(uri);

        verify(mockInterceptor.shouldInterceptRequest()).called(1);
        verifyNever(
            mockInterceptor.interceptRequest(request: anyNamed('request')));
      });

      test('should skip interceptor when shouldInterceptResponse returns false',
          () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => false);
        when(mockInterceptor.shouldInterceptResponse())
            .thenAnswer((_) async => false);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
        );

        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        await client.get(uri);

        verify(mockInterceptor.shouldInterceptResponse()).called(1);
        verifyNever(
            mockInterceptor.interceptResponse(response: anyNamed('response')));
      });
    });

    group('Retry Policy Integration', () {
      test('should retry on exception when policy allows', () async {
        when(mockRetryPolicy.maxRetryAttempts).thenReturn(2);
        when(mockRetryPolicy.shouldAttemptRetryOnException(any, any))
            .thenAnswer((_) async => true);
        when(mockRetryPolicy.delayRetryAttemptOnException(retryAttempt: anyNamed('retryAttempt')))
            .thenReturn(Duration.zero);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
          retryPolicy: mockRetryPolicy,
        );

        final uri = Uri.parse('https://example.com');

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'))
            .thenAnswer((_) async => http.Response('success', 200));

        final response = await client.get(uri);

        expect(response.body, equals('success'));
        expect(response.statusCode, equals(200));
        verify(mockClient.get(uri, headers: anyNamed('headers'))).called(2);
      });

      test('should retry on response when policy allows', () async {
        when(mockRetryPolicy.maxRetryAttempts).thenReturn(2);
        when(mockRetryPolicy.shouldAttemptRetryOnResponse(any))
            .thenAnswer((_) async => true);
        when(mockRetryPolicy.delayRetryAttemptOnResponse(retryAttempt: anyNamed('retryAttempt')))
            .thenReturn(Duration.zero);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
          retryPolicy: mockRetryPolicy,
        );

        final uri = Uri.parse('https://example.com');

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('error', 500))
            .thenAnswer((_) async => http.Response('success', 200));

        final response = await client.get(uri);

        expect(response.body, equals('success'));
        expect(response.statusCode, equals(200));
        verify(mockClient.get(uri, headers: anyNamed('headers'))).called(2);
      });

      test('should not retry when policy does not allow', () async {
        when(mockRetryPolicy.maxRetryAttempts).thenReturn(2);
        when(mockRetryPolicy.shouldAttemptRetryOnException(any, any))
            .thenAnswer((_) async => false);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
          retryPolicy: mockRetryPolicy,
        );

        final uri = Uri.parse('https://example.com');

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        expect(() => client.get(uri), throwsException);
        verify(mockClient.get(uri, headers: anyNamed('headers'))).called(1);
      });

      test('should respect max retry attempts', () async {
        when(mockRetryPolicy.maxRetryAttempts).thenReturn(1);
        when(mockRetryPolicy.shouldAttemptRetryOnException(any, any))
            .thenAnswer((_) async => true);
        when(mockRetryPolicy.delayRetryAttemptOnException(retryAttempt: anyNamed('retryAttempt')))
            .thenReturn(Duration.zero);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
          retryPolicy: mockRetryPolicy,
        );

        final uri = Uri.parse('https://example.com');

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        expect(() => client.get(uri), throwsException);
        verify(mockClient.get(uri, headers: anyNamed('headers')))
            .called(2); // Original + 1 retry
      });
    });

    group('Client Management', () {
      test('should close underlying client', () {
        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
        );

        client.close();

        verify(mockClient.close()).called(1);
      });

      test('should handle close when client is null', () {
        final client = InterceptedClient.build(interceptors: []);

        expect(() => client.close(), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('should handle interceptor exceptions gracefully', () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => true);
        when(mockInterceptor.interceptRequest(request: anyNamed('request')))
            .thenThrow(Exception('Interceptor error'));

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
        );

        final uri = Uri.parse('https://example.com');

        expect(() => client.get(uri), throwsException);
      });

      test('should handle response interceptor exceptions gracefully',
          () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => false);
        when(mockInterceptor.shouldInterceptResponse())
            .thenAnswer((_) async => true);
        when(mockInterceptor.interceptResponse(response: anyNamed('response')))
            .thenThrow(Exception('Response interceptor error'));

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
        );

        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        expect(() => client.get(uri), throwsException);
      });

      test('should handle retry policy exceptions gracefully', () async {
        when(mockRetryPolicy.maxRetryAttempts).thenReturn(2);
        when(mockRetryPolicy.shouldAttemptRetryOnException(any, any))
            .thenThrow(Exception('Retry policy error'));

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [],
          retryPolicy: mockRetryPolicy,
        );

        final uri = Uri.parse('https://example.com');

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        expect(() => client.get(uri), throwsException);
      });
    });

    group('Complex Scenarios', () {
      test('should handle multiple interceptors in order', () async {
        final interceptor1 = MockInterceptorContract();
        final interceptor2 = MockInterceptorContract();

        when(interceptor1.shouldInterceptRequest())
            .thenAnswer((_) async => true);
        when(interceptor1.interceptRequest(request: anyNamed('request')))
            .thenAnswer((invocation) async {
          final request =
              invocation.namedArguments[#request] as http.BaseRequest;
          request.headers['X-Interceptor-1'] = 'true';
          return request;
        });
        when(interceptor1.shouldInterceptResponse())
            .thenAnswer((_) async => false);

        when(interceptor2.shouldInterceptRequest())
            .thenAnswer((_) async => true);
        when(interceptor2.interceptRequest(request: anyNamed('request')))
            .thenAnswer((invocation) async {
          final request =
              invocation.namedArguments[#request] as http.BaseRequest;
          request.headers['X-Interceptor-2'] = 'true';
          return request;
        });
        when(interceptor2.shouldInterceptResponse())
            .thenAnswer((_) async => false);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [interceptor1, interceptor2],
        );

        final uri = Uri.parse('https://example.com');
        final expectedResponse = http.Response('response body', 200);

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenAnswer((_) async => expectedResponse);

        await client.get(uri);

        verify(interceptor1.interceptRequest(request: anyNamed('request')))
            .called(1);
        verify(interceptor2.interceptRequest(request: anyNamed('request')))
            .called(1);
      });

      test('should handle interceptors with retry policy', () async {
        when(mockInterceptor.shouldInterceptRequest())
            .thenAnswer((_) async => true);
        when(mockInterceptor.interceptRequest(request: anyNamed('request')))
            .thenAnswer((invocation) async =>
                invocation.namedArguments[#request] as http.BaseRequest);
        when(mockInterceptor.shouldInterceptResponse())
            .thenAnswer((_) async => false);

        when(mockRetryPolicy.maxRetryAttempts).thenReturn(2);
        when(mockRetryPolicy.shouldAttemptRetryOnException(any, any))
            .thenAnswer((_) async => true);
        when(mockRetryPolicy.delayRetryAttemptOnException(retryAttempt: anyNamed('retryAttempt')))
            .thenReturn(Duration.zero);

        final client = InterceptedClient.build(
          client: mockClient,
          interceptors: [mockInterceptor],
          retryPolicy: mockRetryPolicy,
        );

        final uri = Uri.parse('https://example.com');

        when(mockClient.get(uri, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'))
            .thenAnswer((_) async => http.Response('success', 200));

        final response = await client.get(uri);

        expect(response.body, equals('success'));
        verify(mockInterceptor.interceptRequest(request: anyNamed('request')))
            .called(2);
      });
    });
  });
}
