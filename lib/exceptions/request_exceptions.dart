import 'package:http/http.dart';

class RequestCancelledException implements Exception {
  final BaseRequest request;

  RequestCancelledException(this.request);

  String toString() {
    return 'The request has been cancelled (${request.url})';
  }
}
