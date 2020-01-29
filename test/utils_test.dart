import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/utils.dart';

main() {
  group("addParametersToUrl", () {
    test("Adds parameters to a URL string without parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld";
      Map<String, String> parameters = {"foo": "bar", "num": "0"};

      // Act
      String parameterUrl = addParametersToUrl(url, parameters);

      // Assert
      expect(parameterUrl,
          equals("https://www.google.com/helloworld?foo=bar&num=0"));
    });
    test("Adds parameters to a URL string with parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld?foo=bar&num=0";
      Map<String, String> parameters = {"extra": "1", "extra2": "anotherone"};

      // Act
      String parameterUrl = addParametersToUrl(url, parameters);

      // Assert
      expect(
          parameterUrl,
          equals(
              "https://www.google.com/helloworld?foo=bar&num=0&extra=1&extra2=anotherone"));
    });
  });
}
