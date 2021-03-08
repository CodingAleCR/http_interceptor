import 'dart:convert';
import 'package:http/http.dart';

import 'package:http_interceptor/http_methods.dart';
import 'package:http_interceptor/utils.dart';

class RequestData {
  Method method;
  String baseUrl;
  Map<String, String>? headers;
  Map<String, String>? params;
  dynamic? body;
  Encoding? encoding;

  RequestData({
    required this.method,
    required this.baseUrl,
    this.headers,
    this.params,
    this.body,
    this.encoding,
  });

  String get url => addParametersToStringUrl(baseUrl, params);

  factory RequestData.fromHttpRequest(Request request) {
    var params = Map<String, String>();
    request.url.queryParameters.forEach((key, value) {
      params[key] = value;
    });
    String baseUrl = request.url.origin + request.url.path;
    return RequestData(
      method: methodFromString(request.method),
      encoding: request.encoding,
      body: request.body,
      baseUrl: baseUrl,
      headers: request.headers,
      params: params,
    );
  }

  Request toHttpRequest() {
    var reqUrl = Uri.parse(addParametersToStringUrl(baseUrl, params));

    Request request = new Request(methodToString(method), reqUrl);

    if (headers != null) request.headers.addAll(headers!);
    if (encoding != null) request.encoding = encoding!;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body?.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw new ArgumentError('Invalid request body "$body".');
      }
    }

    return request;
  }

  @override
  String toString() {
    return 'Request Data { $method, $baseUrl, $headers, $params, $body }';
  }
}
