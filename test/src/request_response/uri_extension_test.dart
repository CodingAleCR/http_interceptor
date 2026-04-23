import 'package:http_interceptor/src/extensions/uri_extension.dart';
import 'package:test/test.dart';

void main() {
  group('UriQueryParams', () {
    test('addQueryParams with params merges into empty', () {
      // arrange
      final uri = Uri.parse('https://example.com/path');

      // act
      final result = uri.addQueryParams(params: {'a': '1', 'b': '2'});

      // assert
      expect(result.queryParameters, {'a': '1', 'b': '2'});
    });

    test('addQueryParams with paramsAll adds multiple values per key', () {
      // arrange
      final uri = Uri.parse('https://example.com/path');

      // act
      final result = uri.addQueryParams(
        paramsAll: {
          'x': ['1', '2'],
          'y': ['3'],
        },
      );

      // assert
      expect(result.queryParametersAll['x'], ['1', '2']);
      expect(result.queryParametersAll['y'], ['3']);
    });

    test('addQueryParams merges with existing query', () {
      // arrange
      final uri = Uri.parse('https://example.com/path?foo=bar');

      // act
      final result = uri.addQueryParams(params: {'a': '1'});

      // assert
      expect(result.queryParameters['foo'], 'bar');
      expect(result.queryParameters['a'], '1');
    });

    test('addQueryParams with null params and paramsAll returns same uri', () {
      // arrange
      final uri = Uri.parse('https://example.com/path?x=1');

      // act
      final result = uri.addQueryParams();

      // assert
      expect(result, uri);
    });
  });
}
