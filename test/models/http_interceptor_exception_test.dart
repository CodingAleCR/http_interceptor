import 'package:test/test.dart';
import 'package:http_interceptor/models/http_interceptor_exception.dart';

void main() {
  group('HttpInterceptorException', () {
    test('should create exception with no message', () {
      final exception = HttpInterceptorException();
      
      expect(exception.message, isNull);
      expect(exception.toString(), equals('Exception'));
    });

    test('should create exception with string message', () {
      const message = 'Test error message';
      final exception = HttpInterceptorException(message);
      
      expect(exception.message, equals(message));
      expect(exception.toString(), equals('Exception: $message'));
    });

    test('should create exception with non-string message', () {
      const message = 42;
      final exception = HttpInterceptorException(message);
      
      expect(exception.message, equals(message));
      expect(exception.toString(), equals('Exception: $message'));
    });

    test('should create exception with null message', () {
      final exception = HttpInterceptorException(null);
      
      expect(exception.message, isNull);
      expect(exception.toString(), equals('Exception'));
    });

    test('should create exception with empty string message', () {
      const message = '';
      final exception = HttpInterceptorException(message);
      
      expect(exception.message, equals(message));
      expect(exception.toString(), equals('Exception: $message'));
    });

    test('should handle complex object as message', () {
      final messageObj = {'error': 'Something went wrong', 'code': 500};
      final exception = HttpInterceptorException(messageObj);
      
      expect(exception.message, equals(messageObj));
      expect(exception.toString(), contains('Exception: {error: Something went wrong, code: 500}'));
    });

    test('should be throwable', () {
      expect(() => throw HttpInterceptorException('Test error'), throwsException);
    });

    test('should be catchable as Exception', () {
      try {
        throw HttpInterceptorException('Test error');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e, isA<HttpInterceptorException>());
      }
    });
  });
}