import 'dart:async';

import 'package:http/http.dart';

/// Strategy for transforming HTTP requests and responses.
///
/// Implement this interface to add cross-cutting behavior (logging, auth
/// headers, error handling) without modifying the client. Interceptors
/// receive and return [BaseRequest]/[BaseResponse]; use in-place mutation
/// or return the same instance. Order of execution is the order in the list.
abstract interface class HttpInterceptor {
  /// Runs before the request is sent. Return the (possibly modified) request.
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request});

  /// Runs after the response is received. Return the (possibly modified) response.
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response});

  /// Whether to run [interceptRequest] for this request. Defaults to true.
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) => true;

  /// Whether to run [interceptResponse] for this response. Defaults to true.
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) =>
      true;
}
