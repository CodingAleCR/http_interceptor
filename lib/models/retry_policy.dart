import 'package:http/http.dart';

abstract class RetryPolicy {
  bool shouldAttemptRetryOnException(Exception reason) => false;
  Future<bool> shouldAttemptRetryOnResponse(Response response) async => false;
  final int maxRetryAttempts = 1;
}
