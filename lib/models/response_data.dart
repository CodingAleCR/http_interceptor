import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/models/request_data.dart';

class ResponseData {
  /// The bytes comprising the body of this response.
  Uint8List bodyBytes;
  int statusCode;

  String? url;
  Map<String, String>? headers;
  String? body;
  int? contentLength;
  bool? isRedirect;
  bool? persistentConnection;
  RequestData? request;

  ResponseData(
    this.bodyBytes,
    this.statusCode, {
    this.url,
    this.headers,
    this.body,
    this.contentLength,
    this.isRedirect,
    this.persistentConnection,
    this.request,
  });

  Method? get method => request?.method;

  factory ResponseData.fromHttpResponse(Response response) {
    return ResponseData(
      response.bodyBytes,
      response.statusCode,
      headers: response.headers,
      body: response.body,
      contentLength: response.contentLength,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      url: (response.request != null) ? response.request?.url.toString() : null,
      request: (response.request != null)
          ? RequestData.fromHttpRequest(response.request!)
          : null,
    );
  }

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

  @override
  String toString() {
    return 'ResponseData { $method, $url, $headers, $statusCode, $body, $request }';
  }
}
