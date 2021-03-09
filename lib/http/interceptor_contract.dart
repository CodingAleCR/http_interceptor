import 'package:http_interceptor/models/models.dart';

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
///  Future<RequestData> interceptRequest({required RequestData data}) async {
///    print(data.toString());
///    return data;
///  }
///
///  @override
///  Future<ResponseData> interceptResponse({required ResponseData data}) async {
///      print(data.toString());
///      return data;
///  }
///
///}
///```
abstract class InterceptorContract {
  Future<RequestData> interceptRequest({required RequestData data});

  Future<ResponseData> interceptResponse({required ResponseData data});
}
