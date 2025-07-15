import 'package:test/test.dart';
import 'package:http_interceptor/extensions/uri.dart';

void main() {
  group('URI Extensions', () {
    test('should handle basic URI operations', () {
      final uri = Uri.parse('https://example.com/path');

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.path, equals('/path'));
    });

    test('should handle URI with query parameters', () {
      final uri = Uri.parse('https://example.com/search?q=test&limit=10');

      expect(uri.queryParameters['q'], equals('test'));
      expect(uri.queryParameters['limit'], equals('10'));
    });

    test('should handle URI with fragment', () {
      final uri = Uri.parse('https://example.com/page#section');

      expect(uri.fragment, equals('section'));
    });

    test('should handle URI with port', () {
      final uri = Uri.parse('https://example.com:8080/api');

      expect(uri.port, equals(8080));
    });

    test('should handle URI with userinfo', () {
      final uri = Uri.parse('https://user:pass@example.com/secure');

      expect(uri.userInfo, equals('user:pass'));
    });

    test('should handle different schemes', () {
      final testUris = [
        Uri.parse('http://example.com'),
        Uri.parse('https://example.com'),
        Uri.parse('ftp://example.com'),
        Uri.parse('file:///path/to/file'),
      ];

      expect(testUris[0].scheme, equals('http'));
      expect(testUris[1].scheme, equals('https'));
      expect(testUris[2].scheme, equals('ftp'));
      expect(testUris[3].scheme, equals('file'));
    });

    test('should handle URI building', () {
      final uri = Uri(
        scheme: 'https',
        host: 'example.com',
        path: '/api/v1/users',
        queryParameters: {'page': '1', 'limit': '10'},
      );

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('example.com'));
      expect(uri.path, equals('/api/v1/users'));
      expect(uri.queryParameters['page'], equals('1'));
      expect(uri.queryParameters['limit'], equals('10'));
    });

    test('should handle URI resolution', () {
      final baseUri = Uri.parse('https://example.com/api/');
      final relativeUri = Uri.parse('users/123');
      final resolvedUri = baseUri.resolveUri(relativeUri);

      expect(
          resolvedUri.toString(), equals('https://example.com/api/users/123'));
    });

    test('should handle URI replacement', () {
      final originalUri = Uri.parse('https://example.com/old/path?param=value');
      final newUri = originalUri.replace(path: '/new/path');

      expect(newUri.path, equals('/new/path'));
      expect(newUri.queryParameters['param'], equals('value'));
      expect(newUri.scheme, equals('https'));
      expect(newUri.host, equals('example.com'));
    });

    test('should handle query parameter replacement', () {
      final originalUri = Uri.parse('https://example.com/api?page=1&limit=10');
      final newUri =
          originalUri.replace(queryParameters: {'page': '2', 'limit': '20'});

      expect(newUri.queryParameters['page'], equals('2'));
      expect(newUri.queryParameters['limit'], equals('20'));
    });

    test('should handle URI normalization', () {
      final uri = Uri.parse('https://EXAMPLE.COM/Path/../api/./users');
      final normalizedUri = uri.normalizePath();

      expect(normalizedUri.path, equals('/api/users'));
      expect(
          normalizedUri.host, equals('EXAMPLE.COM')); // Host case is preserved
    });

    test('should handle empty and null values', () {
      final uri = Uri.parse('https://example.com');

      expect(uri.path, equals(''));
      expect(uri.query, equals(''));
      expect(uri.fragment, equals(''));
      expect(uri.userInfo, equals(''));
    });

    test('should handle special characters in URI', () {
      final uri = Uri.parse(
          'https://example.com/path%20with%20spaces?param=value%20with%20spaces');

      expect(uri.path, equals('/path with spaces'));
      expect(uri.queryParameters['param'], equals('value with spaces'));
    });

    test('should handle international domain names', () {
      final uri = Uri.parse('https://例え.テスト/path');

      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('例え.テスト'));
      expect(uri.path, equals('/path'));
    });

    test('should handle data URIs', () {
      final uri = Uri.parse('data:text/plain;base64,SGVsbG8gV29ybGQ=');

      expect(uri.scheme, equals('data'));
      expect(uri.path, equals('text/plain;base64,SGVsbG8gV29ybGQ='));
    });

    test('should handle mailto URIs', () {
      final uri = Uri.parse('mailto:user@example.com?subject=Hello');

      expect(uri.scheme, equals('mailto'));
      expect(uri.path, equals('user@example.com'));
      expect(uri.queryParameters['subject'], equals('Hello'));
    });

    test('should handle tel URIs', () {
      final uri = Uri.parse('tel:+1234567890');

      expect(uri.scheme, equals('tel'));
      expect(uri.path, equals('+1234567890'));
    });

    test('should handle relative URIs', () {
      final uri = Uri.parse('/api/users');

      expect(uri.path, equals('/api/users'));
      expect(uri.scheme, equals(''));
      expect(uri.host, equals(''));
    });

    test('should handle query-only URIs', () {
      final uri = Uri.parse('?q=search&page=1');

      expect(uri.query, equals('q=search&page=1'));
      expect(uri.queryParameters['q'], equals('search'));
      expect(uri.queryParameters['page'], equals('1'));
    });

    test('should handle fragment-only URIs', () {
      final uri = Uri.parse('#section-1');

      expect(uri.fragment, equals('section-1'));
    });

    test('should handle URI encoding and decoding', () {
      final originalString = 'Hello World!';
      final encoded = Uri.encodeComponent(originalString);
      final decoded = Uri.decodeComponent(encoded);

      expect(encoded, equals('Hello%20World!'));
      expect(decoded, equals(originalString));
    });

    test('should handle URI equality', () {
      final uri1 = Uri.parse('https://example.com/path');
      final uri2 = Uri.parse('https://example.com/path');
      final uri3 = Uri.parse('https://example.com/different');

      expect(uri1, equals(uri2));
      expect(uri1, isNot(equals(uri3)));
    });

    test('should handle URI hash codes', () {
      final uri1 = Uri.parse('https://example.com/path');
      final uri2 = Uri.parse('https://example.com/path');
      final uri3 = Uri.parse('https://example.com/different');

      expect(uri1.hashCode, equals(uri2.hashCode));
      expect(uri1.hashCode, isNot(equals(uri3.hashCode)));
    });

    test('should handle URI toString', () {
      final uri = Uri.parse('https://example.com/path?q=test#section');

      expect(uri.toString(), equals('https://example.com/path?q=test#section'));
    });
  });
}
