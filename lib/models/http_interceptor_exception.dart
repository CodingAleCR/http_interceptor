

class HttpInterceptorException implements Exception {
  final message;

  HttpInterceptorException([this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "Exception: $message";
  }
}