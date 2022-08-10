class HttpInterceptorException implements Exception {
  final dynamic message;

  HttpInterceptorException([this.message]);

  @override
  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}
