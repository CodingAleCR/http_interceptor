import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_interceptor/models/request_data.dart';

/// A class that mimics a streamed HTTP Response in order to intercept it's data.
class StreamedResponseData {
  /// The stream comprising the body of this response.
  Stream<List<int>> stream;

  /// The HTTP status code for this response.
  int statusCode;

  Map<String, String>? headers;

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
  StreamedResponseData(
    this.stream,
    this.statusCode, {
    this.headers,
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
  factory StreamedResponseData.fromHttpResponse(StreamedResponse response) {
    return StreamedResponseData(
      response.stream,
      response.statusCode,
      headers: response.headers,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      request: (response.request != null) ? RequestData.fromHttpRequest(response.request!) : null,
    );
  }

  /// Converts this response data to an HTTP response.
  StreamedResponse toHttpResponse() {
    return StreamedResponse(
      stream,
      statusCode,
      headers: headers!,
      persistentConnection: persistentConnection!,
      isRedirect: isRedirect!,
      contentLength: contentLength,
      request: request?.toHttpRequest(),
    );
  }

  factory StreamedResponseData.fromResponseData(ResponseData response, Stream<List<int>> stream) {
    return StreamedResponseData(
      stream,
      response.statusCode,
      headers: response.headers,
      persistentConnection: response.persistentConnection,
      isRedirect: response.isRedirect,
      request: response.request,
      contentLength: response.contentLength,
    );
  }

  /// Converts to synchronous response data, with no body
  ResponseData toResponseData() {
    return ResponseData(
      Uint8List(0),
      statusCode,
      headers: headers,
      contentLength: contentLength,
      isRedirect: isRedirect,
      persistentConnection: persistentConnection,
      request: request,
    );
  }

  /// Convenient toString implementation for logging.
  @override
  String toString() {
    return 'StreamedResponseData { $method, $url, $headers, $statusCode, $request }';
  }
}
