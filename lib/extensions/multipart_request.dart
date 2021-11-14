import 'package:http/http.dart';
import 'package:http_interceptor/http/http_methods.dart';

/// Extends [MultipartRequest] to provide copied instances.
extension MultipartRequestCopyWith on MultipartRequest {
  /// Creates a new instance of [MultipartRequest] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  MultipartRequest copyWith({
    HttpMethod? method,
    Uri? url,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<MultipartFile>? files,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) =>
      MultipartRequest(
        method?.asString ?? this.method,
        url ?? this.url,
      )
        ..headers.addAll(headers ?? {})
        ..fields.addAll(fields ?? {})
        ..files.addAll(files ?? [])
        ..followRedirects = followRedirects ?? this.followRedirects
        ..maxRedirects = maxRedirects ?? this.maxRedirects
        ..persistentConnection =
            persistentConnection ?? this.persistentConnection;
}
