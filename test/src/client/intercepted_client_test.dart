import 'dart:convert';
import 'dart:typed_data';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('InterceptedClient', () {
    test('send runs request then response interceptors', () async {
      // arrange
      var requestSeen = false;
      var responseSeen = false;
      final client = InterceptedClient.build(
        interceptors: [
          _Interceptor(
            onRequest: (r) {
              requestSeen = true;
              return r;
            },
            onResponse: (r) {
              responseSeen = true;
              return r;
            },
          ),
        ],
        client: _FakeClient(Response('ok', 200)),
      );

      // act
      final response = await client.get(Uri.parse('https://example.com/'));

      // assert
      expect(response.body, 'ok');
      expect(requestSeen, true);
      expect(responseSeen, true);

      client.close();
    });

    test('get with params merges into url', () async {
      // arrange
      Uri? capturedUrl;
      final client = InterceptedClient.build(
        interceptors: [
          _Interceptor(
            onRequest: (r) {
              capturedUrl = r.url;
              return r;
            },
          ),
        ],
        client: _FakeClient(Response('', 200)),
      );

      // act
      await client.get(
        Uri.parse('https://example.com/path'),
        params: {'a': '1', 'b': '2'},
      );

      // assert
      expect(capturedUrl?.queryParameters['a'], '1');
      expect(capturedUrl?.queryParameters['b'], '2');

      client.close();
    });
  });
}

class _FakeClient implements Client {
  _FakeClient(this._response);

  final Response _response;

  @override
  void close() {}

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_response);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      Future.value(_response);

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      Future.value(_response);

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_response);

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_response);

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_response);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      Future.value(_response.body);

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      Future.value(_response.bodyBytes);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return StreamedResponse(
      Stream.value(_response.bodyBytes),
      _response.statusCode,
      request: request,
      headers: _response.headers,
    );
  }
}

class _Interceptor implements HttpInterceptor {
  _Interceptor({this.onRequest, this.onResponse});

  final BaseRequest Function(BaseRequest)? onRequest;
  final BaseResponse Function(BaseResponse)? onResponse;

  @override
  BaseRequest interceptRequest({required BaseRequest request}) =>
      onRequest != null ? onRequest!(request) : request;

  @override
  BaseResponse interceptResponse({required BaseResponse response}) =>
      onResponse != null ? onResponse!(response) : response;

  @override
  bool shouldInterceptRequest({required BaseRequest request}) => true;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) => true;
}
