import 'dart:convert';
import 'package:http/http.dart';

import 'package:http_interceptor/http_methods.dart';

class RequestData {
  Method method;
  String url;
  Map<String, String> headers;
  dynamic body;
  Encoding encoding;

  RequestData({
    this.method,
    this.url,
    this.headers,
    this.body,
    this.encoding,
  });

  factory RequestData.fromHttpRequest(Request request) {
    return RequestData(
      method: methodFromString(request.method),
      encoding: request.encoding,
      body: request.body,
      url: request.url.toString(),
      headers: request.headers ?? <String, String>{},
    );
  }

  Request toHttpRequest() {
    var request = new Request(methodToString(method), Uri.parse(url));

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

    return request;
  }
}
