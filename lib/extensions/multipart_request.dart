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
    var clonedRequest =
        MultipartRequest(method?.asString ?? this.method, url ?? this.url)
          ..headers.addAll(headers ?? this.headers)
          ..fields.addAll(fields ?? this.fields);

    // Copy files from original request if no new files provided
    if (files == null) {
      for (var file in this.files) {
        clonedRequest.files.add(MultipartFile(
          file.field,
          file.finalize(),
          file.length,
          filename: file.filename,
          contentType: file.contentType,
        ));
      }
    } else {
      // Use the provided files
      for (var file in files) {
        clonedRequest.files.add(MultipartFile(
          file.field,
          file.finalize(),
          file.length,
          filename: file.filename,
          contentType: file.contentType,
        ));
      }
    }

    // Set properties on the cloned request, not the original
    clonedRequest.persistentConnection =
        persistentConnection ?? this.persistentConnection;
    clonedRequest.followRedirects = followRedirects ?? this.followRedirects;
    clonedRequest.maxRedirects = maxRedirects ?? this.maxRedirects;

    return clonedRequest;
  }
}
