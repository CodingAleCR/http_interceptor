import 'dart:async';

import 'package:http/http.dart';

///Interceptor interface to create custom Interceptor for http.
///Extend this class and override the functions that you want
///to intercept.
///
///Intercepting: You have to implement two functions, `interceptRequest` and
///`interceptResponse`.
///
///Example (Simple logging):
///
///```dart
/// class LoggingInterceptor implements InterceptorContract {
///  @override
///  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
///    print(request.toString());
///    return data;
///  }
///
///  @override
///  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) async {
///      print(response.toString());
///      return data;
///  }
///
///}
///```
abstract class InterceptorContract {
  /// Checks if the request should be intercepted.
  FutureOr<bool> shouldInterceptRequest() => true;

  /// Intercepts the request.
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request});

  /// Checks if the response should be intercepted.
  FutureOr<bool> shouldInterceptResponse() => true;

  /// Intercepts the response.
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response});

  /// Checks if the error should be intercepted.
  FutureOr<bool> shouldInterceptError() => true;

  /// Intercepts the error response.
  FutureOr<void> interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) {
    // Default implementation does nothing
  }
}
