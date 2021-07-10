import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/models/request_data.dart';

/// A class that mimics HTTP Response in order to intercept it's data.
class ResponseData {
  /// The bytes comprising the body of this response.
  Uint8List bodyBytes;

  /// The HTTP status code for this response.
  int statusCode;

  Map<String, String>? headers;

  /// The body of the response as a string.
  String? body;

  /// The size of the response body, in bytes.
  ///
  /// If the size of the request is not known in advance, this is `null`.
  int? contentLength;

  bool? isRedirect;

  /// Whether the server requested that a persistent connection be maintained.
  bool? persistentConnection;

  /// The (frozen) request that triggered this response.
  RequestData? request;

  /// Creates a new response data with body bytes.
  ResponseData(
    this.bodyBytes,
    this.statusCode, {
    this.headers,
    this.body,
    this.contentLength,
    this.isRedirect,
    this.persistentConnection,
    this.request,
  });

  /// Method of the request that triggered this response.
  Method? get method => request?.method;

  /// URL as String of the request that triggered this response.
  String? get url => request?.url;

  /// Creates a new response data from an HTTP response.
  factory ResponseData.fromHttpResponse(Response response) {
    return ResponseData(
      response.bodyBytes,
      response.statusCode,
      headers: response.headers,
      body: response.body,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      request: (response.request != null)
          ? RequestData.fromHttpRequest(response.request!)
          : null,
    );
  }

  /// Converts this response data to an HTTP response.
  Response toHttpResponse() {
    return Response.bytes(
      bodyBytes,
      statusCode,
      headers: headers!,
      persistentConnection: persistentConnection!,
      isRedirect: isRedirect!,
      request: request?.toHttpRequest(),
    );
  }

  /// Convenient toString implementation for logging.
  @override
  String toString() {
    return 'ResponseData { $method, $url, $headers, $statusCode, $body, $request }';
  }
}
