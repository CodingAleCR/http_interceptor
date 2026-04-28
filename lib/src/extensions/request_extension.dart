import 'package:http/http.dart';

/// Extension on [BaseRequest] that provides a fresh, unfinalized copy.
///
/// Dart's [BaseRequest] can only be finalized (sent) once. Retrying a request
/// requires a new copy so [BaseRequest.finalize] can be called again.
extension CopyRequest on BaseRequest {
  /// Returns a new, unfinalized copy of this request with the same properties.
  ///
  /// Supports [Request] and [MultipartRequest]. For any other subtype the
  /// method throws [UnsupportedError] because the body stream can only be
  /// consumed once and cannot be duplicated generically.
  BaseRequest copy() {
    final source = this;
    if (source is Request) {
      final copy = Request(source.method, source.url);
      copy.headers.addAll(source.headers);
      copy.encoding = source.encoding;
      copy.bodyBytes = source.bodyBytes;
      copy.followRedirects = source.followRedirects;
      copy.maxRedirects = source.maxRedirects;
      copy.persistentConnection = source.persistentConnection;
      return copy;
    }

    if (source is MultipartRequest) {
      final copy = MultipartRequest(source.method, source.url);
      copy.headers.addAll(source.headers);
      copy.fields.addAll(source.fields);
      copy.files.addAll(source.files);
      copy.followRedirects = source.followRedirects;
      copy.maxRedirects = source.maxRedirects;
      copy.persistentConnection = source.persistentConnection;
      return copy;
    }

    throw UnsupportedError(
      'Cannot copy a ${source.runtimeType}. '
      'Only Request and MultipartRequest are supported for retry.',
    );
  }
}
