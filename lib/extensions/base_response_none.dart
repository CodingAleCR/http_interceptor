import 'package:http/http.dart';
import 'package:http_interceptor/extensions/response.dart';
import 'package:http_interceptor/extensions/streamed_response.dart';

// Extends [BaseRequest] to provide copied instances.
extension BaseResponseCopyWith on BaseResponse {
  /// Creates a new instance of [BaseResponse] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  ///
  /// [body] are only copied if `this` is a [Response] instance.
  ///
  /// [stream] and [contentLength] are only copied if `this` is a
  /// [StreamedResponse] instance.
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
  }) =>
      switch (this) {
        Response res => res.copyWith(
            statusCode: statusCode,
            body: body,
            request: request,
            headers: headers,
            isRedirect: isRedirect,
            persistentConnection: persistentConnection,
            reasonPhrase: reasonPhrase,
          ),
        StreamedResponse res => res.copyWith(
            stream: stream,
            statusCode: statusCode,
            contentLength: contentLength,
            request: request,
            headers: headers,
            isRedirect: isRedirect,
            persistentConnection: persistentConnection,
            reasonPhrase: reasonPhrase,
          ),
        _ => throw UnsupportedError(
            'Cannot copy unsupported type of response $runtimeType',
          ),
      };
}
