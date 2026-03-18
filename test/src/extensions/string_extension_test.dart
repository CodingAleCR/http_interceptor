import 'package:http_interceptor/src/extensions/string_extension.dart';
import 'package:test/test.dart';

void main() {
  group('StringToUri', () {
    test('toUri parses string as Uri', () {
      // arrange
      const url = 'https://example.com/path?x=1';

      // act
      final uri = url.toUri();

      // assert
      expect(uri.scheme, 'https');
      expect(uri.host, 'example.com');
      expect(uri.path, '/path');
      expect(uri.queryParameters['x'], '1');
    });
  });
}
