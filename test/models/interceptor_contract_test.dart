import 'dart:async';
import 'package:test/test.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/models/interceptor_contract.dart';

class TestInterceptor implements InterceptorContract {
  bool shouldInterceptRequestValue;
  bool shouldInterceptResponseValue;
  BaseRequest? lastRequest;
  BaseResponse? lastResponse;
  
  TestInterceptor({
    this.shouldInterceptRequestValue = true,
    this.shouldInterceptResponseValue = true,
  });

  @override
  FutureOr<bool> shouldInterceptRequest() => shouldInterceptRequestValue;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    lastRequest = request;
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() => shouldInterceptResponseValue;

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    lastResponse = response;
    return response;
  }
}

class ConditionalInterceptor implements InterceptorContract {
  final bool shouldInterceptReq;
  final bool shouldInterceptResp;
  
  ConditionalInterceptor({
    this.shouldInterceptReq = true,
    this.shouldInterceptResp = true,
  });

  @override
  FutureOr<bool> shouldInterceptRequest() => shouldInterceptReq;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() => shouldInterceptResp;

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    return response;
  }
}

class ModifyingInterceptor implements InterceptorContract {
  final Map<String, String> headersToAdd;
  final String? bodyPrefix;
  
  ModifyingInterceptor({
    this.headersToAdd = const {},
    this.bodyPrefix,
  });

  @override
  FutureOr<bool> shouldInterceptRequest() => true;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    headersToAdd.forEach((key, value) {
      request.headers[key] = value;
    });
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() => bodyPrefix != null;

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    if (bodyPrefix != null && response is Response) {
      final modifiedBody = '$bodyPrefix${response.body}';
      return Response(modifiedBody, response.statusCode, 
        headers: response.headers, 
        request: response.request);
    }
    return response;
  }
}

void main() {
  group('InterceptorContract', () {
    group('TestInterceptor', () {
      test('should implement all required methods', () {
        final interceptor = TestInterceptor();
        
        expect(interceptor.shouldInterceptRequest(), isA<FutureOr<bool>>());
        expect(interceptor.shouldInterceptResponse(), isA<FutureOr<bool>>());
        
        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('test', 200);
        
        expect(interceptor.interceptRequest(request: request), isA<FutureOr<BaseRequest>>());
        expect(interceptor.interceptResponse(response: response), isA<FutureOr<BaseResponse>>());
      });

      test('should track last request and response', () async {
        final interceptor = TestInterceptor();
        final request = Request('GET', Uri.parse('https://example.com'));
        final response = Response('test', 200);
        
        expect(interceptor.lastRequest, isNull);
        expect(interceptor.lastResponse, isNull);
        
        await interceptor.interceptRequest(request: request);
        await interceptor.interceptResponse(response: response);
        
        expect(interceptor.lastRequest, equals(request));
        expect(interceptor.lastResponse, equals(response));
      });

      test('should respect shouldIntercept flags', () async {
        final interceptor = TestInterceptor(
          shouldInterceptRequestValue: false,
          shouldInterceptResponseValue: false,
        );
        
        expect(await interceptor.shouldInterceptRequest(), isFalse);
        expect(await interceptor.shouldInterceptResponse(), isFalse);
      });
    });

    group('ConditionalInterceptor', () {
      test('should conditionally intercept requests', () async {
        final interceptor = ConditionalInterceptor(shouldInterceptReq: false);
        
        expect(await interceptor.shouldInterceptRequest(), isFalse);
        expect(await interceptor.shouldInterceptResponse(), isTrue);
      });

      test('should conditionally intercept responses', () async {
        final interceptor = ConditionalInterceptor(shouldInterceptResp: false);
        
        expect(await interceptor.shouldInterceptRequest(), isTrue);
        expect(await interceptor.shouldInterceptResponse(), isFalse);
      });
    });

    group('ModifyingInterceptor', () {
      test('should add headers to request', () async {
        final interceptor = ModifyingInterceptor(
          headersToAdd: {'Authorization': 'Bearer token', 'Content-Type': 'application/json'},
        );
        
        final request = Request('GET', Uri.parse('https://example.com'));
        expect(request.headers['Authorization'], isNull);
        expect(request.headers['Content-Type'], isNull);
        
        final modifiedRequest = await interceptor.interceptRequest(request: request);
        
        expect(modifiedRequest.headers['Authorization'], equals('Bearer token'));
        expect(modifiedRequest.headers['Content-Type'], equals('application/json'));
      });

      test('should modify response body when prefix is provided', () async {
        final interceptor = ModifyingInterceptor(bodyPrefix: 'MODIFIED: ');
        
        final response = Response('original body', 200);
        final modifiedResponse = await interceptor.interceptResponse(response: response);
        
        expect(modifiedResponse, isA<Response>());
        if (modifiedResponse is Response) {
          expect(modifiedResponse.body, equals('MODIFIED: original body'));
          expect(modifiedResponse.statusCode, equals(200));
        }
      });

      test('should not modify response when no prefix provided', () async {
        final interceptor = ModifyingInterceptor();
        
        final response = Response('original body', 200);
        final modifiedResponse = await interceptor.interceptResponse(response: response);
        
        expect(modifiedResponse, equals(response));
      });

      test('should return true for shouldInterceptResponse when bodyPrefix is provided', () async {
        final interceptor = ModifyingInterceptor(bodyPrefix: 'PREFIX: ');
        
        expect(await interceptor.shouldInterceptResponse(), isTrue);
      });

      test('should return false for shouldInterceptResponse when no bodyPrefix', () async {
        final interceptor = ModifyingInterceptor();
        
        expect(await interceptor.shouldInterceptResponse(), isFalse);
      });
    });

    group('Async behavior', () {
      test('should handle async shouldInterceptRequest', () async {
        final interceptor = TestInterceptor();
        
        final result = interceptor.shouldInterceptRequest();
        if (result is Future<bool>) {
          expect(await result, isTrue);
        } else {
          expect(result, isTrue);
        }
      });

      test('should handle async shouldInterceptResponse', () async {
        final interceptor = TestInterceptor();
        
        final result = interceptor.shouldInterceptResponse();
        if (result is Future<bool>) {
          expect(await result, isTrue);
        } else {
          expect(result, isTrue);
        }
      });

      test('should handle async interceptRequest', () async {
        final interceptor = TestInterceptor();
        final request = Request('GET', Uri.parse('https://example.com'));
        
        final result = interceptor.interceptRequest(request: request);
        if (result is Future<BaseRequest>) {
          final interceptedRequest = await result;
          expect(interceptedRequest, equals(request));
        } else {
          expect(result, equals(request));
        }
      });

      test('should handle async interceptResponse', () async {
        final interceptor = TestInterceptor();
        final response = Response('test', 200);
        
        final result = interceptor.interceptResponse(response: response);
        if (result is Future<BaseResponse>) {
          final interceptedResponse = await result;
          expect(interceptedResponse, equals(response));
        } else {
          expect(result, equals(response));
        }
      });
    });
  });
}