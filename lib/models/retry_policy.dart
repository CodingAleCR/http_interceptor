import 'package:http/http.dart';

abstract class RetryPolicy {
  bool shouldAttemptRetryOnException(Exception reason) => false;
  bool shouldAttemptRetryOnResponse(Response response) => false;
  final int maxRetryAttempts = 1;
}