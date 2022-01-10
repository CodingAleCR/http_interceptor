/// Enum representation of all available HTTP methods.
enum HttpMethod {
  HEAD,
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

/// Extends [HttpMethod] to be initialized from a [String] value.
extension StringToMethod on HttpMethod {
  /// Parses an string into a Method Enum value.
  static HttpMethod fromString(String method) {
    switch (method) {
      case "HEAD":
        return HttpMethod.HEAD;
      case "GET":
        return HttpMethod.GET;
      case "POST":
        return HttpMethod.POST;
      case "PUT":
        return HttpMethod.PUT;
      case "PATCH":
        return HttpMethod.PATCH;
      case "DELETE":
        return HttpMethod.DELETE;
    }
    throw ArgumentError.value(method, "method", "Must be a valid HTTP Method.");
  }
}

/// Extends [HttpMethod] to provide a [String] representation.
extension MethodToString on HttpMethod {
  // Parses a Method Enum value into a string.
  String get asString {
    switch (this) {
      case HttpMethod.HEAD:
        return "HEAD";
      case HttpMethod.GET:
        return "GET";
      case HttpMethod.POST:
        return "POST";
      case HttpMethod.PUT:
        return "PUT";
      case HttpMethod.PATCH:
        return "PATCH";
      case HttpMethod.DELETE:
        return "DELETE";
    }
  }
}
