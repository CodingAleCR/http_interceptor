import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
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
  Duration requestTimeout;
  RetryPolicy retryPolicy;
  bool Function(X509Certificate, String, int) badCertificateCallback;

  int _retryCount = 0;
  Client _client;

  void _initializeClient() {
    var ioClient = new HttpClient()
      ..badCertificateCallback = badCertificateCallback;
    _client = IOClient(ioClient);
  }

  HttpClientWithInterceptor._internal({
    this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.badCertificateCallback,
  });

  factory HttpClientWithInterceptor.build({
    @required List<InterceptorContract> interceptors,
    Duration requestTimeout,
    RetryPolicy retryPolicy,
    bool Function(X509Certificate, String, int) badCertificateCallback,
  }) {
    assert(interceptors != null);

    //Remove any value that is null.
    interceptors.removeWhere((interceptor) => interceptor == null);
    return HttpClientWithInterceptor._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        badCertificateCallback: badCertificateCallback);
  }

  Future<Response> head(url, {Map<String, String> headers}) => _sendUnstreamed(
        method: Method.HEAD,
        url: url,
        headers: headers,
      );

  Future<Response> get(url,
          {Map<String, String> headers, Map<String, String> params}) =>
      _sendUnstreamed(
        method: Method.GET,
        url: url,
        headers: headers,
        params: params,
      );

  Future<Response> post(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed(
        method: Method.POST,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> put(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed(
        method: Method.PUT,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> patch(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed(
        method: Method.PATCH,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> delete(url, {Map<String, String> headers}) =>
      _sendUnstreamed(
        method: Method.DELETE,
        url: url,
        headers: headers,
      );

  Future<String> read(url, {Map<String, String> headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  Future<StreamedResponse> send(BaseRequest request) {
    if (_client == null) {
      _initializeClient();
    }
    return _client.send(request);
  }

  Future<Response> _sendUnstreamed({
    @required Method method,
    @required url,
    @required Map<String, String> headers,
    Map<String, String> params,
    dynamic body,
    Encoding encoding,
  }) async {
    if (url is String) {
      url = Uri.parse(addParametersToStringUrl(url, params));
    } else if (url is Uri) {
      url = addParametersToUrl(url, params);
    } else {
      throw HttpInterceptorException(
          "Malformed URL parameter. Check that the url used is either a String or a Uri instance.");
    }

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

  void _checkResponseSuccess(url, Response response) {
    if (response.statusCode < 400) return;
    var message = "Request to $url failed with status ${response.statusCode}";
    if (response.reasonPhrase != null) {
      message = "$message: ${response.reasonPhrase}";
    }
    if (url is String) url = Uri.parse(url);
    throw new ClientException("$message.", url);
  }

  Future<Response> _attemptRequest(Request request) async {
    var response;
    try {
      // Intercept request
      request = await _interceptRequest(request);

      var stream = requestTimeout == null
          ? await send(request)
          : await send(request).timeout(requestTimeout);

      response = await Response.fromStream(stream);
      if (retryPolicy != null &&
          retryPolicy.maxRetryAttempts > _retryCount &&
          await retryPolicy.shouldAttemptRetryOnResponse(
              ResponseData.fromHttpResponse(response))) {
        _retryCount += 1;
        return _attemptRequest(request);
      }
    } catch (error) {
      if (retryPolicy != null &&
          retryPolicy.maxRetryAttempts > _retryCount &&
          retryPolicy.shouldAttemptRetryOnException(error)) {
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
    if (_client == null) {
      _initializeClient();
    }
    _client.close();
  }
}
