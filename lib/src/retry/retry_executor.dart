import 'dart:async';

import 'package:http/http.dart';

import 'retry_policy.dart';

/// Runs [attempt] and retries according to [policy] when the policy says so.
///
/// [attempt] should run request interceptors and send (one full try). [request]
/// is passed to the policy for exception retries. Each retry runs [attempt]
/// again so interceptors can run anew (e.g. refresh token).
Future<StreamedResponse> executeWithRetry({
  required RetryPolicy policy,
  required BaseRequest request,
  required Future<StreamedResponse> Function() attempt,
}) async {
  final totalAllowed = 1 + policy.maxRetryAttempts;
  int tries = 0;

  while (true) {
    tries++;
    try {
      final response = await attempt();
      final shouldRetry = await policy.shouldAttemptRetryOnResponse(response);
      if (!shouldRetry || tries >= totalAllowed) return response;
      await Future.delayed(
          policy.delayRetryAttemptOnResponse(retryAttempt: tries));
    } on Exception catch (e) {
      if (tries >= totalAllowed) rethrow;
      final shouldRetry =
          await policy.shouldAttemptRetryOnException(e, request);
      if (!shouldRetry) rethrow;
      await Future.delayed(
          policy.delayRetryAttemptOnException(retryAttempt: tries));
    }
  }
}
