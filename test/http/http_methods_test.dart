import 'package:test/test.dart';
import 'package:http_interceptor/http/http_methods.dart';

void main() {
  group('HttpMethod', () {
    test('should have all expected HTTP methods', () {
      final expectedMethods = [
        HttpMethod.HEAD,
        HttpMethod.GET,
        HttpMethod.POST,
        HttpMethod.PUT,
        HttpMethod.PATCH,
        HttpMethod.DELETE,
      ];

      expect(HttpMethod.values, containsAll(expectedMethods));
      expect(HttpMethod.values.length, equals(6));
    });

    group('StringToMethod Extension', () {
      test('should parse valid HTTP method strings', () {
        expect(StringToMethod.fromString('HEAD'), equals(HttpMethod.HEAD));
        expect(StringToMethod.fromString('GET'), equals(HttpMethod.GET));
        expect(StringToMethod.fromString('POST'), equals(HttpMethod.POST));
        expect(StringToMethod.fromString('PUT'), equals(HttpMethod.PUT));
        expect(StringToMethod.fromString('PATCH'), equals(HttpMethod.PATCH));
        expect(StringToMethod.fromString('DELETE'), equals(HttpMethod.DELETE));
      });

      test('should be case sensitive', () {
        expect(
          () => StringToMethod.fromString('get'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => StringToMethod.fromString('Post'),
          throwsArgumentError,
        );
      });

      test('should throw ArgumentError for invalid HTTP method strings', () {
        expect(() => StringToMethod.fromString('INVALID'), throwsArgumentError);

        try {
          StringToMethod.fromString('INVALID');
          fail('Should have thrown ArgumentError');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('INVALID'));
        }
      });

      test('should have meaningful error message', () {
        try {
          StringToMethod.fromString('INVALID');
          fail('Expected ArgumentError to be thrown');
        } catch (e) {
          expect(e, isA<ArgumentError>());
          expect(e.toString(), contains('Must be a valid HTTP Method'));
          expect(e.toString(), contains('INVALID'));
        }
      });

      test('should handle whitespace correctly', () {
        expect(
          () => StringToMethod.fromString(' GET '),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => StringToMethod.fromString('GET '),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => StringToMethod.fromString(' GET'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for empty string', () {
        expect(
          () => StringToMethod.fromString(''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for null string', () {
        expect(
          () => StringToMethod.fromString(null as dynamic),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('MethodToString Extension', () {
      test('should convert HTTP methods to strings', () {
        expect(HttpMethod.HEAD.asString, equals('HEAD'));
        expect(HttpMethod.GET.asString, equals('GET'));
        expect(HttpMethod.POST.asString, equals('POST'));
        expect(HttpMethod.PUT.asString, equals('PUT'));
        expect(HttpMethod.PATCH.asString, equals('PATCH'));
        expect(HttpMethod.DELETE.asString, equals('DELETE'));
      });

      test('should be consistent with StringToMethod', () {
        for (final method in HttpMethod.values) {
          final stringValue = method.asString;
          final parsedMethod = StringToMethod.fromString(stringValue);
          expect(parsedMethod, equals(method));
        }
      });

      test('should return uppercase strings', () {
        for (final method in HttpMethod.values) {
          final stringValue = method.asString;
          expect(stringValue, equals(stringValue.toUpperCase()));
          expect(stringValue, isNot(equals(stringValue.toLowerCase())));
        }
      });

      test('should not contain whitespace', () {
        for (final method in HttpMethod.values) {
          final stringValue = method.asString;
          expect(stringValue.trim(), equals(stringValue));
          expect(stringValue, isNot(contains(' ')));
          expect(stringValue, isNot(contains('\t')));
          expect(stringValue, isNot(contains('\n')));
        }
      });

      test('should not be empty', () {
        for (final method in HttpMethod.values) {
          final stringValue = method.asString;
          expect(stringValue, isNotEmpty);
          expect(stringValue.length, greaterThan(0));
        }
      });
    });

    group('Round-trip conversion', () {
      test('should maintain consistency in round-trip conversions', () {
        final testStrings = ['HEAD', 'GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

        for (final testString in testStrings) {
          final method = StringToMethod.fromString(testString);
          final backToString = method.asString;
          expect(backToString, equals(testString));
        }
      });

      test('should handle all enum values', () {
        for (final method in HttpMethod.values) {
          final stringValue = method.asString;
          final backToMethod = StringToMethod.fromString(stringValue);
          expect(backToMethod, equals(method));
        }
      });
    });

    group('Edge cases', () {
      test('should handle repeated conversions', () {
        const testMethod = HttpMethod.GET;

        for (int i = 0; i < 100; i++) {
          final stringValue = testMethod.asString;
          final parsedMethod = StringToMethod.fromString(stringValue);
          expect(parsedMethod, equals(testMethod));
        }
      });

      test('should be thread-safe for conversions', () {
        // Note: This is a basic test, real thread safety would require more complex testing
        final futures = <Future<void>>[];

        for (int i = 0; i < 10; i++) {
          futures.add(Future(() {
            for (final method in HttpMethod.values) {
              final stringValue = method.asString;
              final parsedMethod = StringToMethod.fromString(stringValue);
              expect(parsedMethod, equals(method));
            }
          }));
        }

        return Future.wait(futures);
      });
    });
  });
}
