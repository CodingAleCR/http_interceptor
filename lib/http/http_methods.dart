// ignore_for_file: constant_identifier_names
/// Enum representation of all available HTTP methods.
enum HttpMethod {
  HEAD,
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
  OPTIONS;

  /// Converts a string to an [HttpMethod].
  static HttpMethod fromString(String method) => switch (method) {
        "HEAD" => HttpMethod.HEAD,
        "GET" => HttpMethod.GET,
        "POST" => HttpMethod.POST,
        "PUT" => HttpMethod.PUT,
        "PATCH" => HttpMethod.PATCH,
        "DELETE" => HttpMethod.DELETE,
        "OPTIONS" => HttpMethod.OPTIONS,
        _ => throw ArgumentError.value(
            method,
            "method",
            "Must be a valid HTTP Method.",
          ),
      };

  /// Converts the [HttpMethod] to a string.
  String get asString => name;

  @override
  String toString() => name;
}
