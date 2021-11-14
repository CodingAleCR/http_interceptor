import 'package:http/http.dart';
import 'package:http_interceptor/http/http_methods.dart';

/// Extends [StreamedRequest] to provide copied instances.
extension StreamedRequestCopyWith on StreamedRequest {
  /// Creates a new instance of [StreamedRequest] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  StreamedRequest copyWith({
    HttpMethod? method,
    Uri? url,
    Map<String, String>? headers,
    Stream<List<int>>? stream,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final req = StreamedRequest(
      method?.asString ?? this.method,
      url ?? this.url,
    )
      ..headers.addAll(headers ?? {})
      ..followRedirects = followRedirects ?? this.followRedirects
      ..maxRedirects = maxRedirects ?? this.maxRedirects
      ..persistentConnection =
          persistentConnection ?? this.persistentConnection;

    if (stream != null) {
      stream.listen((data) {
        req.sink.add(data);
      });
      this.finalize().listen((data) {
        req.sink.add(data);
      });
    }

    return req;
  }
}
