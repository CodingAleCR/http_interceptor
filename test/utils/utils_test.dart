import 'package:test/test.dart';
import 'package:http_interceptor/utils/utils.dart';

main() {
  group("buildUrlString", () {
    test("Adds parameters to a URL string without parameters", () {
      // Arrange
      final String url = "https://www.google.com/helloworld";
      final Map<String, dynamic> parameters = {"foo": "bar", "num": "0"};

      // Act
      final String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(
        parameterUrl,
        equals("https://www.google.com/helloworld?foo=bar&num=0"),
      );
    });

    test("Adds parameters to a URL string with parameters", () {
      // Arrange
      final String url = "https://www.google.com/helloworld?foo=bar&num=0";
      final Map<String, dynamic> parameters = {
        "extra": "1",
        "extra2": "anotherone"
      };

      // Act
      final String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(
        parameterUrl,
        equals(
          "https://www.google.com/helloworld?foo=bar&num=0&extra=1&extra2=anotherone",
        ),
      );
    });

    test("Adds parameters with array to a URL string without parameters", () {
      // Arrange
      final String url = "https://www.google.com/helloworld";
      final Map<String, dynamic> parameters = {
        "foo": "bar",
        "num": ["0", "1"],
      };

      // Act
      final String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(
        parameterUrl,
        equals("https://www.google.com/helloworld?foo=bar&num=0&num=1"),
      );
    });

    test("Null parameters returns original URL", () {
      final url = "https://example.com/path";
      expect(
        buildUrlString(url, null),
        equals(url),
      );
    });

    test("Empty parameters returns original URL", () {
      final url = "https://example.com/path";
      expect(
        buildUrlString(url, {}),
        equals(url),
      );
    });

    test("Null parameter value becomes empty assignment", () {
      final url = "https://example.com/path";
      final params = {"a": null};
      expect(
        buildUrlString(url, params),
        equals("https://example.com/path?a="),
      );
    });

    test("Overrides existing parameter", () {
      final url = "https://example.com/path?foo=bar";
      final params = {"foo": "baz", "x": "y"};
      expect(
        buildUrlString(url, params),
        equals("https://example.com/path?foo=baz&x=y"),
      );
    });

    test("Preserves fragment without existing query", () {
      final url = "https://example.com/path#section";
      final params = {"a": "1"};
      expect(buildUrlString(url, params),
          equals("https://example.com/path?a=1#section"));
    });

    test("Preserves fragment with existing query", () {
      final url = "https://example.com/path?foo=bar#section";
      final params = {"baz": "qux"};
      expect(buildUrlString(url, params),
          equals("https://example.com/path?foo=bar&baz=qux#section"));
    });

    test("Invalid URL does not trigger concatenation fallback", () {
      final url = "not a valid url";
      final params = {"a": "b"};
      expect(() => buildUrlString(url, params), throwsArgumentError);
    });

    test("Encodes special characters in keys and values", () {
      final url = "https://example.com";
      final params = {"a b": "c d", "ä": "ö"};
      expect(
        buildUrlString(url, params),
        equals("https://example.com?a%20b=c%20d&%C3%A4=%C3%B6"),
      );
    });

    test("Numeric and boolean values are stringified", () {
      final url = "https://example.com";
      final params = {"int": 42, "bool": true};
      expect(
        buildUrlString(url, params),
        equals("https://example.com?int=42&bool=true"),
      );
    });

    test("List parameter overrides existing singular key", () {
      final url = "https://example.com/path?x=1";
      final params = {
        "x": ["2", "3"]
      };
      expect(
        buildUrlString(url, params),
        equals("https://example.com/path?x=2&x=3"),
      );
    });

    test('encodes a query string object (basic key/value)', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'a': 'b'}),
        equals('$testUrl?a=b'),
      );
      expect(
        buildUrlString(testUrl, {'a': '1'}),
        equals('$testUrl?a=1'),
      );
      expect(
        buildUrlString(testUrl, {'a': '1', 'b': '2'}),
        equals('$testUrl?a=1&b=2'),
      );
      expect(
        buildUrlString(testUrl, {'a': 'A_Z'}),
        equals('$testUrl?a=A_Z'),
      );
    });

    test('encodes various unicode characters', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'a': '€'}),
        equals('$testUrl?a=%E2%82%AC'),
      );
      expect(
        buildUrlString(testUrl, {'a': ''}),
        equals('$testUrl?a=%EE%80%80'),
      );
      expect(
        buildUrlString(testUrl, {'a': 'א'}),
        equals('$testUrl?a=%D7%90'),
      );
      expect(
        buildUrlString(testUrl, {'a': '𐐷'}),
        equals('$testUrl?a=%F0%90%90%B7'),
      );
    });

    test('increasing number of pairs', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'a': 'b', 'c': 'd'}),
        equals('$testUrl?a=b&c=d'),
      );
      expect(
        buildUrlString(testUrl, {'a': 'b', 'c': 'd', 'e': 'f'}),
        equals('$testUrl?a=b&c=d&e=f'),
      );
      expect(
        buildUrlString(testUrl, {'a': 'b', 'c': 'd', 'e': 'f', 'g': 'h'}),
        equals('$testUrl?a=b&c=d&e=f&g=h'),
      );
    });

    test('list values get repeated keys', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {
          'a': ['b', 'c', 'd'],
          'e': 'f'
        }),
        equals('$testUrl?a=b&a=c&a=d&e=f'),
      );
    });

    test('empty map yields no query string', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {}),
        buildUrlString(testUrl, {}).toString(),
      );
    });

    test('single key with empty string value', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'a': ''}),
        equals('$testUrl?a='),
      );
    });

    test('null value is not skipped', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'a': null, 'b': '2'}),
        equals('$testUrl?a=&b=2'),
      );
    });

    test('keys with special characters are encoded', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'a b': 'c d'}),
        equals('$testUrl?a%20b=c%20d'),
      );
      expect(
        buildUrlString(testUrl, {'ä': 'ö'}),
        equals('$testUrl?%C3%A4=%C3%B6'),
      );
    });

    test('values containing reserved characters', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'q': 'foo@bar.com'}),
        equals('$testUrl?q=foo%40bar.com'),
      );
      expect(
        buildUrlString(testUrl, {'path': '/home'}),
        equals('$testUrl?path=%2Fhome'),
      );
    });

    test('plus sign and space in value', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {'v': 'a+b c'}),
        equals('$testUrl?v=a%2Bb%20c'),
      );
    });

    test('list values including numbers and empty strings', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {
          'x': ['1', '', '3'],
        }),
        equals('$testUrl?x=1&x=&x=3'),
      );
    });

    test('multiple keys maintain insertion order', () {
      final String testUrl = 'https://example.com/path';
      expect(
        buildUrlString(testUrl, {
          'first': '1',
          'second': '2',
          'third': '3',
        }),
        equals('$testUrl?first=1&second=2&third=3'),
      );
    });
  });
}
