import 'dart:convert';
import 'package:http/http.dart';

import 'package:http_interceptor/http_methods.dart';
import 'package:http_interceptor/models/merge_params.dart';

class RequestData {
  Method method;
  Uri url;
  Map<String, String> headers;
  List<MultipartFile> files;

  /// Map<String, dynamic /*String|Iterable<String>*/ >
  Map<String, dynamic /*String|Iterable<String>*/ > params;
  dynamic body;
  Encoding encoding;

  RequestData({
    this.method,
    this.url,
    this.headers,
    this.params,
    this.body,
    this.encoding,
    this.files,
  });

  String get requestUrl {
    return mergeParams(url, params).toString();
  }

  factory RequestData.fromHttpRequest(dynamic request) {
    if (request is Request) {
      return RequestData(
        method: methodFromString(request.method),
        encoding: request.encoding,
        body: request.body,
        url: request.url,
        headers: request.headers ?? <String, String>{},
        params: request.url.queryParametersAll,
      );
    } else if (request is MultipartRequest) {
      return RequestData(
        method: methodFromString(request.method),
        encoding: null,
        body: request.fields,
        files: request.files ?? List<MultipartFile>(),
        url: request.url,
        headers: request.headers ?? <String, String>{},
        params: request.url.queryParametersAll,
      );
    }
    return null;
  }

  T toHttpRequest<T extends BaseRequest>() {
    Uri paramUrl = mergeParams(url, params);
    if (T.toString() == 'MultipartRequest') {
      var request = MultipartRequest("POST", paramUrl);
      if (headers != null) request.headers.addAll(headers);
      if (body != null) request.fields.addAll(body);
      if (files != null) request.files.addAll(files);
      return request as T;
    } else {
      var request = new Request(methodToString(method), paramUrl);
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
      return request as T;
    }
  }
}
