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
  }) {
    final MultipartRequest clonedRequest =
        MultipartRequest(method?.asString ?? this.method, url ?? this.url)
          ..headers.addAll(headers ?? this.headers)
          ..fields.addAll(fields ?? this.fields);

    for (final MultipartFile file in this.files) {
      clonedRequest.files.add(MultipartFile(
        file.field,
        file.finalize(),
        file.length,
        filename: file.filename,
        contentType: file.contentType,
      ));
    }

    this.persistentConnection =
        persistentConnection ?? this.persistentConnection;
    this.followRedirects = followRedirects ?? this.followRedirects;
    this.maxRedirects = maxRedirects ?? this.maxRedirects;

    return clonedRequest;
  }
}
