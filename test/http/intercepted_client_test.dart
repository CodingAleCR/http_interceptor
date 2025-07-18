import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

// Test interceptors for InterceptedClient testing
class TestInterceptor implements InterceptorContract {
  final List<String> log = [];
  final bool _shouldInterceptRequest;
  final bool _shouldInterceptResponse;
  final BaseRequest? requestModification;
  final BaseResponse? responseModification;

  TestInterceptor({
    bool shouldInterceptRequest = true,
    bool shouldInterceptResponse = true,
    this.requestModification,
    this.responseModification,
  })  : _shouldInterceptRequest = shouldInterceptRequest,
        _shouldInterceptResponse = shouldInterceptResponse;

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async {
    log.add('shouldInterceptRequest: ${request.method} ${request.url}');
    return _shouldInterceptRequest;
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    log.add('interceptRequest: ${request.method} ${request.url}');
    if (requestModification != null) {
      return requestModification!;
    }
    return request;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    log.add('shouldInterceptResponse: ${response.statusCode}');
    return _shouldInterceptResponse;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    log.add('interceptResponse: ${response.statusCode}');
    if (responseModification != null) {
      return responseModification!;
    }
    return response;
  }
}

class HeaderInterceptor implements InterceptorContract {
  final String headerName;
  final String headerValue;

  HeaderInterceptor(this.headerName, this.headerValue);

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async {
    return true;
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final modifiedRequest = request.copyWith();
    modifiedRequest.headers[headerName] = headerValue;
    return modifiedRequest;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    return true;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    return response;
  }
}

class ResponseModifierInterceptor implements InterceptorContract {
  final int statusCode;
  final String body;

  ResponseModifierInterceptor({this.statusCode = 200, this.body = 'modified'});

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async {
    return true;
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    return request;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    return true;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    return Response(body, statusCode);
  }
}

void main() {
  group('InterceptedClient', () {
    late HttpServer server;
    late String baseUrl;

    setUpAll(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://localhost:${server.port}';
      
      server.listen((HttpRequest request) {
        final response = request.response;
        response.headers.contentType = ContentType.json;
        
        // Convert headers to a map for JSON serialization
        final headersMap = <String, List<String>>{};
        request.headers.forEach((name, values) {
          headersMap[name] = values;
        });
        
        // Handle different request bodies
        String body = '';
        if (request.method == 'POST' || request.method == 'PUT' || request.method == 'PATCH') {
          body = request.uri.queryParameters['body'] ?? '';
        }
        
        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'headers': headersMap,
          'body': body,
          'contentLength': request.contentLength,
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    group('Basic HTTP Methods', () {
      test('should perform GET request with interceptors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
        expect(interceptor.log, contains('interceptRequest: GET $baseUrl/test'));
        expect(interceptor.log, contains('shouldInterceptResponse: 200'));
        expect(interceptor.log, contains('interceptResponse: 200'));
        
        client.close();
      });

      test('should perform POST request with interceptors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
        );
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        expect(interceptor.log, contains('interceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should perform PUT request with interceptors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.put(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
        );
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: PUT $baseUrl/test'));
        
        client.close();
      });

      test('should perform DELETE request with interceptors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.delete(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: DELETE $baseUrl/test'));
        
        client.close();
      });

      test('should perform PATCH request with interceptors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.patch(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
        );
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: PATCH $baseUrl/test'));
        
        client.close();
      });

      test('should perform HEAD request with interceptors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.head(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: HEAD $baseUrl/test'));
        
        client.close();
      });
    });

    group('Request Body Types', () {
      test('should handle string body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'simple string body',
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle JSON body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final jsonBody = jsonEncode({'key': 'value', 'number': 42});
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: jsonBody,
          headers: {'Content-Type': 'application/json'},
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle form data body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: {'field1': 'value1', 'field2': 'value2'},
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle bytes body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final bytes = utf8.encode('binary data');
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: bytes,
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle empty body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle large body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final largeBody = 'A' * 10000; // 10KB
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: largeBody,
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle binary body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final binaryData = List<int>.generate(1000, (i) => i % 256);
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: binaryData,
          headers: {'Content-Type': 'application/octet-stream'},
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle null body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: null,
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });
    });

    group('Request Headers', () {
      test('should handle custom headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(
          Uri.parse('$baseUrl/test'),
          headers: {
            'X-Custom-Header': 'custom-value',
            'Authorization': 'Bearer token123',
            'Accept': 'application/json',
          },
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['x-custom-header'], contains('custom-value'));
        expect(headers['authorization'], contains('Bearer token123'));
        expect(headers['accept'], contains('application/json'));
        
        client.close();
      });

      test('should handle content-type header', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
          headers: {'Content-Type': 'text/plain'},
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['content-type'], contains('text/plain; charset=utf-8'));
        
        client.close();
      });

      test('should handle multiple values for same header', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(
          Uri.parse('$baseUrl/test'),
          headers: {
            'Accept': 'application/json, text/plain, */*',
            'Cache-Control': 'no-cache, no-store',
          },
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['accept'], contains('application/json, text/plain, */*'));
        expect(headers['cache-control'], contains('no-cache, no-store'));
        
        client.close();
      });
    });

    group('Query Parameters', () {
      test('should handle query parameters', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(
          Uri.parse('$baseUrl/test'),
          params: {
            'param1': 'value1',
            'param2': 'value2',
            'number': '42',
            'bool': 'true',
          },
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['url'], contains('param1=value1'));
        expect(responseData['url'], contains('param2=value2'));
        expect(responseData['url'], contains('number=42'));
        expect(responseData['url'], contains('bool=true'));
        
        client.close();
      });

      test('should handle special characters in query parameters', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(
          Uri.parse('$baseUrl/test'),
          params: {
            'param with spaces': 'value with spaces',
            'param&with=special': 'value&with=special',
            'param+with+plus': 'value+with+plus',
          },
        );
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['url'], contains('param+with+spaces=value+with+spaces'));
        expect(responseData['url'], contains('param%26with%3Dspecial=value%26with%3Dspecial'));
        expect(responseData['url'], contains('param%2Bwith%2Bplus=value%2Bwith%2Bplus'));
        
        client.close();
      });
    });

    group('Response Handling', () {
      test('should read response body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final body = await client.read(Uri.parse('$baseUrl/test'));
        
        expect(body, isNotEmpty);
        expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
        
        client.close();
      });

      test('should read response bytes', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final bytes = await client.readBytes(Uri.parse('$baseUrl/test'));
        
        expect(bytes, isNotEmpty);
        expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
        
        client.close();
      });

      test('should handle response with custom status code', () async {
        final interceptor = ResponseModifierInterceptor(statusCode: 201, body: 'created');
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(201));
        expect(response.body, equals('created'));
        
        client.close();
      });

      test('should handle response with custom headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(response.headers['content-type'], contains('application/json'));
        
        client.close();
      });

      test('should handle different response types', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        // Test Response type
        final response1 = await client.get(Uri.parse('$baseUrl/test'));
        expect(response1, isA<Response>());
        
        // Test StreamedResponse type
        final request = Request('GET', Uri.parse('$baseUrl/test'));
        final response2 = await client.send(request);
        expect(response2, isA<StreamedResponse>());
        
        client.close();
      });

      test('should handle response with redirects', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(response.isRedirect, isFalse);
        
        client.close();
      });

      test('should handle response with content length', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(response.contentLength, isNotNull);
        
        client.close();
      });

      test('should handle response with reason phrase', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(response.reasonPhrase, isNotNull);
        
        client.close();
      });

      test('should handle response with persistent connection', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(response.persistentConnection, isNotNull);
        
        client.close();
      });
    });

    group('Streamed Requests', () {
      test('should handle streamed requests', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('POST', Uri.parse('$baseUrl/test'));
        request.body = 'streamed body';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle streamed requests with headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('POST', Uri.parse('$baseUrl/test'));
        request.headers['X-Custom-Header'] = 'streamed-value';
        request.body = 'streamed body with headers';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle streamed requests with bytes', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('POST', Uri.parse('$baseUrl/test'));
        request.bodyBytes = utf8.encode('binary streamed data');
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle StreamedRequest with data stream', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final streamController = StreamController<List<int>>();
        final streamedRequest = StreamedRequest('POST', Uri.parse('$baseUrl/test'));
        streamedRequest.headers['Content-Type'] = 'application/octet-stream';
        
        // Add data to the stream
        streamController.add(utf8.encode('streamed data part 1'));
        streamController.add(utf8.encode('streamed data part 2'));
        streamController.close();
        
        streamedRequest.sink.add(utf8.encode('streamed data part 1'));
        streamedRequest.sink.add(utf8.encode('streamed data part 2'));
        streamedRequest.sink.close();
        
        final response = await client.send(streamedRequest);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle StreamedRequest with large data', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final streamedRequest = StreamedRequest('POST', Uri.parse('$baseUrl/test'));
        streamedRequest.headers['Content-Type'] = 'text/plain';
        
        // Add large data in chunks
        final largeData = 'A' * 1024; // 1KB
        for (int i = 0; i < 10; i++) {
          streamedRequest.sink.add(utf8.encode(largeData));
        }
        streamedRequest.sink.close();
        
        final response = await client.send(streamedRequest);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle StreamedRequest with custom headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final streamedRequest = StreamedRequest('POST', Uri.parse('$baseUrl/test'));
        streamedRequest.headers['X-Custom-Header'] = 'streamed-custom-value';
        streamedRequest.headers['Authorization'] = 'Bearer streamed-token';
        streamedRequest.headers['Content-Type'] = 'application/json';
        
        streamedRequest.sink.add(utf8.encode('{"key": "value"}'));
        streamedRequest.sink.close();
        
        final response = await client.send(streamedRequest);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['x-custom-header'], contains('streamed-custom-value'));
        expect(headers['authorization'], contains('Bearer streamed-token'));
        
        client.close();
      });
    });

    group('Streamed Responses', () {
      test('should handle StreamedResponse', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('GET', Uri.parse('$baseUrl/test'));
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(response, isA<StreamedResponse>());
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('GET'));
        
        client.close();
      });

      test('should handle StreamedResponse with large data', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('GET', Uri.parse('$baseUrl/test'));
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(response, isA<StreamedResponse>());
        
        final responseBody = await response.stream.bytesToString();
        expect(responseBody, isNotEmpty);
        
        client.close();
      });

      test('should handle StreamedResponse with custom headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('GET', Uri.parse('$baseUrl/test'));
        request.headers['X-Request-Header'] = 'request-value';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(response, isA<StreamedResponse>());
        expect(response.headers['content-type'], contains('application/json'));
        
        client.close();
      });

      test('should handle StreamedResponse with different status codes', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('GET', Uri.parse('$baseUrl/test'));
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(response, isA<StreamedResponse>());
        
        client.close();
      });
    });

    group('Interceptor Chaining', () {
      test('should chain multiple interceptors correctly', () async {
        final interceptor1 = HeaderInterceptor('X-First', 'first-value');
        final interceptor2 = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor1, interceptor2]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        expect(interceptor2.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
        
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['x-first'], contains('first-value'));
        
        client.close();
      });

      test('should handle conditional interception', () async {
        final interceptor = TestInterceptor(
          shouldInterceptRequest: false,
          shouldInterceptResponse: false,
        );
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        await client.get(Uri.parse('$baseUrl/test'));
        
        expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
        expect(interceptor.log, contains('shouldInterceptResponse: 200'));
        expect(interceptor.log, isNot(contains('interceptRequest')));
        expect(interceptor.log, isNot(contains('interceptResponse')));
        
        client.close();
      });

      test('should handle request modification by interceptor', () async {
        final modifiedRequest = Request('POST', Uri.parse('$baseUrl/modified'));
        final interceptor = TestInterceptor(requestModification: modifiedRequest);
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(200));
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        expect(responseData['url'], contains('/modified'));
        
        client.close();
      });

      test('should handle response modification by interceptor', () async {
        final modifiedResponse = Response('modified body', 201);
        final interceptor = TestInterceptor(responseModification: modifiedResponse);
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.get(Uri.parse('$baseUrl/test'));
        
        expect(response.statusCode, equals(201));
        expect(response.body, equals('modified body'));
        
        client.close();
      });
    });

    group('Client Lifecycle', () {
      test('should handle client close', () {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(() => client.close(), returnsNormally);
      });

      test('should handle multiple close calls', () {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(() => client.close(), returnsNormally);
        expect(() => client.close(), returnsNormally);
      });

      test('should handle requests after close', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        client.close();
        
        expect(
          () => client.get(Uri.parse('$baseUrl/test')),
          throwsA(isA<ClientException>()),
        );
      });
    });

    group('Request Types and Edge Cases', () {
      test('should handle Request with custom headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('POST', Uri.parse('$baseUrl/test'));
        request.headers['X-Custom-Header'] = 'request-value';
        request.body = 'request body';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle Request with different HTTP methods', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
        
        for (final method in methods) {
          final request = Request(method, Uri.parse('$baseUrl/test'));
          final response = await client.send(request);
          
          expect(response.statusCode, equals(200));
          expect(interceptor.log, contains('shouldInterceptRequest: $method $baseUrl/test'));
        }
        
        client.close();
      });

      test('should handle Request with query parameters', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final uri = Uri.parse('$baseUrl/test').replace(queryParameters: {
          'param1': 'value1',
          'param2': 'value2',
        });
        
        final request = Request('GET', uri);
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test?param1=value1&param2=value2'));
        
        client.close();
      });

      test('should handle Request with empty body', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('POST', Uri.parse('$baseUrl/test'));
        // No body set
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle Request with large headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = Request('POST', Uri.parse('$baseUrl/test'));
        request.headers['X-Large-Header'] = 'A' * 1000; // Large header value
        request.body = 'test body';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        client.close();
      });

      test('should handle Request with special characters in URL', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final uri = Uri.parse('$baseUrl/test/path with spaces/param?key=value with spaces');
        final request = Request('GET', uri);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test/path%20with%20spaces/param?key=value%20with%20spaces'));
        
        client.close();
      });

      test('should handle Request with different content types', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final contentTypes = [
          'text/plain',
          'application/json',
          'application/xml',
          'application/octet-stream',
          'multipart/form-data',
        ];
        
        for (final contentType in contentTypes) {
          final request = Request('POST', Uri.parse('$baseUrl/test'));
          request.headers['Content-Type'] = contentType;
          request.body = 'test body';
          
          final response = await client.send(request);
          
          expect(response.statusCode, equals(200));
          expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        }
        
        client.close();
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(
          () => client.get(Uri.parse('http://invalid-host-that-does-not-exist.com')),
          throwsA(isA<Exception>()),
        );
        
        client.close();
      });

      test('should handle malformed URLs', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(
          () => client.get(Uri.parse('not-a-valid-url')),
          throwsA(isA<Exception>()),
        );
        
        client.close();
      });

      test('should handle invalid request bodies', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(
          () => client.post(
            Uri.parse('$baseUrl/test'),
            body: Object(), // Invalid body type
          ),
          throwsA(isA<ArgumentError>()),
        );
        
        client.close();
      });

      test('should handle timeout errors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(
          () => client.get(Uri.parse('http://10.255.255.1'), headers: {'Connection': 'close'}),
          throwsA(isA<Exception>()),
        );
        
        client.close();
      });

      test('should handle connection refused errors', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        expect(
          () => client.get(Uri.parse('http://localhost:9999')),
          throwsA(isA<Exception>()),
        );
        
        client.close();
      });
    });

    group('Encoding', () {
      test('should handle different encodings', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'test body with encoding',
          encoding: utf8,
        );
        
        expect(response.statusCode, equals(200));
        
        client.close();
      });

      test('should handle latin1 encoding', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'test body with latin1',
          encoding: latin1,
        );
        
        expect(response.statusCode, equals(200));
        
        client.close();
      });
    });

    group('Multipart Requests', () {
      test('should handle basic multipart request with fields', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['text_field'] = 'text value';
        request.fields['number_field'] = '42';
        request.fields['boolean_field'] = 'true';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with text files', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['description'] = 'File upload test';
        
        final textFile = MultipartFile.fromString(
          'text_file',
          'This is the content of the text file',
          filename: 'test.txt',
        );
        request.files.add(textFile);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with binary files', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['description'] = 'Binary file upload test';
        
        final binaryData = utf8.encode('Binary file content');
        final binaryFile = MultipartFile.fromBytes(
          'binary_file',
          binaryData,
          filename: 'test.bin',
          contentType: MediaType('application', 'octet-stream'),
        );
        request.files.add(binaryFile);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with multiple files', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['description'] = 'Multiple files upload test';
        
        // Add text file
        final textFile = MultipartFile.fromString(
          'text_file',
          'Text file content',
          filename: 'text.txt',
        );
        request.files.add(textFile);
        
        // Add binary file
        final binaryData = utf8.encode('Binary file content');
        final binaryFile = MultipartFile.fromBytes(
          'binary_file',
          binaryData,
          filename: 'binary.bin',
        );
        request.files.add(binaryFile);
        
        // Add JSON file
        final jsonFile = MultipartFile.fromString(
          'json_file',
          jsonEncode({'key': 'value', 'number': 42}),
          filename: 'data.json',
          contentType: MediaType('application', 'json'),
        );
        request.files.add(jsonFile);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with custom headers', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.headers['X-Custom-Header'] = 'multipart-value';
        request.headers['Authorization'] = 'Bearer multipart-token';
        request.fields['description'] = 'Multipart with custom headers';
        
        final textFile = MultipartFile.fromString(
          'file',
          'File content',
          filename: 'test.txt',
        );
        request.files.add(textFile);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['x-custom-header'], contains('multipart-value'));
        expect(headers['authorization'], contains('Bearer multipart-token'));
        
        client.close();
      });

      test('should handle multipart request with large files', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['description'] = 'Large file upload test';
        
        // Create a large text file (1KB)
        final largeContent = 'A' * 1024;
        final largeFile = MultipartFile.fromString(
          'large_file',
          largeContent,
          filename: 'large.txt',
        );
        request.files.add(largeFile);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with special characters in fields', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['field with spaces'] = 'value with spaces';
        request.fields['field&with=special'] = 'value&with=special';
        request.fields['field+with+plus'] = 'value+with+plus';
        request.fields['field_with_unicode'] = 'café 🚀 你好';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with files and no fields', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        
        final textFile = MultipartFile.fromString(
          'file1',
          'Content of file 1',
          filename: 'file1.txt',
        );
        request.files.add(textFile);
        
        final textFile2 = MultipartFile.fromString(
          'file2',
          'Content of file 2',
          filename: 'file2.txt',
        );
        request.files.add(textFile2);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with fields and no files', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['name'] = 'John Doe';
        request.fields['email'] = 'john@example.com';
        request.fields['age'] = '30';
        request.fields['active'] = 'true';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with empty fields and files', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with different content types', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['description'] = 'Different content types test';
        
        // Text file
        final textFile = MultipartFile.fromString(
          'text_file',
          'Text content',
          filename: 'text.txt',
          contentType: MediaType('text', 'plain'),
        );
        request.files.add(textFile);
        
        // JSON file
        final jsonFile = MultipartFile.fromString(
          'json_file',
          jsonEncode({'data': 'value'}),
          filename: 'data.json',
          contentType: MediaType('application', 'json'),
        );
        request.files.add(jsonFile);
        
        // XML file
        final xmlFile = MultipartFile.fromString(
          'xml_file',
          '<root><item>value</item></root>',
          filename: 'data.xml',
          contentType: MediaType('application', 'xml'),
        );
        request.files.add(xmlFile);
        
        // Binary file
        final binaryFile = MultipartFile.fromBytes(
          'binary_file',
          utf8.encode('Binary data'),
          filename: 'data.bin',
          contentType: MediaType('application', 'octet-stream'),
        );
        request.files.add(binaryFile);
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        
        client.close();
      });

      test('should handle multipart request with interceptor modification', () async {
        final modifiedRequest = MultipartRequest('PUT', Uri.parse('$baseUrl/modified'));
        modifiedRequest.fields['modified'] = 'true';
        
        final interceptor = TestInterceptor(requestModification: modifiedRequest);
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['original'] = 'true';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        
        final responseData = jsonDecode(await response.stream.bytesToString()) as Map<String, dynamic>;
        expect(responseData['method'], equals('PUT'));
        expect(responseData['url'], contains('/modified'));
        
        client.close();
      });

      test('should handle multipart request with conditional interception', () async {
        final interceptor = TestInterceptor(
          shouldInterceptRequest: false,
          shouldInterceptResponse: false,
        );
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final request = MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        request.fields['test'] = 'value';
        
        final response = await client.send(request);
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
        expect(interceptor.log, contains('shouldInterceptResponse: 200'));
        expect(interceptor.log, isNot(contains('interceptRequest')));
        expect(interceptor.log, isNot(contains('interceptResponse')));
        
        client.close();
      });
    });

    group('Complex Scenarios', () {
      test('should handle complex request with all features', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer complex-token',
            'X-Custom-Header': 'complex-value',
          },
          params: {
            'query1': 'value1',
            'query2': 'value2',
          },
          body: jsonEncode({
            'complex': 'data',
            'nested': {'key': 'value'},
            'array': [1, 2, 3],
          }),
        );
        
        expect(response.statusCode, equals(200));
        expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test?query1=value1&query2=value2'));
        
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));
        expect(responseData['url'], contains('query1=value1'));
        expect(responseData['url'], contains('query2=value2'));
        
        client.close();
      });

      test('should handle multiple requests with same client', () async {
        final interceptor = TestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);
        
        // First request
        final response1 = await client.get(Uri.parse('$baseUrl/test'));
        expect(response1.statusCode, equals(200));
        
        // Second request
        final response2 = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'second request',
        );
        expect(response2.statusCode, equals(200));
        
        // Third request
        final response3 = await client.put(
          Uri.parse('$baseUrl/test'),
          body: 'third request',
        );
        expect(response3.statusCode, equals(200));
        
        expect(interceptor.log.length, equals(12)); // 4 log entries per request
        
        client.close();
      });
    });
  });
} 