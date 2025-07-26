import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('HttpInterceptorException', () {
    test('can be instantiated without a message', () {
      // Act
      final exception = HttpInterceptorException();

      // Assert
      expect(exception, isA<HttpInterceptorException>());
      expect(exception.message, isNull);
    });

    test('can be instantiated with a message', () {
      // Arrange
      const message = 'Test error message';

      // Act
      final exception = HttpInterceptorException(message);

      // Assert
      expect(exception, isA<HttpInterceptorException>());
      expect(exception.message, equals(message));
    });

    test('toString() returns "Exception" when message is null', () {
      // Arrange
      final exception = HttpInterceptorException();

      // Act
      final result = exception.toString();

      // Assert
      expect(result, equals('Exception'));
    });

    test('toString() returns "Exception: message" when message is provided',
        () {
      // Arrange
      const message = 'Test error message';
      final exception = HttpInterceptorException(message);

      // Act
      final result = exception.toString();

      // Assert
      expect(result, equals('Exception: $message'));
    });
  });
}
