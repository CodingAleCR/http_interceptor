import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
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

    // Regression test for https://github.com/CodingAleCR/http_interceptor/issues/174
    //
    // BaseRequest.finalize() can only be called once. Before this fix, retries
    // reused the same (already-finalized) request object, causing a StateError
    // that bubbled up silently so the request never reached the server.
    test('retry actually sends the request to the server', () async {
      // arrange
      var sendCount = 0;
      final fakeClient = _CountingFakeClient(
        responses: [
          Response('unauthorized', 401),
          Response('ok', 200),
        ],
        onSend: () => sendCount++,
      );

      var interceptCount = 0;
      final client = InterceptedClient.build(
        interceptors: [
          _Interceptor(
            onRequest: (r) {
              interceptCount++;
              return r;
            },
          ),
        ],
        client: fakeClient,
        retryPolicy: _OnceRetryPolicy(),
      );

      // act
      final response = await client.get(Uri.parse('https://example.com/'));

      // assert – the retry must reach the underlying client (sendCount == 2)
      // and the interceptor must run for each attempt (interceptCount == 2).
      expect(sendCount, 2, reason: 'retry request must be sent to the server');
      expect(interceptCount, 2, reason: 'interceptor must run on each attempt');
      expect(response.statusCode, 200);

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

/// Fake client that cycles through a list of canned [Response]s and calls
/// [onSend] on each [send] invocation.
class _CountingFakeClient implements Client {
  _CountingFakeClient({required List<Response> responses, this.onSend})
    : _responses = responses;

  final List<Response> _responses;
  final void Function()? onSend;
  int _index = 0;

  Response get _next {
    final r = _responses[_index.clamp(0, _responses.length - 1)];
    if (_index < _responses.length) _index++;
    return r;
  }

  @override
  void close() {}

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_next);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) =>
      Future.value(_next);

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      Future.value(_next);

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_next);

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_next);

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) => Future.value(_next);

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) =>
      Future.value(_next.body);

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
      Future.value(_next.bodyBytes);

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    onSend?.call();
    final r = _next;
    return StreamedResponse(
      Stream.value(r.bodyBytes),
      r.statusCode,
      request: request,
      headers: r.headers,
    );
  }
}

/// Retry policy that retries once on any non-200 response.
class _OnceRetryPolicy implements RetryPolicy {
  @override
  int get maxRetryAttempts => 1;

  @override
  bool shouldAttemptRetryOnResponse(BaseResponse response) =>
      response.statusCode != 200;

  @override
  bool shouldAttemptRetryOnException(Exception reason, BaseRequest request) =>
      false;

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) =>
      Duration.zero;

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) =>
      Duration.zero;
}
