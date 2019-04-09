import 'package:http_interceptor/models/models.dart';

///Middleware interface to create custom middleware for http.
///Extend this class and override the functions that you want
///to intercept.
///
///Intercepting: You have to implement two functions, `interceptRequest` and
///`interceptResponse`.
///
///Example (Simple logging):
///
///```dart
///class CustomMiddleWare extends MiddlewareContract {
///    @override
///    Function(http.Response) interceptRequest({RequestData data}) {
///        print("${data.method} Url: ${data.url}")
///        return (response) {
///            print("POST Status: ${}")
///        };
///    }
///
///    @override
///    Function(http.Response) interceptResponse({ResponseData data}) {
///        print("${data.method}: ${response}")
///        return (response) {
///            print("POST Status: ${}")
///        };
///    }
///}
///```
abstract class MiddlewareContract {
  Future<RequestData> interceptRequest({RequestData data});

  Future<ResponseData> interceptResponse({ResponseData data});
}
