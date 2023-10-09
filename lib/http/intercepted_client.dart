import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/extensions/base_request.dart';
import 'package:http_interceptor/extensions/uri.dart';

import '../models/interceptor_contract.dart';
import '../models/retry_policy.dart';
import 'http_methods.dart';

typedef TimeoutCallback = FutureOr<StreamedResponse> Function();

/// Class to be used by the user to set up a new `http.Client` with interceptor
/// support.
///
/// Call `build()` and pass list of interceptors as parameter.
///
/// Example:
/// ```dart
///  InterceptedClient client = InterceptedClient.build(interceptors: [
///      LoggingInterceptor(),
///  ]);
/// ```
///
/// Then call the functions you want to, on the created `client` object.
/// ```dart
///  client.get(...);
///  client.post(...);
///  client.put(...);
///  client.delete(...);
///  client.head(...);
///  client.patch(...);
///  client.read(...);
///  client.send(...);
///  client.readBytes(...);
///  client.close();
/// ```
///
/// Don't forget to close the client once you are done, as a client keeps
/// the connection alive with the server by default.
class InterceptedClient extends BaseClient {
  /// List of interceptors that will be applied to the requests and responses.
  final List<InterceptorContract> interceptors;

  /// Maximum duration of a request.
  final Duration? requestTimeout;

  /// Request timeout handler
  TimeoutCallback? onRequestTimeout;

  /// A policy that defines whether a request or response should trigger a
  /// retry. This is useful for implementing JWT token expiration
  final RetryPolicy? retryPolicy;

  int _retryCount = 0;
  late Client _inner;

  InterceptedClient._internal({
    required this.interceptors,
    this.requestTimeout,
    this.onRequestTimeout,
    this.retryPolicy,
    Client? client,
  }) : _inner = client ?? Client();

  /// Builds a new [InterceptedClient] instance.
  ///
  /// Interceptors are applied in a linear order. For example a list that looks
  /// like this:
  ///
  /// ```dart
  /// InterceptedClient.build(
  ///   interceptors: [
  ///     WeatherApiInterceptor(),
  ///     LoggerInterceptor(),
  ///   ],
  /// ),
  /// ```
  ///
  /// Will apply first the `WeatherApiInterceptor` interceptor, so when
  /// `LoggerInterceptor` receives the request/response it has already been
  /// intercepted.
  factory InterceptedClient.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    TimeoutCallback? onRequestTimeout,
    RetryPolicy? retryPolicy,
    Client? client,
  }) =>
      InterceptedClient._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        onRequestTimeout: onRequestTimeout,
        retryPolicy: retryPolicy,
        client: client,
      );

  @override
  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
  }) async =>
      (await _sendUnstreamed(
        method: HttpMethod.HEAD,
        url: url,
        headers: headers,
      )) as Response;

  @override
  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) async =>
      (await _sendUnstreamed(
        method: HttpMethod.GET,
        url: url,
        headers: headers,
        params: params,
      )) as Response;

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: HttpMethod.POST,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: HttpMethod.PUT,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: HttpMethod.PATCH,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: HttpMethod.DELETE,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<String> read(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    return get(url, headers: headers, params: params).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  @override
  Future<Uint8List> readBytes(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    return get(url, headers: headers, params: params).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final response = await _attemptRequest(request, isStream: true);

    final interceptedResponse = await _interceptResponse(response);

    return interceptedResponse as StreamedResponse;
  }

  Future<BaseResponse> _sendUnstreamed({
    required HttpMethod method,
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    url = url.addParameters(params);

    Request request = Request(method.asString, url);
    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }

    var response = await _attemptRequest(request);

    // Intercept response
    response = await _interceptResponse(response);

    return response;
  }

  void _checkResponseSuccess(Uri url, Response response) {
    if (response.statusCode < 400) return;
    var message = "Request to $url failed with status ${response.statusCode}";
    if (response.reasonPhrase != null) {
      message = "$message: ${response.reasonPhrase}";
    }
    throw ClientException("$message.", url);
  }

  /// Attempts to perform the request and intercept the data
  /// of the response
  Future<BaseResponse> _attemptRequest(BaseRequest request,
      {bool isStream = false}) async {
    BaseResponse response;
    try {
      // Intercept request
      final interceptedRequest = await _interceptRequest(request);

      var stream = requestTimeout == null
          ? await _inner.send(interceptedRequest)
          : await _inner
              .send(interceptedRequest)
              .timeout(requestTimeout!, onTimeout: onRequestTimeout);

      response = isStream ? stream : await Response.fromStream(stream);

      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          await retryPolicy!.shouldAttemptRetryOnResponse(response)) {
        _retryCount += 1;
        return _attemptRequest(request);
      }
    } on Exception catch (error) {
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          await retryPolicy!.shouldAttemptRetryOnException(error, request)) {
        _retryCount += 1;
        return _attemptRequest(request);
      } else {
        rethrow;
      }
    }

    _retryCount = 0;
    return response;
  }

  /// This internal function intercepts the request.
  Future<BaseRequest> _interceptRequest(BaseRequest request) async {
    BaseRequest interceptedRequest = request.copyWith();
    for (InterceptorContract interceptor in interceptors) {
      if (await interceptor.shouldInterceptRequest()) {
        interceptedRequest = await interceptor.interceptRequest(
          request: interceptedRequest,
        );
      }
    }

    return interceptedRequest;
  }

  /// This internal function intercepts the response.
  Future<BaseResponse> _interceptResponse(BaseResponse response) async {
    BaseResponse interceptedResponse = response;
    for (InterceptorContract interceptor in interceptors) {
      if (await interceptor.shouldInterceptResponse()) {
        interceptedResponse = await interceptor.interceptResponse(
          response: interceptedResponse,
        );
      }
    }

    return interceptedResponse;
  }

  @override
  void close() {
    _inner.close();
  }
}
