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
///   bool shouldAttemptRetryOnException(Exception reason) {
///     log(reason.toString());
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
  FutureOr<bool> shouldAttemptRetryOnException(
          Exception reason, BaseRequest request) =>
      false;

  /// Defines whether the request should be retried after the request has
  /// received `response` from the server.
  FutureOr<bool> shouldAttemptRetryOnResponse(BaseResponse response) => false;

  /// Number of maximum request attempts that can be retried.
  final int maxRetryAttempts = 1;

  Duration delayRetryAttemptOnException({required int retryAttempt}) =>
      Duration.zero;

  Duration delayRetryAttemptOnResponse({required int retryAttempt}) =>
      Duration.zero;
}
