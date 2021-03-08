import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/functions/functions.dart';
import 'package:http_interceptor/interceptor_contract.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:http_interceptor/utils.dart';

import 'http_methods.dart';

///Class to be used by the user to set up a new `http.Client` with interceptor supported.
///call the `build()` constructor passing in the list of interceptors.
///Example:
///```dart
/// HttpClientWithInterceptor httpClient = HttpClientWithInterceptor.build(interceptors: [
///     Logger(),
/// ]);
///```
///
///Then call the functions you want to, on the created `http` object.
///```dart
/// httpClient.get(...);
/// httpClient.post(...);
/// httpClient.put(...);
/// httpClient.delete(...);
/// httpClient.head(...);
/// httpClient.patch(...);
/// httpClient.read(...);
/// httpClient.readBytes(...);
/// httpClient.send(...);
/// httpClient.close();
///```
///Don't forget to close the client once you are done, as a client keeps
///the connection alive with the server.
class HttpClientWithInterceptor extends BaseClient {
  List<InterceptorContract> interceptors;
  Duration? requestTimeout;
  RetryPolicy? retryPolicy;
  bool Function(X509Certificate, String, int)? badCertificateCallback;
  String Function(Uri)? findProxy;

  int _retryCount = 0;
  late Client _client;

  HttpClientWithInterceptor._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.badCertificateCallback,
    this.findProxy,
    Client? client,
  }) {
    if (client != null) {
      _client = client;
    } else {
      _client = initializeClient(
        badCertificateCallback,
        findProxy,
      );
    }
  }

  factory HttpClientWithInterceptor.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    RetryPolicy? retryPolicy,
    bool Function(X509Certificate, String, int)? badCertificateCallback,
    String Function(Uri)? findProxy,
    Client? client,
  }) =>
      HttpClientWithInterceptor._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        badCertificateCallback: badCertificateCallback,
        findProxy: findProxy,
        client: client,
      );

  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      _sendUnstreamed(
        method: Method.HEAD,
        url: url,
        headers: headers,
      );

  Future<Response> get(Uri url,
          {Map<String, String>? headers, Map<String, String>? params}) =>
      _sendUnstreamed(
        method: Method.GET,
        url: url,
        headers: headers,
        params: params,
      );

  Future<Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed(
        method: Method.POST,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed(
        method: Method.PUT,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed(
        method: Method.PATCH,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _sendUnstreamed(
        method: Method.DELETE,
        url: url,
        headers: headers,
      );

  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  // TODO: Implement interception from `send` method.
  Future<StreamedResponse> send(BaseRequest request) {
    return _client.send(request);
  }

  Future<Response> _sendUnstreamed({
    required Method method,
    required Uri url,
    Map<String, String>? headers,
    Map<String, String>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    url = addParametersToUrl(url, params);

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
      request = await _interceptRequest(request);

      var stream = requestTimeout == null
          ? await send(request)
          : await send(request).timeout(requestTimeout!);

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
    _client.close();
  }
}
