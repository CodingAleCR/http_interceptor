import 'package:http/http.dart';

/// Extends [StreamedResponse] to provide copied instances.
extension StreamedResponseCopyWith on StreamedResponse {
  /// Creates a new instance of [StreamedResponse] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  StreamedResponse copyWith({
    Stream<List<int>>? stream,
    int? statusCode,
    int? contentLength,
    BaseRequest? request,
    Map<String, String>? headers,
    bool? isRedirect,
    bool? persistentConnection,
    String? reasonPhrase,
  }) =>
      StreamedResponse(
        stream ?? this.stream,
        statusCode ?? this.statusCode,
        contentLength: contentLength ?? this.contentLength,
        request: request ?? this.request,
        headers: headers ?? this.headers,
        isRedirect: isRedirect ?? this.isRedirect,
        persistentConnection: persistentConnection ?? this.persistentConnection,
        reasonPhrase: reasonPhrase ?? this.reasonPhrase,
      );
}
