import 'package:test/test.dart';
import 'package:http_interceptor/extensions/string.extensions.dart';

void main() {
  group("toUri extension", () {
    test("Can convert string to https Uri", () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      // Act
      Uri convertedUri = stringUrl.toUri();
      // Assert
      Uri expectedUrl = Uri.https("www.google.com", "/helloworld");

      expect(convertedUri, equals(expectedUrl));
    });

    test("Can convert string to http Uri", () {
      // Arrange
      String stringUrl = "http://www.google.com/helloworld";
      // Act
      Uri convertedUri = stringUrl.toUri();
      // Assert
      Uri expectedUrl = Uri.http("www.google.com", "/helloworld");

      expect(convertedUri, equals(expectedUrl));
    });

    test("Can convert string to http Uri", () {
      // Arrange
      String stringUrl = "path/to/helloworld";
      // Act
      Uri convertedUri = stringUrl.toUri();
      // Assert
      Uri expectedUrl = Uri.file("path/to/helloworld");

      expect(convertedUri, equals(expectedUrl));
    });
  });
}
