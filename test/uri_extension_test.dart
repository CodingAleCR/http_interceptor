import 'package:http_interceptor/src/request_response/uri_extension.dart';
import 'package:test/test.dart';

void main() {
  group('UriQueryParams', () {
    test('addQueryParams with params merges into empty', () {
      final uri = Uri.parse('https://example.com/path');
      final result = uri.addQueryParams(params: {'a': '1', 'b': '2'});
      expect(result.queryParameters, {'a': '1', 'b': '2'});
    });

    test('addQueryParams with paramsAll adds multiple values per key', () {
      final uri = Uri.parse('https://example.com/path');
      final result =
          uri.addQueryParams(paramsAll: {'x': ['1', '2'], 'y': ['3']});
      expect(result.queryParametersAll['x'], ['1', '2']);
      expect(result.queryParametersAll['y'], ['3']);
    });

    test('addQueryParams merges with existing query', () {
      final uri = Uri.parse('https://example.com/path?foo=bar');
      final result = uri.addQueryParams(params: {'a': '1'});
      expect(result.queryParameters['foo'], 'bar');
      expect(result.queryParameters['a'], '1');
    });

    test('addQueryParams with null params and paramsAll returns same uri', () {
      final uri = Uri.parse('https://example.com/path?x=1');
      final result = uri.addQueryParams();
      expect(result, uri);
    });
  });
}
