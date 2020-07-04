import 'package:http_interceptor/models/models.dart';

abstract class RetryPolicy {
  bool shouldAttemptRetryOnException(Exception reason) => false;
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async =>
      false;
  final int maxRetryAttempts = 1;
}
