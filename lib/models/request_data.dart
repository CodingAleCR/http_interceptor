import 'dart:convert';
import 'package:http/http.dart';

import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/utils/utils.dart';

class RequestData {
  Method method;
  String baseUrl;
  Map<String, String> headers;
  Map<String, dynamic> params;
  dynamic body;
  Encoding? encoding;

  RequestData({
    required this.method,
    required this.baseUrl,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    this.body,
    this.encoding,
  })  : headers = headers ?? {},
        params = params ?? {};

  String get url => buildUrlString(baseUrl, params);

  factory RequestData.fromHttpRequest(BaseRequest request) {
    var params = Map<String, dynamic>();
    request.url.queryParametersAll.forEach((key, value) {
      params[key] = value;
    });
    String baseUrl = request.url.origin + request.url.path;

    if (request is Request) {
      return RequestData(
        method: methodFromString(request.method),
        baseUrl: baseUrl,
        headers: request.headers,
        body: request.body,
        encoding: request.encoding,
        params: params,
      );
    }

    throw UnsupportedError(
      "Can't intercept ${request.runtimeType}. Request type not supported yet.",
    );
  }

  Request toHttpRequest() {
    var reqUrl = buildUrlString(baseUrl, params);

    Request request = new Request(methodToString(method), reqUrl.toUri());

    request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding!;
    if (body != null) {
      if (body is String) {
        request.body = body as String;
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
