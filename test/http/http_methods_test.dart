import 'package:http_interceptor/http/http_methods.dart';
import 'package:test/test.dart';

main() {
  group("Can parse from string", () {
    test("with HEAD method", () {
      // Arrange
      HttpMethod method;
      String methodString = "HEAD";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.HEAD));
    });
    test("with GET method", () {
      // Arrange
      HttpMethod method;
      String methodString = "GET";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.GET));
    });
    test("with POST method", () {
      // Arrange
      HttpMethod method;
      String methodString = "POST";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.POST));
    });
    test("with PUT method", () {
      // Arrange
      HttpMethod method;
      String methodString = "PUT";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.PUT));
    });
    test("with PATCH method", () {
      // Arrange
      HttpMethod method;
      String methodString = "PATCH";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.PATCH));
    });
    test("with DELETE method", () {
      // Arrange
      HttpMethod method;
      String methodString = "DELETE";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(HttpMethod.DELETE));
    });
  });

  group("Can parse to string", () {
    test("to 'HEAD' string.", () {
      // Arrange
      String methodString;
      HttpMethod method = HttpMethod.HEAD;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("HEAD"));
    });
    test("to 'GET' string.", () {
      // Arrange
      String methodString;
      HttpMethod method = HttpMethod.GET;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("GET"));
    });
    test("to 'POST' string.", () {
      // Arrange
      String methodString;
      HttpMethod method = HttpMethod.POST;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("POST"));
    });
    test("to 'PUT' string.", () {
      // Arrange
      String methodString;
      HttpMethod method = HttpMethod.PUT;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("PUT"));
    });
    test("to 'PATCH' string.", () {
      // Arrange
      String methodString;
      HttpMethod method = HttpMethod.PATCH;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("PATCH"));
    });
    test("to 'DELETE' string.", () {
      // Arrange
      String methodString;
      HttpMethod method = HttpMethod.DELETE;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("DELETE"));
    });
  });

  group("Can control unsupported values", () {
    test("Throws when string is unsupported", () {
      // Arrange
      String methodString = "UNSUPPORTED";

      // Act
      // Assert
      expect(
          () => StringToMethod.fromString(methodString), throwsArgumentError);
    });
  });
}
