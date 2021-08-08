import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:http_interceptor/extensions/extensions.dart';

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
  List<InterceptorContract> interceptors;
  Duration? requestTimeout;
  RetryPolicy? retryPolicy;
  String Function(Uri)? findProxy;

  int _retryCount = 0;
  late Client _inner;

  InterceptedClient._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.findProxy,
    Client? client,
  }) : _inner = client ?? Client();

  factory InterceptedClient.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    RetryPolicy? retryPolicy,
    String Function(Uri)? findProxy,
    Client? client,
  }) =>
      InterceptedClient._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        findProxy: findProxy,
        client: client,
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
  Future<Response> _attemptRequest(Request request) async {
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
        return _attemptRequest(request);
      }
    } on Exception catch (error) {
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          retryPolicy!.shouldAttemptRetryOnException(error)) {
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
}
