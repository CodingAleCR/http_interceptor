import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/extensions/uri.extensions.dart';

void main() {
  group("addParameters extension", () {
    test("Add parameters to Uri without parameters", () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      Map<String, String> parameters = {"foo": "bar", "num": "0"};
      Uri url = Uri.parse(stringUrl);

      // Act
      Uri parameterUri = url.addParameters(parameters);

      // Assert
      Uri expectedUrl = Uri.https("www.google.com", "/helloworld", parameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add parameters to Uri with parameters", () {
      // Arrange
      String authority = "www.google.com";
      String unencodedPath = "/helloworld";
      Map<String, String> someParameters = {"foo": "bar"};
      Map<String, String> otherParameters = {"num": "0"};
      Uri url = Uri.https(authority, unencodedPath, someParameters);

      // Act
      Uri parameterUri = url.addParameters(otherParameters);

      // Assert
      Map<String, String> allParameters = {"foo": "bar", "num": "0"};
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", allParameters);
      expect(parameterUri, equals(expectedUrl));
    });
  });
}
