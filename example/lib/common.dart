import 'dart:developer';

import 'package:http_interceptor/http_interceptor.dart';

class LoggerInterceptor extends InterceptorContract {
  @override
  BaseRequest interceptRequest({
    required BaseRequest request,
  }) {
    log('----- Request -----');
    log(request.toString());
    log(request.headers.toString());
    log('Request type: ${request.runtimeType}');
    return request;
  }

  @override
  BaseResponse interceptResponse({
    required BaseResponse response,
  }) {
    log('----- Response -----');
    log('Code: ${response.statusCode}');
    log('Response type: ${response.runtimeType}');
    if (response is Response) {
      log((response).body);
    }
    return response;
  }

  @override
  void interceptError({
    BaseRequest? request,
    BaseResponse? response,
    Exception? error,
    StackTrace? stackTrace,
  }) {
    log('----- Error -----');
    if (request != null) {
      log('Request: ${request.toString()}');
    }
    if (response != null) {
      log('Response: ${response.toString()}');
    }
    if (error != null) {
      log('Error: ${error.toString()}');
    }
    if (stackTrace != null) {
      log('StackTrace: $stackTrace');
    }
  }
}
