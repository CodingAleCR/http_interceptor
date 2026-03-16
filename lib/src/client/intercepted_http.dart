import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';

import '../interceptor/http_interceptor.dart';
import '../request_response/uri_extension.dart';
import '../retry/retry_policy.dart';
import 'intercepted_client.dart';

/// Facade for one-off or shared intercepted HTTP calls.
///
/// Holds an [InterceptedClient] and exposes the same API (get, post, put,
/// patch, delete, head, read, readBytes, send). For long-lived apps with many
/// requests, prefer holding an [InterceptedClient] and reusing it.
class InterceptedHttp {
  InterceptedHttp._(this._client);

  final InterceptedClient _client;

  /// Builds an [InterceptedHttp] with the same options as [InterceptedClient.build].
  factory InterceptedHttp.build({
    required List<HttpInterceptor> interceptors,
    Client? client,
    RetryPolicy? retryPolicy,
    Duration? requestTimeout,
    void Function()? onRequestTimeout,
  }) {
    return InterceptedHttp._(
      InterceptedClient.build(
        interceptors: interceptors,
        client: client,
        retryPolicy: retryPolicy,
        requestTimeout: requestTimeout,
        onRequestTimeout: onRequestTimeout,
      ),
    );
  }

  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.get(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
  );

  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.head(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
  );

  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.post(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.put(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.patch(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.delete(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  Future<String> read(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.read(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
  );

  Future<Uint8List> readBytes(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => _client.readBytes(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
  );

  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  void close() => _client.close();
}
