import 'dart:convert';

import 'package:http/http.dart';

import '../interceptor/http_interceptor.dart';
import '../interceptor/interceptor_chain.dart';
import '../request_response/uri_extension.dart';
import '../retry/retry_executor.dart';
import '../retry/retry_policy.dart';
import '../timeout_wrapper.dart';

/// HTTP client that runs [HttpInterceptor]s on every request and response.
///
/// Wraps a [Client] (Decorator pattern): delegates to the inner client after
/// running request interceptors, then runs response interceptors on the result.
/// Use [build] to construct with interceptors and optional inner client.
class InterceptedClient extends BaseClient {
  InterceptedClient._({
    required List<HttpInterceptor> interceptors,
    required Client client,
    RetryPolicy? retryPolicy,
    Duration? requestTimeout,
    void Function()? onRequestTimeout,
  }) : _chain = InterceptorChain(interceptors),
       _client = client,
       _retryPolicy = retryPolicy,
       _requestTimeout = requestTimeout,
       _onRequestTimeout = onRequestTimeout;

  final InterceptorChain _chain;
  final Client _client;
  final RetryPolicy? _retryPolicy;
  final Duration? _requestTimeout;
  final void Function()? _onRequestTimeout;

  /// Builds an [InterceptedClient] with the given [interceptors].
  ///
  /// [client] defaults to the platform default ([Client()]). Pass a custom
  /// client (e.g. [IOClient] with [HttpClient.badCertificateCallback]) for
  /// self-signed certificates or other TLS behavior.
  ///
  /// [retryPolicy] when non-null enables retries on exception or response.
  ///
  /// [requestTimeout] when non-null applies a per-request timeout.
  /// [onRequestTimeout] is invoked when a request times out (if provided).
  factory InterceptedClient.build({
    required List<HttpInterceptor> interceptors,
    Client? client,
    RetryPolicy? retryPolicy,
    Duration? requestTimeout,
    void Function()? onRequestTimeout,
  }) {
    return InterceptedClient._(
      interceptors: interceptors,
      client: client ?? Client(),
      retryPolicy: retryPolicy,
      requestTimeout: requestTimeout,
      onRequestTimeout: onRequestTimeout,
    );
  }

  Future<StreamedResponse> _execute(BaseRequest request) async {
    final interceptedRequest = await _chain.runRequestInterceptors(request);
    return _client.send(interceptedRequest);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) => withTimeout(
    action: () async {
      final streamed = _retryPolicy != null
          ? await executeWithRetry(
              policy: _retryPolicy,
              request: request,
              attempt: () => _execute(request),
            )
          : await _execute(request);

      final response = await _chain.runResponseInterceptors(streamed);
      return response as StreamedResponse;
    },
    timeout: _requestTimeout,
    onTimeout: _onRequestTimeout,
  );

  /// Sends a GET request. [params] and [paramsAll] are merged into [url]'s query.
  @override
  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => super.get(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
  );

  /// Sends a HEAD request. [params] and [paramsAll] are merged into [url]'s query.
  @override
  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => super.head(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
  );

  /// Sends a POST request. [params] and [paramsAll] are merged into [url]'s query.
  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => super.post(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  /// Sends a PUT request. [params] and [paramsAll] are merged into [url]'s query.
  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => super.put(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  /// Sends a PATCH request. [params] and [paramsAll] are merged into [url]'s query.
  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => super.patch(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  /// Sends a DELETE request. [params] and [paramsAll] are merged into [url]'s query.
  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) => super.delete(
    url.addQueryParams(params: params, paramsAll: paramsAll),
    headers: headers,
    body: body,
    encoding: encoding,
  );

  @override
  void close() {
    _client.close();
  }
}
