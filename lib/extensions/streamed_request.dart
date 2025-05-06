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
    // Create a new StreamedRequest with the same method and URL
    final StreamedRequest clonedRequest =
        StreamedRequest(method?.asString ?? this.method, url ?? this.url)
          ..headers.addAll(headers ?? this.headers);

    // Use a broadcast stream to allow multiple listeners
    final Stream<List<int>> broadcastStream =
        stream?.asBroadcastStream() ?? finalize().asBroadcastStream();

    // Pipe the broadcast stream into the cloned request's sink
    broadcastStream.listen(
      (List<int> data) => clonedRequest.sink.add(data),
      onDone: () => clonedRequest.sink.close(),
    );

    this.persistentConnection =
        persistentConnection ?? this.persistentConnection;
    this.followRedirects = followRedirects ?? this.followRedirects;
    this.maxRedirects = maxRedirects ?? this.maxRedirects;

    return clonedRequest;
  }
}
