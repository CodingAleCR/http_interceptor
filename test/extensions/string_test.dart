import 'package:test/test.dart';
import 'package:http_interceptor/extensions/string.dart';

void main() {
  group('ToURI Extension', () {
    test('should convert valid URL string to URI', () {
      const urlString = 'https://example.com';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.toString(), equals(urlString));
    });

    test('should convert URL with path to URI', () {
      const urlString = 'https://example.com/api/v1/users';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.path, equals('/api/v1/users'));
    });

    test('should convert URL with query parameters to URI', () {
      const urlString = 'https://example.com/search?q=test&limit=10';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.path, equals('/search'));
      expect(uri.queryParameters['q'], equals('test'));
      expect(uri.queryParameters['limit'], equals('10'));
    });

    test('should convert URL with fragment to URI', () {
      const urlString = 'https://example.com/page#section';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.path, equals('/page'));
      expect(uri.fragment, equals('section'));
    });

    test('should convert URL with port to URI', () {
      const urlString = 'https://example.com:8080/api';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.port, equals(8080));
      expect(uri.path, equals('/api'));
    });

    test('should convert URL with userinfo to URI', () {
      const urlString = 'https://user:pass@example.com/secure';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.userInfo, equals('user:pass'));
      expect(uri.path, equals('/secure'));
    });

    test('should handle different schemes', () {
      final testUrls = [
        'http://example.com',
        'https://example.com',
        'ftp://example.com',
        'file:///path/to/file',
      ];

      for (final urlString in testUrls) {
        final uri = urlString.toUri();
        expect(uri, isA<Uri>());
        expect(uri.toString(), equals(urlString));
      }
    });

    test('should handle complex query parameters', () {
      const urlString =
          'https://example.com/api?name=John%20Doe&age=30&tags=red,blue,green&special=!@#';
      final uri = urlString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.queryParameters['name'], equals('John Doe'));
      expect(uri.queryParameters['age'], equals('30'));
      expect(uri.queryParameters['tags'], equals('red,blue,green'));
      expect(uri.queryParameters['special'], equals('!@#'));
    });

    test('should handle most invalid URI strings without throwing', () {
      const invalidUrls = [
        'not a url',
        'ftp://invalid space',
      ];

      for (final invalidUrl in invalidUrls) {
        final uri = invalidUrl.toUri();
        expect(uri, isA<Uri>());
        // Uri.parse is lenient and doesn't throw for most invalid strings
        // It will create a URI object even for malformed strings
      }
    });

    test('should throw FormatException for severely malformed URIs', () {
      expect(
        () => 'http://[invalid'.toUri(),
        throwsA(isA<FormatException>()),
      );
    });

    test('should handle empty string', () {
      const emptyString = '';
      final uri = emptyString.toUri();

      expect(uri, isA<Uri>());
      expect(uri.toString(), equals(''));
    });

    test('should handle file URLs', () {
      const fileUrl = 'file:///home/user/document.txt';
      final uri = fileUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('file'));
      expect(uri.path, equals('/home/user/document.txt'));
    });

    test('should handle relative URLs', () {
      const relativeUrl = '/api/users';
      final uri = relativeUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.path, equals('/api/users'));
      expect(uri.scheme, isEmpty);
    });

    test('should handle query-only URLs', () {
      const queryUrl = '?q=search&page=1';
      final uri = queryUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.query, equals('q=search&page=1'));
      expect(uri.queryParameters['q'], equals('search'));
      expect(uri.queryParameters['page'], equals('1'));
    });

    test('should handle fragment-only URLs', () {
      const fragmentUrl = '#section-1';
      final uri = fragmentUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.fragment, equals('section-1'));
    });

    test('should handle URLs with encoded characters', () {
      const encodedUrl =
          'https://example.com/path%20with%20spaces?param=value%20with%20spaces';
      final uri = encodedUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.path, equals('/path with spaces'));
      expect(uri.queryParameters['param'], equals('value with spaces'));
    });

    test('should handle URLs with international domain names', () {
      const idnUrl = 'https://例え.テスト/path';
      final uri = idnUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('例え.テスト'));
      expect(uri.path, equals('/path'));
    });

    test('should handle URLs with multiple query parameters with same name',
        () {
      const multiParamUrl =
          'https://example.com/search?tag=red&tag=blue&tag=green';
      final uri = multiParamUrl.toUri();

      expect(uri, isA<Uri>());
      expect(uri.query, equals('tag=red&tag=blue&tag=green'));
      // Note: queryParameters only returns the last value for duplicate keys
      expect(uri.queryParameters['tag'], equals('green'));
    });

    test('should be consistent with Uri.parse', () {
      final testUrls = [
        'https://example.com',
        'http://example.com:8080/path?query=value#fragment',
        'mailto:user@example.com',
        'tel:+1234567890',
        'data:text/plain;base64,SGVsbG8gV29ybGQ=',
      ];

      for (final urlString in testUrls) {
        final uriFromExtension = urlString.toUri();
        final uriFromParse = Uri.parse(urlString);

        expect(uriFromExtension.toString(), equals(uriFromParse.toString()));
        expect(uriFromExtension.scheme, equals(uriFromParse.scheme));
        expect(uriFromExtension.host, equals(uriFromParse.host));
        expect(uriFromExtension.path, equals(uriFromParse.path));
        expect(uriFromExtension.query, equals(uriFromParse.query));
        expect(uriFromExtension.fragment, equals(uriFromParse.fragment));
      }
    });
  });
}
