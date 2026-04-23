import 'package:http/http.dart';
import 'package:http_interceptor/src/interceptor/http_interceptor.dart';
import 'package:http_interceptor/src/interceptor/interceptor_chain.dart';
import 'package:test/test.dart';

void main() {
  group('InterceptorChain', () {
    test('runRequestInterceptors runs interceptors in order', () async {
      // arrange
      final request = Request('GET', Uri.parse('https://example.com/'));
      final order = <int>[];
      final chain = InterceptorChain([
        _Interceptor((r) {
          order.add(1);
          return r;
        }),
        _Interceptor((r) {
          order.add(2);
          return r;
        }),
      ]);

      // act
      await chain.runRequestInterceptors(request);

      // assert
      expect(order, [1, 2]);
    });

    test('runRequestInterceptors passes result of one to next', () async {
      // arrange
      final request = Request('GET', Uri.parse('https://example.com/'));
      final modified = Request('POST', Uri.parse('https://other.com/'));
      final chain = InterceptorChain([_Interceptor((_) => modified)]);

      // act
      final result = await chain.runRequestInterceptors(request);

      // assert
      expect(result.method, 'POST');
      expect(result.url.toString(), 'https://other.com/');
    });

    test(
      'runRequestInterceptors skips only that interceptor when shouldInterceptRequest is false',
      () async {
        // arrange
        final request = Request('GET', Uri.parse('https://example.com/'));
        var firstCalled = false;
        var secondCalled = false;
        final chain = InterceptorChain([
          _Interceptor((r) {
            firstCalled = true;
            return r;
          }, shouldInterceptRequest: () => false),
          _Interceptor((r) {
            secondCalled = true;
            return r;
          }),
        ]);

        // act
        await chain.runRequestInterceptors(request);

        // assert
        expect(firstCalled, false);
        expect(secondCalled, true);
      },
    );

    test('runResponseInterceptors runs interceptors in order', () async {
      // arrange
      final response = Response('body', 200);
      final order = <int>[];
      final chain = InterceptorChain([
        _Interceptor(
          (r) => r,
          onResponse: (res) {
            order.add(1);
            return res;
          },
        ),
        _Interceptor(
          (r) => r,
          onResponse: (res) {
            order.add(2);
            return res;
          },
        ),
      ]);

      // act
      await chain.runResponseInterceptors(response);

      // assert
      expect(order, [1, 2]);
    });

    test(
      'runResponseInterceptors skips only that interceptor when shouldInterceptResponse is false',
      () async {
        // arrange
        final response = Response('body', 200);
        var firstCalled = false;
        var secondCalled = false;
        final chain = InterceptorChain([
          _Interceptor(
            (r) => r,
            onResponse: (r) {
              firstCalled = true;
              return r;
            },
            shouldInterceptResponse: () => false,
          ),
          _Interceptor(
            (r) => r,
            onResponse: (res) {
              secondCalled = true;
              return res;
            },
          ),
        ]);

        // act
        await chain.runResponseInterceptors(response);

        // assert
        expect(firstCalled, false);
        expect(secondCalled, true);
      },
    );
  });
}

class _Interceptor implements HttpInterceptor {
  _Interceptor(
    this._onRequest, {
    this.onResponse,
    bool Function()? shouldInterceptRequest,
    bool Function()? shouldInterceptResponse,
  }) : _shouldRequest = shouldInterceptRequest,
       _shouldResponse = shouldInterceptResponse;

  final BaseRequest Function(BaseRequest) _onRequest;
  final BaseResponse Function(BaseResponse)? onResponse;
  final bool Function()? _shouldRequest;
  final bool Function()? _shouldResponse;

  @override
  BaseRequest interceptRequest({required BaseRequest request}) =>
      _onRequest(request);

  @override
  BaseResponse interceptResponse({required BaseResponse response}) =>
      onResponse != null ? onResponse!(response) : response;

  @override
  bool shouldInterceptRequest({required BaseRequest request}) =>
      _shouldRequest?.call() ?? true;

  @override
  bool shouldInterceptResponse({required BaseResponse response}) =>
      _shouldResponse?.call() ?? true;
}
