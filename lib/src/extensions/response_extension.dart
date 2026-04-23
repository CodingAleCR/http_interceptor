import 'dart:convert';

import 'package:http/http.dart';

/// Convenience helpers for decoding a [Response] body.
///
/// These helpers are intentionally lightweight: they do not enforce JSON, do
/// not depend on interceptors, and leave error/status-code handling to the
/// caller.
extension ResponseBodyDecoding on Response {
  /// Decodes [body] as JSON and returns the result.
  ///
  /// The returned value is typically a `Map<String, dynamic>` or `List<dynamic>`.
  /// Throws a [FormatException] if [body] is not valid JSON.
  Object? get jsonBody => body.isEmpty ? null : jsonDecode(body);

  /// Decodes [body] as a JSON object (`Map<String, dynamic>`).
  ///
  /// Throws if [body] is empty, not valid JSON, or not a JSON object.
  Map<String, dynamic> get jsonMap => jsonDecode(body) as Map<String, dynamic>;

  /// Decodes [body] as a JSON array (`List<dynamic>`).
  ///
  /// Throws if [body] is empty, not valid JSON, or not a JSON array.
  List<dynamic> get jsonList => jsonDecode(body) as List<dynamic>;

  /// Attempts to decode [body] as JSON and returns `null` on failure.
  Object? tryJsonBody() {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  /// Maps the decoded JSON body into a model using [fromJson].
  ///
  /// This is a small convenience wrapper around [jsonBody] intended to keep
  /// call sites concise.
  T decodeJson<T>(T Function(Object? json) fromJson) => fromJson(jsonBody);
}
