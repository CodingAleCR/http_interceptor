import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http/http_methods.dart';

/// Extends [Request] to provide copied instances.
extension RequestCopyWith on Request {
  /// Creates a new instance of [Request] based of on `this`. It copies
  /// all the properties and overrides the ones sent via parameters.
  Request copyWith({
    HttpMethod? method,
    Uri? url,
    Map<String, String>? headers,
    String? body,
    List<int>? bodyBytes,
    Encoding? encoding,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final Request copied = Request(
      method?.asString ?? this.method,
      url ?? this.url,
    )..bodyBytes = this.bodyBytes;

    try {
      copied.body = this.body;
    } catch (e) {
      // Do not try to get body as string when it is not parseable
    }

    if (body != null) {
      copied.body = body;
    }

    if (bodyBytes != null) {
      copied.bodyBytes = bodyBytes;
    }

    return copied
      ..headers.addAll(headers ?? this.headers)
      ..encoding = encoding ?? this.encoding
      ..followRedirects = followRedirects ?? this.followRedirects
      ..maxRedirects = maxRedirects ?? this.maxRedirects
      ..persistentConnection =
          persistentConnection ?? this.persistentConnection;
  }
}
