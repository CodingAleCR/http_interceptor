import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/utils.dart';

main() {
  group("addParametersToStringUrl", () {
    test("Adds parameters to a URL string without parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld";
      Map<String, String> parameters = {"foo": "bar", "num": "0"};

      // Act
      String parameterUrl = addParametersToStringUrl(url, parameters);

      // Assert
      expect(parameterUrl,
          equals("https://www.google.com/helloworld?foo=bar&num=0"));
    });
    test("Adds parameters to a URL string with parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld?foo=bar&num=0";
      Map<String, String> parameters = {"extra": "1", "extra2": "anotherone"};

      // Act
      String parameterUrl = addParametersToStringUrl(url, parameters);

      // Assert
      expect(
          parameterUrl,
          equals(
              "https://www.google.com/helloworld?foo=bar&num=0&extra=1&extra2=anotherone"));
    });
  });
  group("addParametersToUrl", () {
    test("Add parameters to Uri Url without parameters", () {
      // Arrange
      String stringUrl = "https://www.google.com/helloworld";
      Map<String, String> parameters = {"foo": "bar", "num": "0"};
      Uri url = Uri.parse(stringUrl);

      // Act
      Uri parameterUri = addParametersToUrl(url, parameters);

      // Assert
      Uri expectedUrl = Uri.https("www.google.com", "/helloworld", parameters);
      expect(parameterUri, equals(expectedUrl));
    });
    test("Add parameters to Uri Url with parameters", () {
      // Arrange
      String authority = "www.google.com";
      String unencodedPath = "/helloworld";
      Map<String, String> someParameters = {"foo": "bar"};
      Map<String, String> otherParameters = {"num": "0"};
      Uri url = Uri.https(authority, unencodedPath, someParameters);

      // Act
      Uri parameterUri = addParametersToUrl(url, otherParameters);

      // Assert
      Map<String, String> allParameters = {"foo": "bar", "num": "0"};
      Uri expectedUrl = Uri.https("www.google.com", "/helloworld", allParameters);
      expect(parameterUri, equals(expectedUrl));
    });
  });
}
