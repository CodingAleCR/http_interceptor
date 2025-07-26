import 'package:http/http.dart';
import 'package:http_interceptor/http/http_methods.dart';

/// Extends [StreamedRequest] to provide copied instances.
extension StreamedRequestCopyWith on StreamedRequest {
  /// Creates a new instance of [StreamedRequest] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  Future<StreamedRequest> copyWith({
    HttpMethod? method,
    Uri? url,
    Map<String, String>? headers,
    Stream<List<int>>? stream,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) async {
    final StreamedRequest clonedRequest = StreamedRequest(
      method?.toString() ?? this.method,
      url ?? this.url,
    )
      ..followRedirects = followRedirects ?? this.followRedirects
      ..maxRedirects = maxRedirects ?? this.maxRedirects
      ..persistentConnection = persistentConnection ?? this.persistentConnection
      ..headers.addAll(headers ?? this.headers);

    await for (List<int> chunk in stream ?? finalize()) {
      clonedRequest.sink.add(chunk);
    }
    clonedRequest.sink.close();

    return clonedRequest;
  }
}
