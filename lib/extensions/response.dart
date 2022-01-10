import 'package:http/http.dart';

/// Extends [Response] to provide copied instances.
extension ResponseCopyWith on Response {
  /// Creates a new instance of [Response] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  Response copyWith({
    String? body,
    int? statusCode,
    BaseRequest? request,
    Map<String, String>? headers,
    bool? isRedirect,
    bool? persistentConnection,
    String? reasonPhrase,
  }) =>
      Response(
        body ?? this.body,
        statusCode ?? this.statusCode,
        request: request ?? this.request,
        headers: headers ?? this.headers,
        isRedirect: isRedirect ?? this.isRedirect,
        persistentConnection: persistentConnection ?? this.persistentConnection,
        reasonPhrase: reasonPhrase ?? this.reasonPhrase,
      );
}
