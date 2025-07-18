import 'dart:async';

import 'package:http/http.dart';

/// Defines the behavior for retrying requests.
///
/// Example:
///
/// ```dart
/// class ExpiredTokenRetryPolicy extends RetryPolicy {
///   @override
///   int get maxRetryAttempts => 2;
///
///   @override
///   bool shouldAttemptRetryOnException(Exception reason, BaseRequest request) {
///     log(reason.toString());
///     log("Request URL: ${request.url}");
///
///     return false;
///   }
///
///   @override
///   Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
///     if (response.statusCode == 401) {
///       log("Retrying request...");
///       final cache = await SharedPreferences.getInstance();
///
///       cache.setString(kOWApiToken, OPEN_WEATHER_API_KEY);
///
///       return true;
///     }
///
///     return false;
///   }
/// }
/// ```
abstract class RetryPolicy {
  /// Defines whether the request should be retried when an Exception occurs
  /// while making said request to the server.
  ///
  /// [reason] - The exception that occurred during the request
  /// [request] - The original request that failed
  ///
  /// Returns `true` if the request should be retried, `false` otherwise.
  FutureOr<bool> shouldAttemptRetryOnException(
          Exception reason, BaseRequest request) =>
      false;

  /// Defines whether the request should be retried after the request has
  /// received `response` from the server.
  ///
  /// [response] - The response received from the server
  ///
  /// Returns `true` if the request should be retried, `false` otherwise.
  /// Common use cases include retrying on 401 (Unauthorized) or 500 (Server Error).
  FutureOr<bool> shouldAttemptRetryOnResponse(BaseResponse response) => false;

  /// Number of maximum request attempts that can be retried.
  ///
  /// Default is 1, meaning the original request plus 1 retry attempt.
  /// Set to 0 to disable retries, or higher values for more retry attempts.
  int get maxRetryAttempts => 1;

  /// Delay before retrying when an exception occurs.
  ///
  /// [retryAttempt] - The current retry attempt number (1-based)
  ///
  /// Returns the delay duration. Default is no delay (Duration.zero).
  /// Consider implementing exponential backoff for production use.
  Duration delayRetryAttemptOnException({required int retryAttempt}) =>
      Duration.zero;

  /// Delay before retrying when a response indicates retry is needed.
  ///
  /// [retryAttempt] - The current retry attempt number (1-based)
  ///
  /// Returns the delay duration. Default is no delay (Duration.zero).
  /// Consider implementing exponential backoff for production use.
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) =>
      Duration.zero;
}
