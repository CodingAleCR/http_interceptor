import 'dart:convert';
import 'package:http/http.dart';

import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/utils/utils.dart';

class MultipartBody {
  Map<String, String>? fields;
  List<MultipartFile>? files;
  MultipartBody({this.fields, this.files});
}

/// A class that mimics HTTP Request in order to intercept it's data.
class RequestData {
  /// The HTTP method of the request.
  ///
  /// Most commonly "GET" or "POST", less commonly "HEAD", "PUT", or "DELETE".
  /// Non-standard method names are also supported.
  Method method;

  /// The base URL String to which the request will be sent. It does not include
  /// the query parameters.
  String baseUrl;

  /// Map of String to String that represents the headers of the request.
  Map<String, String> headers;

  /// Map of String to String that represents the query parameters of the
  /// request.
  Map<String, dynamic> params;

  dynamic body;

  /// The encoding used for the request.
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

  /// The complete URL String including query parameters to which the request
  /// will be sent.
  String get url => buildUrlString(baseUrl, params);

  /// Creates a new request data from an HTTP request.
  ///
  /// For now it only supports [Request] and [MultipartRequest].
  /// TODO(codingalecr): Support for [StreamedRequest].
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
    } else if (request is MultipartRequest) {
      return RequestData(
        method: methodFromString(request.method),
        baseUrl: baseUrl,
        headers: request.headers,
        body: MultipartBody(fields: request.fields, files: request.files),
        params: params,
      );
    }

    throw UnsupportedError(
      "Can't intercept ${request.runtimeType}. Request type not supported yet.",
    );
  }

  /// Converts this request data to an HTTP request.
  BaseRequest toHttpRequest() {
    var reqUrl = buildUrlString(baseUrl, params);

    // Request request = new Request();

    late BaseRequest request;

    if (body != null) {
      if (body is MultipartBody) {
        final _body = body as MultipartBody;
        request = MultipartRequest(methodToString(method), reqUrl.toUri())
          ..files.addAll(_body.files ?? [])
          ..fields.addAll(_body.fields ?? {});
      } else {
        if (body is String) {
          request = Request(methodToString(method), reqUrl.toUri())..body = body as String;
        } else if (body is List) {
          request = Request(methodToString(method), reqUrl.toUri())..bodyBytes = body?.cast<int>();
        } else if (body is Map) {
          request = Request(methodToString(method), reqUrl.toUri())..bodyFields = body.cast<String, String>();
        } else {
          throw new ArgumentError('Invalid request body "$body".');
        }
        if (encoding != null) (request as Request).encoding = encoding!;
      }
    }

    request.headers.addAll(headers);

    return request;
  }

  /// Convenient toString implementation for logging.
  @override
  String toString() {
    return 'Request Data { $method, $baseUrl, $headers, $params, $body }';
  }
}
