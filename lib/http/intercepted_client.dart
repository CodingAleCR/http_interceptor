import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/managers/pool_manager.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:pool/pool.dart';

import 'http_methods.dart';
import 'interceptor_contract.dart';

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
  static const String kSkipPoolHeader = 'Intercepted-Client-Skip-Pool-Manager';

  /// List of interceptors that will be applied to the requests and responses.
  final List<InterceptorContract> interceptors;

  /// Maximum duration of a request.
  final Duration? requestTimeout;

  /// A policy that defines whether a request or response should trigger a
  /// retry. This is useful for implementing JWT token expiration
  final RetryPolicy? retryPolicy;

  /// Manage the requests in a Pool.
  PoolManager? poolManager;

  Map<BaseRequest, int> _retryCount = {};
  late Client _inner;

  InterceptedClient._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.poolManager,
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
    RetryPolicy? retryPolicy,
    Client? client,
    PoolManager? poolManager,
  }) =>
      InterceptedClient._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        client: client,
        poolManager: poolManager,
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
    PoolResource? poolResource = await _addToRequestPool(request.headers);
    request.headers.remove(kSkipPoolHeader);

    try {
      final interceptedRequest = await _interceptRequest(request);

      final response = await _inner.send(interceptedRequest);

      final interceptedResponse = await _interceptResponse(response);

      await _releasePoolRequest(poolResource);
      return interceptedResponse as StreamedResponse;
    } catch (_) {
      await _releasePoolRequest(poolResource);
      rethrow;
    }
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

    Request request = new Request(method.asString, url);
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
        throw new ArgumentError('Invalid request body "$body".');
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
    throw new ClientException("$message.", url);
  }

  /// Attempts to perform the request and intercept the data
  /// of the response
  Future<BaseResponse> _attemptRequest(BaseRequest request) async {
    PoolResource? poolResource = await _addToRequestPool(request.headers);
    request.headers.remove(kSkipPoolHeader);

    if (!_retryCount.containsKey(request)) {
      _retryCount[request] = 0;
    }

    BaseResponse response;
    try {
      // Intercept request
      final interceptedRequest = await _interceptRequest(request);

      var stream = requestTimeout == null
          ? await _inner.send(interceptedRequest)
          : await _inner.send(interceptedRequest).timeout(requestTimeout!);

      response =
          request is Request ? await Response.fromStream(stream) : stream;

      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount[request]! &&
          await retryPolicy!.shouldAttemptRetryOnResponse(response)) {
        _retryCount[request] = _retryCount[request]! + 1;
        response = await _attemptRequest(request);
        await _releasePoolRequest(poolResource);
        return response;
      }
    } on Exception catch (error) {
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount[request]! &&
          retryPolicy!.shouldAttemptRetryOnException(error, request)) {
        _retryCount[request] = _retryCount[request]! + 1;
        try {
          response = await _attemptRequest(request);
          await _releasePoolRequest(poolResource);
          return response;
        } on Exception catch (_) {
          _retryCount.remove(request);
          await _releasePoolRequest(poolResource);
          rethrow;
        }
      } else {
        _retryCount.remove(request);
        await _releasePoolRequest(poolResource);
        rethrow;
      }
    }

    _retryCount.remove(request);
    await _releasePoolRequest(poolResource);
    return response;
  }

  /// This internal function intercepts the request.
  Future<BaseRequest> _interceptRequest(BaseRequest request) async {
    BaseRequest interceptedRequest = request.copyWith();
    for (InterceptorContract interceptor in interceptors) {
      interceptedRequest = await interceptor.interceptRequest(
        request: interceptedRequest,
      );
    }

    return interceptedRequest;
  }

  /// This internal function intercepts the response.
  Future<BaseResponse> _interceptResponse(BaseResponse response) async {
    BaseResponse interceptedResponse = response;
    for (InterceptorContract interceptor in interceptors) {
      interceptedResponse = await interceptor.interceptResponse(
        response: interceptedResponse,
      );
    }

    return interceptedResponse;
  }

  void close() {
    _inner.close();
  }

  /// Add a new request to the pool.
  /// If [kSkipPoolHeader] is found in the headers, the pool is skipped so
  /// the request is executed immediately.
  Future<PoolResource?> _addToRequestPool(Map<String, String>? headers) async {
    if (headers?.keys.contains(kSkipPoolHeader) == true) {
      return null;
    }

    if (poolManager == null) {
      return null;
    }
    return await poolManager?.request();
  }

  /// Release a [PoolRequest]
  Future<void> _releasePoolRequest(PoolResource? poolResource) async {
    if (poolResource == null) {
      return;
    }
    await poolManager?.release(poolResource);
  }
}
