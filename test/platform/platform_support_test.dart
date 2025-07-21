import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

// Platform-specific test interceptors
class PlatformTestInterceptor implements InterceptorContract {
  final List<String> log = [];

  @override
  Future<bool> shouldInterceptRequest({required BaseRequest request}) async {
    log.add('shouldInterceptRequest: ${request.method} ${request.url}');
    return true;
  }

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    log.add('interceptRequest: ${request.method} ${request.url}');
    // Add platform-specific header
    final modifiedRequest = request.copyWith();
    modifiedRequest.headers['X-Platform'] = _getPlatformName();
    return modifiedRequest;
  }

  @override
  Future<bool> shouldInterceptResponse({required BaseResponse response}) async {
    log.add('shouldInterceptResponse: ${response.statusCode}');
    return true;
  }

  @override
  Future<BaseResponse> interceptResponse(
      {required BaseResponse response}) async {
    log.add('interceptResponse: ${response.statusCode}');
    return response;
  }

  String _getPlatformName() {
    // For testing purposes, we'll use a simple platform detection
    // In a real Flutter app, you would use kIsWeb and Platform.is*
    try {
      if (Platform.isAndroid) return 'android';
      if (Platform.isIOS) return 'ios';
      if (Platform.isWindows) return 'windows';
      if (Platform.isMacOS) return 'macos';
      if (Platform.isLinux) return 'linux';
      return 'unknown';
    } catch (e) {
      // If Platform.is* throws (e.g., on web), return 'web'
      return 'web';
    }
  }
}

void main() {
  group('Platform Support Tests', () {
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
          'platform': 'test',
        }));
        response.close();
      });
    });

    tearDownAll(() async {
      await server.close();
    });

    group('Cross-Platform HTTP Methods', () {
      test('should perform GET request on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.get(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: GET $baseUrl/test'));
        expect(
            interceptor.log, contains('interceptRequest: GET $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('GET'));

        client.close();
      });

      test('should perform POST request on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
        );

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: POST $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });

      test('should perform PUT request on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.put(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
        );

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: PUT $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('PUT'));

        client.close();
      });

      test('should perform DELETE request on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.delete(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: DELETE $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('DELETE'));

        client.close();
      });

      test('should perform PATCH request on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.patch(
          Uri.parse('$baseUrl/test'),
          body: 'test body',
        );

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: PATCH $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('PATCH'));

        client.close();
      });

      test('should perform HEAD request on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.head(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: HEAD $baseUrl/test'));

        client.close();
      });
    });

    group('Cross-Platform Request Types', () {
      test('should handle Request objects on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final request = Request('POST', Uri.parse('$baseUrl/test'));
        request.headers['X-Custom-Header'] = 'platform-test';
        request.body = 'request body';

        final response = await client.send(request);

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: POST $baseUrl/test'));

        final responseData = jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });

      test('should handle StreamedRequest on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final streamedRequest =
            StreamedRequest('POST', Uri.parse('$baseUrl/test'));
        streamedRequest.headers['Content-Type'] = 'application/octet-stream';
        streamedRequest.sink.add(utf8.encode('streamed data'));
        streamedRequest.sink.close();

        final response = await client.send(streamedRequest);

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: POST $baseUrl/test'));

        final responseData = jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });

      test('should handle MultipartRequest on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final multipartRequest =
            MultipartRequest('POST', Uri.parse('$baseUrl/test'));
        multipartRequest.fields['field1'] = 'value1';
        multipartRequest.fields['field2'] = 'value2';

        final textFile = MultipartFile.fromString(
          'text_file',
          'file content',
          filename: 'test.txt',
        );
        multipartRequest.files.add(textFile);

        final response = await client.send(multipartRequest);

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: POST $baseUrl/test'));

        final responseData = jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });
    });

    group('Cross-Platform Response Types', () {
      test('should handle Response objects on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.get(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(response, isA<Response>());

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('GET'));

        client.close();
      });

      test('should handle StreamedResponse on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final request = Request('GET', Uri.parse('$baseUrl/test'));
        final response = await client.send(request);

        expect(response.statusCode, equals(200));
        expect(response, isA<StreamedResponse>());

        final responseData = jsonDecode(await response.stream.bytesToString())
            as Map<String, dynamic>;
        expect(responseData['method'], equals('GET'));

        client.close();
      });
    });

    group('Cross-Platform Interceptor Functionality', () {
      test('should add platform-specific headers on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.get(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: GET $baseUrl/test'));
        expect(
            interceptor.log, contains('interceptRequest: GET $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final headers = responseData['headers'] as Map<String, dynamic>;
        expect(headers['x-platform'], isNotNull);

        client.close();
      });

      test('should handle multiple interceptors on all platforms', () async {
        final interceptor1 = PlatformTestInterceptor();
        final interceptor2 = PlatformTestInterceptor();
        final client =
            InterceptedClient.build(interceptors: [interceptor1, interceptor2]);

        final response = await client.get(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(interceptor1.log,
            contains('shouldInterceptRequest: GET $baseUrl/test'));
        expect(interceptor2.log,
            contains('shouldInterceptRequest: GET $baseUrl/test'));

        client.close();
      });

      test('should handle conditional interception on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        await client.get(Uri.parse('$baseUrl/test'));

        expect(interceptor.log,
            contains('shouldInterceptRequest: GET $baseUrl/test'));
        expect(
            interceptor.log, contains('interceptRequest: GET $baseUrl/test'));
        expect(interceptor.log, contains('shouldInterceptResponse: 200'));
        expect(interceptor.log, contains('interceptResponse: 200'));

        client.close();
      });
    });

    group('Cross-Platform Error Handling', () {
      test('should handle network errors on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        expect(
          () => client
              .get(Uri.parse('http://invalid-host-that-does-not-exist.com')),
          throwsA(isA<Exception>()),
        );

        client.close();
      });

      test('should handle malformed URLs on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        expect(
          () => client.get(Uri.parse('not-a-valid-url')),
          throwsA(isA<Exception>()),
        );

        client.close();
      });
    });

    group('Cross-Platform Data Types', () {
      test('should handle string data on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: 'string data',
        );

        expect(response.statusCode, equals(200));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });

      test('should handle JSON data on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final jsonData = jsonEncode({'key': 'value', 'number': 42});
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: jsonData,
          headers: {'Content-Type': 'application/json'},
        );

        expect(response.statusCode, equals(200));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });

      test('should handle binary data on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        final binaryData = utf8.encode('binary data');
        final response = await client.post(
          Uri.parse('$baseUrl/test'),
          body: binaryData,
        );

        expect(response.statusCode, equals(200));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('POST'));

        client.close();
      });

      test('should handle form data on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
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
    });

    group('Cross-Platform Client Lifecycle', () {
      test('should handle client lifecycle on all platforms', () {
        final interceptor = PlatformTestInterceptor();
        final client = InterceptedClient.build(interceptors: [interceptor]);

        expect(() => client.close(), returnsNormally);
      });

      test('should handle multiple client instances on all platforms', () {
        final interceptor = PlatformTestInterceptor();

        final client1 = InterceptedClient.build(interceptors: [interceptor]);
        final client2 = InterceptedClient.build(interceptors: [interceptor]);

        expect(() => client1.close(), returnsNormally);
        expect(() => client2.close(), returnsNormally);
      });
    });

    group('Cross-Platform InterceptedHttp', () {
      test('should work with InterceptedHttp on all platforms', () async {
        final interceptor = PlatformTestInterceptor();
        final http = InterceptedHttp.build(interceptors: [interceptor]);

        final response = await http.get(Uri.parse('$baseUrl/test'));

        expect(response.statusCode, equals(200));
        expect(interceptor.log,
            contains('shouldInterceptRequest: GET $baseUrl/test'));

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        expect(responseData['method'], equals('GET'));
      });

      test(
          'should handle all HTTP methods with InterceptedHttp on all platforms',
          () async {
        final interceptor = PlatformTestInterceptor();
        final http = InterceptedHttp.build(interceptors: [interceptor]);

        final methods = [
          () => http.get(Uri.parse('$baseUrl/test')),
          () => http.post(Uri.parse('$baseUrl/test'), body: 'test'),
          () => http.put(Uri.parse('$baseUrl/test'), body: 'test'),
          () => http.delete(Uri.parse('$baseUrl/test')),
          () => http.patch(Uri.parse('$baseUrl/test'), body: 'test'),
          () => http.head(Uri.parse('$baseUrl/test')),
        ];

        for (final method in methods) {
          final response = await method();
          expect(response.statusCode, equals(200));
        }
      });
    });
  });
}
