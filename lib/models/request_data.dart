import 'dart:convert';
import 'package:http/http.dart';

import 'package:http_interceptor/http_methods.dart';

class RequestData {
  Method method;
  String url;
  Map<String, String> headers;
  Map<String, String> params;
  dynamic body;
  Encoding encoding;

  RequestData({
    this.method,
    this.url,
    this.headers,
    this.params,
    this.body,
    this.encoding,
  });

  String get requestUrl {
    var paramUrl = url;
    if (params != null && params.length > 0) {
      paramUrl += "?";
      params.forEach((key, value) {
        paramUrl += "$key=$value&";
      });
      paramUrl = paramUrl.substring(0, paramUrl.length);
    }
    return paramUrl;
  }

  factory RequestData.fromHttpRequest(Request request) {
    var params = Map<String, String>();
    request.url.queryParameters.forEach((key, value) {
      params[key] = value;
    });
    return RequestData(
      method: methodFromString(request.method),
      encoding: request.encoding,
      body: request.body,
      url: request.url.toString(),
      headers: request.headers ?? <String, String>{},
      params: params ?? <String, String>{},
    );
  }

  Request toHttpRequest() {
    var paramUrl = url;
    if (params != null && params.length > 0) {
      paramUrl += "?";
      params.forEach((key, value) {
        paramUrl += "$key=$value&";
      });
      paramUrl = paramUrl.substring(0, paramUrl.length);
    }
    var request = new Request(methodToString(method), Uri.parse(paramUrl));
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
