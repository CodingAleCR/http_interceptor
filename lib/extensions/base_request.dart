import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http/http_methods.dart';

import './multipart_request.dart';
import './request.dart';
import './streamed_request.dart';

/// Extends [BaseRequest] to provide copied instances.
extension BaseRequestCopyWith on BaseRequest {
  /// Creates a new instance of [BaseRequest] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  ///
  /// [body] and [encoding] are only copied if `this` is a [Request] instance.
  ///
  /// [fields] and [files] are only copied if `this` is a [MultipartRequest]
  /// instance.
  ///
  /// [stream] are only copied if `this` is a [StreamedRequest] instance.
  Future<BaseRequest> copyWith({
    HttpMethod? method,
    Uri? url,
    Map<String, String>? headers,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
    // Request only variables.
    dynamic body,
    Encoding? encoding,
    // MultipartRequest only properties.
    Map<String, String>? fields,
    List<MultipartFile>? files,
    // StreamedRequest only properties.
    Stream<List<int>>? stream,
  }) async {
    return switch (this) {
      Request req => req.copyWith(
          method: method,
          url: url,
          headers: headers,
          body: body,
          encoding: encoding,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          persistentConnection: persistentConnection,
        ),
      StreamedRequest req => await req.copyWith(
          method: method,
          url: url,
          headers: headers,
          stream: stream,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          persistentConnection: persistentConnection,
        ),
      MultipartRequest req => req.copyWith(
          method: method,
          url: url,
          headers: headers,
          fields: fields,
          files: files,
          followRedirects: followRedirects,
          maxRedirects: maxRedirects,
          persistentConnection: persistentConnection,
        ),
      _ => throw UnsupportedError(
          'Cannot copy unsupported type of request $runtimeType',
        ),
    };
  }
}
