import 'package:http/http.dart';

import 'http_interceptor.dart';

/// Runs a list of [HttpInterceptor]s in order with guard clauses.
///
/// For each interceptor: if [shouldInterceptRequest]/[shouldInterceptResponse]
/// is false, the request/response is passed through unchanged; otherwise
/// [interceptRequest]/[interceptResponse] is called and the result is used
/// for the next interceptor.
class InterceptorChain {
  InterceptorChain(this._interceptors);

  final List<HttpInterceptor> _interceptors;

  /// Runs request interceptors in order. Returns the final request.
  Future<BaseRequest> runRequestInterceptors(BaseRequest request) async {
    BaseRequest current = request;
    for (final interceptor in _interceptors) {
      final shouldIntercept = await interceptor.shouldInterceptRequest(
        request: current,
      );
      if (!shouldIntercept) continue;
      current = await interceptor.interceptRequest(request: current);
    }
    return current;
  }

  /// Runs response interceptors in order. Returns the final response.
  Future<BaseResponse> runResponseInterceptors(BaseResponse response) async {
    BaseResponse current = response;
    for (final interceptor in _interceptors) {
      final shouldIntercept = await interceptor.shouldInterceptResponse(
        response: current,
      );
      if (!shouldIntercept) continue;
      current = await interceptor.interceptResponse(response: current);
    }
    return current;
  }
}
