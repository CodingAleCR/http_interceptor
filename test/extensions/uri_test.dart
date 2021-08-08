import 'package:test/test.dart';
import 'package:http_interceptor/extensions/uri.extensions.dart';

void main() {
  group("addParameters extension", () {
    test("Add parameters to Uri without parameters", () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      Map<String, dynamic> parameters = {"foo": "bar", "num": "0"};
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
      Map<String, dynamic> someParameters = {"foo": "bar"};
      Map<String, dynamic> otherParameters = {"num": "0"};
      Uri url = Uri.https(authority, unencodedPath, someParameters);

      // Act
      Uri parameterUri = url.addParameters(otherParameters);

      // Assert
      Map<String, String> allParameters = {"foo": "bar", "num": "0"};
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", allParameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add parameters with array to Uri Url without parameters", () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      Map<String, dynamic> parameters = {
        "foo": "bar",
        "num": ["0", "1"],
      };
      Uri url = Uri.parse(stringUrl);

      // Act
      Uri parameterUri = url.addParameters(parameters);

      // Assert
      Uri expectedUrl = Uri.https("www.google.com", "/helloworld", parameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add parameters to Uri Url with array parameters", () {
      // Arrange
      String authority = "www.google.com";
      String unencodedPath = "/helloworld";
      Map<String, dynamic> someParameters = {
        "foo": ["bar", "bar1"],
      };
      Map<String, dynamic> otherParameters = {"num": "0"};
      Uri url = Uri.https(authority, unencodedPath, someParameters);

      // Act
      Uri parameterUri = url.addParameters(otherParameters);

      // Assert
      Map<String, dynamic> allParameters = {
        "foo": ["bar", "bar1"],
        "num": "0",
      };
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", allParameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add non-string parameters to Uri without parameters", () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      Map<String, dynamic> expectedParameters = {"foo": "bar", "num": "1"};
      Map<String, dynamic> parameters = {"foo": "bar", "num": 1};
      Uri url = Uri.parse(stringUrl);

      // Act
      Uri parameterUri = url.addParameters(parameters);

      // Assert
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", expectedParameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add non-string parameters to Uri with parameters", () {
      // Arrange
      String authority = "www.google.com";
      String unencodedPath = "/helloworld";
      Map<String, dynamic> someParameters = {"foo": "bar"};
      Map<String, dynamic> otherParameters = {"num": 0};
      Uri url = Uri.https(authority, unencodedPath, someParameters);

      // Act
      Uri parameterUri = url.addParameters(otherParameters);

      // Assert
      Map<String, String> allParameters = {"foo": "bar", "num": "0"};
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", allParameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add non-string parameters with array to Uri Url without parameters",
        () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      Map<String, dynamic> expectedParameters = {
        "foo": "bar",
        "num": ["0", "1"],
      };
      Map<String, dynamic> parameters = {
        "foo": "bar",
        "num": ["0", 1],
      };
      Uri url = Uri.parse(stringUrl);

      // Act
      Uri parameterUri = url.addParameters(parameters);

      // Assert
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", expectedParameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add non-string parameters to Uri Url with array parameters", () {
      // Arrange
      String authority = "www.google.com";
      String unencodedPath = "/helloworld";
      Map<String, dynamic> someParameters = {
        "foo": ["bar", "bar1"],
      };
      Map<String, dynamic> otherParameters = {
        "num": "0",
        "num2": 1,
        "num3": ["3", 2],
      };
      Uri url = Uri.https(authority, unencodedPath, someParameters);

      // Act
      Uri parameterUri = url.addParameters(otherParameters);

      // Assert
      Map<String, dynamic> expectedParameters = {
        "foo": ["bar", "bar1"],
        "num": "0",
        "num2": "1",
        "num3": ["3", "2"],
      };
      Uri expectedUrl =
          Uri.https("www.google.com", "/helloworld", expectedParameters);
      expect(parameterUri, equals(expectedUrl));
    });
  });
}
