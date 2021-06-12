import 'package:test/test.dart';
import 'package:http_interceptor/utils/utils.dart';

main() {
  group("buildUrlString", () {
    test("Adds parameters to a URL string without parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld";
      Map<String, dynamic> parameters = {"foo": "bar", "num": "0"};

      // Act
      String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(parameterUrl,
          equals("https://www.google.com/helloworld?foo=bar&num=0"));
    });
    test("Adds parameters to a URL string with parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld?foo=bar&num=0";
      Map<String, dynamic> parameters = {"extra": "1", "extra2": "anotherone"};

      // Act
      String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(
          parameterUrl,
          equals(
              "https://www.google.com/helloworld?foo=bar&num=0&extra=1&extra2=anotherone"));
    });
    test("Adds parameters with array to a URL string without parameters", () {
      // Arrange
      String url = "https://www.google.com/helloworld";
      Map<String, dynamic> parameters = {
        "foo": "bar",
        "num": ["0", "1"],
      };

      // Act
      String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(parameterUrl,
          equals("https://www.google.com/helloworld?foo=bar&num=0&num=1"));
    });
  });
}
