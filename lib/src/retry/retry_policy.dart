import 'dart:async';

import 'package:http/http.dart';

/// Strategy for when to retry a request (on exception or on response) and
/// how long to wait before each retry.
abstract interface class RetryPolicy {
  /// Maximum number of retry attempts (0 = no retries, 1 = one retry, etc.).
  int get maxRetryAttempts;

  /// Whether to retry after an [Exception] during the request.
  ///
  /// Return true to retry (subject to [maxRetryAttempts]); false to fail immediately.
  FutureOr<bool> shouldAttemptRetryOnException(
    Exception reason,
    BaseRequest request,
  );

  /// Whether to retry after receiving [response].
  ///
  /// Return true to retry (e.g. 401 refresh token); false to return the response.
  FutureOr<bool> shouldAttemptRetryOnResponse(BaseResponse response);

  /// Delay before retrying after an exception. [retryAttempt] is 1-based.
  Duration delayRetryAttemptOnException({required int retryAttempt}) =>
      Duration.zero;

  /// Delay before retrying after a response. [retryAttempt] is 1-based.
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) =>
      Duration.zero;
}
