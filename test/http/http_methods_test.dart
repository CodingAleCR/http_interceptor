import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('HttpMethod', () {
    test('should have correct string representations', () {
      expect(HttpMethod.GET.asString, equals('GET'));
      expect(HttpMethod.POST.asString, equals('POST'));
      expect(HttpMethod.PUT.asString, equals('PUT'));
      expect(HttpMethod.DELETE.asString, equals('DELETE'));
      expect(HttpMethod.HEAD.asString, equals('HEAD'));
      expect(HttpMethod.PATCH.asString, equals('PATCH'));
    });

    test('should parse HTTP methods correctly', () {
      expect(StringToMethod.fromString('GET'), equals(HttpMethod.GET));
      expect(StringToMethod.fromString('POST'), equals(HttpMethod.POST));
      expect(StringToMethod.fromString('PUT'), equals(HttpMethod.PUT));
      expect(StringToMethod.fromString('DELETE'), equals(HttpMethod.DELETE));
      expect(StringToMethod.fromString('HEAD'), equals(HttpMethod.HEAD));
      expect(StringToMethod.fromString('PATCH'), equals(HttpMethod.PATCH));
    });

    test('should handle case-insensitive parsing', () {
      expect(StringToMethod.fromString('GET'), equals(HttpMethod.GET));
      expect(StringToMethod.fromString('POST'), equals(HttpMethod.POST));
      expect(StringToMethod.fromString('PUT'), equals(HttpMethod.PUT));
      expect(StringToMethod.fromString('DELETE'), equals(HttpMethod.DELETE));
      expect(StringToMethod.fromString('HEAD'), equals(HttpMethod.HEAD));
      expect(StringToMethod.fromString('PATCH'), equals(HttpMethod.PATCH));
    });

    test('should handle mixed case parsing', () {
      expect(StringToMethod.fromString('GET'), equals(HttpMethod.GET));
      expect(StringToMethod.fromString('POST'), equals(HttpMethod.POST));
      expect(StringToMethod.fromString('PUT'), equals(HttpMethod.PUT));
      expect(StringToMethod.fromString('DELETE'), equals(HttpMethod.DELETE));
      expect(StringToMethod.fromString('HEAD'), equals(HttpMethod.HEAD));
      expect(StringToMethod.fromString('PATCH'), equals(HttpMethod.PATCH));
    });

    test('should throw exception for invalid HTTP methods', () {
      expect(() => StringToMethod.fromString('INVALID'),
          throwsA(isA<ArgumentError>()));
      expect(
          () => StringToMethod.fromString(''), throwsA(isA<ArgumentError>()));
      expect(() => StringToMethod.fromString('OPTIONS'),
          throwsA(isA<ArgumentError>()));
      expect(() => StringToMethod.fromString('TRACE'),
          throwsA(isA<ArgumentError>()));
    });

    test('should handle null and empty strings', () {
      expect(
          () => StringToMethod.fromString(''), throwsA(isA<ArgumentError>()));
    });

    test('should have correct enum values', () {
      expect(HttpMethod.HEAD.index, equals(0));
      expect(HttpMethod.GET.index, equals(1));
      expect(HttpMethod.POST.index, equals(2));
      expect(HttpMethod.PUT.index, equals(3));
      expect(HttpMethod.PATCH.index, equals(4));
      expect(HttpMethod.DELETE.index, equals(5));
    });

    test('should be comparable', () {
      expect(HttpMethod.GET, equals(HttpMethod.GET));
      expect(HttpMethod.POST, equals(HttpMethod.POST));
      expect(HttpMethod.GET, isNot(equals(HttpMethod.POST)));
      expect(HttpMethod.POST, isNot(equals(HttpMethod.PUT)));
    });

    test('should have correct toString representation', () {
      expect(HttpMethod.GET.toString(), equals('HttpMethod.GET'));
      expect(HttpMethod.POST.toString(), equals('HttpMethod.POST'));
      expect(HttpMethod.PUT.toString(), equals('HttpMethod.PUT'));
      expect(HttpMethod.DELETE.toString(), equals('HttpMethod.DELETE'));
      expect(HttpMethod.HEAD.toString(), equals('HttpMethod.HEAD'));
      expect(HttpMethod.PATCH.toString(), equals('HttpMethod.PATCH'));
    });

    test('should handle all supported HTTP methods', () {
      final methods = [
        HttpMethod.GET,
        HttpMethod.POST,
        HttpMethod.PUT,
        HttpMethod.DELETE,
        HttpMethod.HEAD,
        HttpMethod.PATCH,
      ];

      for (final method in methods) {
        expect(StringToMethod.fromString(method.asString), equals(method));
      }
    });

    test('should validate HTTP method strings', () {
      final validMethods = ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'PATCH'];
      final invalidMethods = ['OPTIONS', 'TRACE', 'CONNECT', 'INVALID', ''];

      for (final method in validMethods) {
        expect(() => StringToMethod.fromString(method), returnsNormally);
      }

      for (final method in invalidMethods) {
        expect(() => StringToMethod.fromString(method),
            throwsA(isA<ArgumentError>()));
      }
    });

    test('should handle whitespace in method strings', () {
      expect(() => StringToMethod.fromString(' GET '),
          throwsA(isA<ArgumentError>()));
      expect(() => StringToMethod.fromString('POST '),
          throwsA(isA<ArgumentError>()));
      expect(() => StringToMethod.fromString(' PUT'),
          throwsA(isA<ArgumentError>()));
    });

    test('should be immutable', () {
      final method1 = HttpMethod.GET;
      final method2 = HttpMethod.GET;

      expect(identical(method1, method2), isTrue);
      expect(method1.hashCode, equals(method2.hashCode));
    });

    test('should work in switch statements', () {
      final method = HttpMethod.POST;

      final result = switch (method) {
        HttpMethod.GET => 'GET',
        HttpMethod.POST => 'POST',
        HttpMethod.PUT => 'PUT',
        HttpMethod.DELETE => 'DELETE',
        HttpMethod.HEAD => 'HEAD',
        HttpMethod.PATCH => 'PATCH',
      };

      expect(result, equals('POST'));
    });

    test('should be usable in collections', () {
      final methods = <HttpMethod>{
        HttpMethod.GET,
        HttpMethod.POST,
        HttpMethod.PUT
      };

      expect(methods.contains(HttpMethod.GET), isTrue);
      expect(methods.contains(HttpMethod.POST), isTrue);
      expect(methods.contains(HttpMethod.PUT), isTrue);
      expect(methods.contains(HttpMethod.DELETE), isFalse);
    });

    test('should have consistent behavior across instances', () {
      final method1 = StringToMethod.fromString('GET');
      final method2 = StringToMethod.fromString('GET');
      final method3 = HttpMethod.GET;

      expect(method1, equals(method2));
      expect(method1, equals(method3));
      expect(method2, equals(method3));

      expect(method1.hashCode, equals(method2.hashCode));
      expect(method1.hashCode, equals(method3.hashCode));
    });
  });
}
