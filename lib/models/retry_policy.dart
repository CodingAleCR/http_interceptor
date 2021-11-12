import 'package:http/http.dart';

abstract class RetryPolicy {
  bool shouldAttemptRetryOnException(Exception reason) => false;
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async =>
      false;
  final int maxRetryAttempts = 1;
}
