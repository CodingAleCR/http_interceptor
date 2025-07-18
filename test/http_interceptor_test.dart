import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

// Concrete implementation of RetryPolicy for testing
class TestRetryPolicy extends RetryPolicy {
  final int maxAttempts;
  
  TestRetryPolicy({this.maxAttempts = 1});
  
  @override
  int get maxRetryAttempts => maxAttempts;
}

// Test interceptors for testing
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
  group('InterceptedHttp', () {
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
        
        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'headers': headersMap,
          'body': request.uri.queryParameters['body'] ?? '',
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    test('should build with interceptors', () {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      expect(http.interceptors, equals([interceptor]));
      expect(http.requestTimeout, isNull);
      expect(http.onRequestTimeout, isNull);
      expect(http.retryPolicy, isNull);
      expect(http.client, isNull);
    });

    test('should build with all parameters', () {
      final interceptor = TestInterceptor();
      final timeout = Duration(seconds: 30);
      final retryPolicy = TestRetryPolicy(maxAttempts: 3);
      final client = Client();
      
      final http = InterceptedHttp.build(
        interceptors: [interceptor],
        requestTimeout: timeout,
        retryPolicy: retryPolicy,
        client: client,
      );
      
      expect(http.interceptors, equals([interceptor]));
      expect(http.requestTimeout, equals(timeout));
      expect(http.retryPolicy, equals(retryPolicy));
      expect(http.client, equals(client));
    });

    test('should perform GET request with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
      expect(interceptor.log, contains('interceptRequest: GET $baseUrl/test'));
      expect(interceptor.log, contains('shouldInterceptResponse: 200'));
      expect(interceptor.log, contains('interceptResponse: 200'));
    });

    test('should perform POST request with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.post(
        Uri.parse('$baseUrl/test'),
        body: 'test body',
      );
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
      expect(interceptor.log, contains('interceptRequest: POST $baseUrl/test'));
    });

    test('should perform PUT request with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.put(
        Uri.parse('$baseUrl/test'),
        body: 'test body',
      );
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: PUT $baseUrl/test'));
    });

    test('should perform DELETE request with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.delete(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: DELETE $baseUrl/test'));
    });

    test('should perform PATCH request with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.patch(
        Uri.parse('$baseUrl/test'),
        body: 'test body',
      );
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: PATCH $baseUrl/test'));
    });

    test('should perform HEAD request with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.head(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: HEAD $baseUrl/test'));
    });

    test('should read response body with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final body = await http.read(Uri.parse('$baseUrl/test'));
      
      expect(body, isNotEmpty);
      expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
      expect(interceptor.log, contains('interceptRequest: GET $baseUrl/test'));
    });

    test('should read response bytes with interceptors', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final bytes = await http.readBytes(Uri.parse('$baseUrl/test'));
      
      expect(bytes, isNotEmpty);
      expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
    });

    test('should apply multiple interceptors in order', () async {
      final interceptor1 = TestInterceptor();
      final interceptor2 = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor1, interceptor2]);
      
      await http.get(Uri.parse('$baseUrl/test'));
      
      expect(interceptor1.log.length, equals(interceptor2.log.length));
      expect(interceptor1.log.first, contains('shouldInterceptRequest'));
      expect(interceptor2.log.first, contains('shouldInterceptRequest'));
    });

    test('should handle request modification by interceptor', () async {
      final modifiedRequest = Request('POST', Uri.parse('$baseUrl/modified'));
      final interceptor = TestInterceptor(requestModification: modifiedRequest);
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      expect(responseData['method'], equals('POST'));
      expect(responseData['url'], contains('/modified'));
    });

    test('should handle response modification by interceptor', () async {
      final modifiedResponse = Response('modified body', 201);
      final interceptor = TestInterceptor(responseModification: modifiedResponse);
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(201));
      expect(response.body, equals('modified body'));
    });

    test('should handle conditional interception', () async {
      final interceptor = TestInterceptor(
        shouldInterceptRequest: false,
        shouldInterceptResponse: false,
      );
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      await http.get(Uri.parse('$baseUrl/test'));
      
      expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
      expect(interceptor.log, contains('shouldInterceptResponse: 200'));
      expect(interceptor.log, isNot(contains('interceptRequest')));
      expect(interceptor.log, isNot(contains('interceptResponse')));
    });
  });

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
        
        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'headers': headersMap,
          'body': request.uri.queryParameters['body'] ?? '',
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    test('should build with interceptors', () {
      final interceptor = TestInterceptor();
      final client = InterceptedClient.build(interceptors: [interceptor]);
      
      expect(client.interceptors, equals([interceptor]));
      expect(client.requestTimeout, isNull);
      expect(client.onRequestTimeout, isNull);
      expect(client.retryPolicy, isNull);
    });

    test('should perform GET request with interceptors', () async {
      final interceptor = TestInterceptor();
      final client = InterceptedClient.build(interceptors: [interceptor]);
      
      final response = await client.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
      expect(interceptor.log, contains('interceptRequest: GET $baseUrl/test'));
      
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
      
      client.close();
    });

    test('should handle request headers modification', () async {
      final interceptor = HeaderInterceptor('X-Custom-Header', 'custom-value');
      final client = InterceptedClient.build(interceptors: [interceptor]);
      
      final response = await client.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final headers = responseData['headers'] as Map<String, dynamic>;
      expect(headers['x-custom-header'], contains('custom-value'));
      
      client.close();
    });

    test('should handle response modification', () async {
      final interceptor = ResponseModifierInterceptor(statusCode: 201, body: 'modified');
      final client = InterceptedClient.build(interceptors: [interceptor]);
      
      final response = await client.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(201));
      expect(response.body, equals('modified'));
      
      client.close();
    });

    test('should handle streamed requests', () async {
      final interceptor = TestInterceptor();
      final client = InterceptedClient.build(interceptors: [interceptor]);
      
      final request = Request('POST', Uri.parse('$baseUrl/test'));
      final response = await client.send(request);
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
      
      client.close();
    });

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

    test('should handle client close', () {
      final interceptor = TestInterceptor();
      final client = InterceptedClient.build(interceptors: [interceptor]);
      
      expect(() => client.close(), returnsNormally);
    });
  });

  group('HttpInterceptorException', () {
    test('should create exception with message', () {
      final exception = HttpInterceptorException('Test error');
      
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), equals('Exception: Test error'));
    });

    test('should create exception without message', () {
      final exception = HttpInterceptorException();
      
      expect(exception.message, isNull);
      expect(exception.toString(), equals('Exception'));
    });

    test('should create exception with null message', () {
      final exception = HttpInterceptorException(null);
      
      expect(exception.message, isNull);
      expect(exception.toString(), equals('Exception'));
    });
  });

  group('Integration Tests', () {
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
        
        response.write(jsonEncode({
          'method': request.method,
          'url': request.uri.toString(),
          'headers': headersMap,
          'body': request.uri.queryParameters['body'] ?? '',
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    test('should chain multiple interceptors correctly', () async {
      final headerInterceptor = HeaderInterceptor('X-First', 'first-value');
      final testInterceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [headerInterceptor, testInterceptor]);
      
      final response = await http.get(Uri.parse('$baseUrl/test'));
      
      expect(response.statusCode, equals(200));
      expect(testInterceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test'));
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final headers = responseData['headers'] as Map<String, dynamic>;
      expect(headers['x-first'], contains('first-value'));
    });

    test('should handle complex request with body and headers', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.post(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'key': 'value'}),
      );
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: POST $baseUrl/test'));
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      expect(responseData['method'], equals('POST'));
    });

    test('should handle request with query parameters', () async {
      final interceptor = TestInterceptor();
      final http = InterceptedHttp.build(interceptors: [interceptor]);
      
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        params: {'param1': 'value1', 'param2': 'value2'},
      );
      
      expect(response.statusCode, equals(200));
      expect(interceptor.log, contains('shouldInterceptRequest: GET $baseUrl/test?param1=value1&param2=value2'));
      
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      expect(responseData['url'], contains('param1=value1'));
      expect(responseData['url'], contains('param2=value2'));
    });
  });
}
