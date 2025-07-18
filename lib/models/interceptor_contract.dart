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
  FutureOr<bool> shouldInterceptRequest({
    required BaseRequest request,
  }) =>
      true;

  FutureOr<BaseRequest> interceptRequest({
    required BaseRequest request,
  });

  FutureOr<bool> shouldInterceptResponse({
    required BaseResponse response,
  }) =>
      true;

  FutureOr<BaseResponse> interceptResponse({
    required BaseResponse response,
  });
}
