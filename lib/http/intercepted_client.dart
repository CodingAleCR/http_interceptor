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

///Class to be used by the user to set up a new `http.Client` with interceptor supported.
///call the `build()` constructor passing in the list of interceptors.
///Example:
///```dart
/// InterceptedClient httpClient = InterceptedClient.build(interceptors: [
///     Logger(),
/// ]);
///```
///
///Then call the functions you want to, on the created `httpClient` object.
///```dart
/// httpClient.get(...);
/// httpClient.post(...);
/// httpClient.put(...);
/// httpClient.delete(...);
/// httpClient.head(...);
/// httpClient.patch(...);
/// httpClient.read(...);
/// httpClient.readBytes(...);
/// httpClient.close();
///```
///Don't forget to close the client once you are done, as a client keeps
///the connection alive with the server.
///
///Note: `send` method is not currently supported.
class InterceptedClient extends BaseClient {
  static const String kSkipPoolHeader = 'Intercepted-Client-Skip-Pool-Manager';

  List<InterceptorContract> interceptors;
  Duration? requestTimeout;
  RetryPolicy? retryPolicy;
  String Function(Uri)? findProxy;
  PoolManager? poolManager;

  int _retryCount = 0;
  late Client _inner;

  InterceptedClient._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.findProxy,
    this.poolManager,
    Client? client,
  }) : _inner = client ?? Client();

  factory InterceptedClient.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    RetryPolicy? retryPolicy,
    String Function(Uri)? findProxy,
    Client? client,
    PoolManager? poolManager,
  }) =>
      InterceptedClient._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        findProxy: findProxy,
        client: client,
        poolManager: poolManager,
      );

  @override
  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      _sendUnstreamed(
        method: Method.HEAD,
        url: url,
        headers: headers,
      );

  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) =>
      _sendUnstreamed(
        method: Method.GET,
        url: url,
        headers: headers,
        params: params,
      );

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) =>
      _sendUnstreamed(
        method: Method.POST,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      );

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) =>
      _sendUnstreamed(
        method: Method.PUT,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      );

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) =>
      _sendUnstreamed(
        method: Method.PATCH,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      );

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) =>
      _sendUnstreamed(
        method: Method.DELETE,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      );

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

  // TODO(codingalecr): Implement interception from `send` method.
  @override
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }

  Future<Response> _sendUnstreamed({
    required Method method,
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    url = url.addParameters(params);

    Request request = new Request(methodToString(method), url);
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

    request.headers.remove(kSkipPoolHeader);

    late Response response;
    try {
      response = await _attemptRequest(request);
    } catch (_) {
      rethrow;
    }

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
  Future<Response> _attemptRequest(Request request) async {
    PoolResource? poolResource = await _addToRequestPool(request.headers);

    var response;
    try {
      // Intercept request
      final interceptedRequest = await _interceptRequest(request);

      var stream = requestTimeout == null
          ? await send(interceptedRequest)
          : await send(interceptedRequest).timeout(requestTimeout!);

      response = await Response.fromStream(stream);
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          await retryPolicy!.shouldAttemptRetryOnResponse(
              ResponseData.fromHttpResponse(response))) {
        _retryCount += 1;
        await _releasePoolRequest(poolResource);
        return _attemptRequest(request);
      }
    } on Exception catch (error) {
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          retryPolicy!.shouldAttemptRetryOnException(error)) {
        _retryCount += 1;
        await _releasePoolRequest(poolResource);
        return _attemptRequest(request);
      } else {
        await _releasePoolRequest(poolResource);
        rethrow;
      }
    }

    _retryCount = 0;
    await _releasePoolRequest(poolResource);
    return response;
  }

  /// This internal function intercepts the request.
  Future<Request> _interceptRequest(Request request) async {
    for (InterceptorContract interceptor in interceptors) {
      RequestData interceptedData = await interceptor.interceptRequest(
        data: RequestData.fromHttpRequest(request),
      );
      request = interceptedData.toHttpRequest();
    }

    return request;
  }

  /// This internal function intercepts the response.
  Future<Response> _interceptResponse(Response response) async {
    for (InterceptorContract interceptor in interceptors) {
      ResponseData responseData = await interceptor.interceptResponse(
        data: ResponseData.fromHttpResponse(response),
      );
      response = responseData.toHttpResponse();
    }

    return response;
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
