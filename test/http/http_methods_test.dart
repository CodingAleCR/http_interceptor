import 'package:http_interceptor/http/http_methods.dart';
import 'package:test/test.dart';

main() {
  group("Can parse from string", () {
    test("with HEAD method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "HEAD";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.HEAD));
    });
    test("with GET method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "GET";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.GET));
    });
    test("with POST method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "POST";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.POST));
    });
    test("with PUT method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "PUT";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.PUT));
    });
    test("with PATCH method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "PATCH";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.PATCH));
    });
    test("with DELETE method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "DELETE";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.DELETE));
    });

    test("with OPTIONS method", () {
      // Arrange
      late final HttpMethod method;
      final String methodString = "OPTIONS";

      // Act
      method = HttpMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.OPTIONS));
    });
  });

  group("Can parse to string", () {
    test("to 'HEAD' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.HEAD;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("HEAD"));
    });
    test("to 'GET' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.GET;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("GET"));
    });
    test("to 'POST' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.POST;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("POST"));
    });
    test("to 'PUT' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.PUT;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("PUT"));
    });
    test("to 'PATCH' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.PATCH;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("PATCH"));
    });
    test("to 'DELETE' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.DELETE;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("DELETE"));
    });

    test("to 'OPTIONS' string.", () {
      // Arrange
      final String methodString;
      final HttpMethod method = HttpMethod.OPTIONS;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("OPTIONS"));
    });
  });

  group("Can control unsupported values", () {
    test("Throws when string is unsupported", () {
      // Arrange
      final String methodString = "UNSUPPORTED";

      // Act
      // Assert
      expect(
        () => HttpMethod.fromString(methodString),
        throwsArgumentError,
      );
    });
  });

  group("toString() method returns correct string representation", () {
    test("for HEAD method", () {
      // Arrange
      final HttpMethod method = HttpMethod.HEAD;

      // Act & Assert
      expect(method.toString(), equals("HEAD"));
    });

    test("for GET method", () {
      // Arrange
      final HttpMethod method = HttpMethod.GET;

      // Act & Assert
      expect(method.toString(), equals("GET"));
    });

    test("for POST method", () {
      // Arrange
      final HttpMethod method = HttpMethod.POST;

      // Act & Assert
      expect(method.toString(), equals("POST"));
    });

    test("for PUT method", () {
      // Arrange
      final HttpMethod method = HttpMethod.PUT;

      // Act & Assert
      expect(method.toString(), equals("PUT"));
    });

    test("for PATCH method", () {
      // Arrange
      final HttpMethod method = HttpMethod.PATCH;

      // Act & Assert
      expect(method.toString(), equals("PATCH"));
    });

    test("for DELETE method", () {
      // Arrange
      final HttpMethod method = HttpMethod.DELETE;

      // Act & Assert
      expect(method.toString(), equals("DELETE"));
    });

    test("for OPTIONS method", () {
      // Arrange
      final HttpMethod method = HttpMethod.OPTIONS;

      // Act & Assert
      expect(method.toString(), equals("OPTIONS"));
    });
  });
}
