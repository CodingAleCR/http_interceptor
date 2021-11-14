import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/extensions/io_streamed_response.dart';

// Extends [BaseRequest] to provide copied instances.
extension BaseResponseCopyWith on BaseResponse {
  /// Creates a new instance of [BaseResponse] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  ///
  /// [body] are only copied if `this` is a [Response] instance.
  ///
  /// [stream] and [contentLength] are only copied if `this` is a
  /// [StreamedResponse] instance.
  ///
  /// [inner] are only copied if `this` is a [IOStreamedResponse] instance.
  BaseResponse copyWith({
    int? statusCode,
    BaseRequest? request,
    Map<String, String>? headers,
    bool? isRedirect,
    bool? persistentConnection,
    String? reasonPhrase,
    // `Response` only variables.
    String? body,
    // `StreamedResponse` only properties.
    Stream<List<int>>? stream,
    int? contentLength,
    // `IOStreamedResponse` only properties.
    HttpClientResponse? inner,
  }) {
    if (this is Response) {
      return ResponseCopyWith(this as Response).copyWith(
        statusCode: statusCode,
        body: body,
        request: request,
        headers: headers,
        isRedirect: isRedirect,
        persistentConnection: persistentConnection,
        reasonPhrase: reasonPhrase,
      );
    } else if (this is StreamedResponse) {
      return StreamedResponseCopyWith(this as StreamedResponse).copyWith(
        stream: stream,
        statusCode: statusCode,
        contentLength: contentLength,
        request: request,
        headers: headers,
        isRedirect: isRedirect,
        persistentConnection: persistentConnection,
        reasonPhrase: reasonPhrase,
      );
    } else if (this is IOStreamedResponse) {
      return IOStreamedResponseCopyWith(this as IOStreamedResponse).copyWith(
        stream: stream,
        statusCode: statusCode,
        contentLength: contentLength,
        request: request,
        headers: headers,
        isRedirect: isRedirect,
        persistentConnection: persistentConnection,
        reasonPhrase: reasonPhrase,
        inner: inner,
      );
    }

    throw UnsupportedError(
        'Cannot copy unsupported type of response ${this.runtimeType}');
  }
}
