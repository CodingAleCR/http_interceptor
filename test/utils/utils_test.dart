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
    
    test("Properly encodes parameter keys to prevent injection", () {
      // Arrange
      String url = "https://www.google.com/helloworld";
      Map<String, dynamic> parameters = {
        "normal_key": "normal_value",
        "key&with=special": "value&with=special",
      };

      // Act
      String parameterUrl = buildUrlString(url, parameters);

      // Assert
      expect(parameterUrl, contains("normal_key=normal_value"));
      expect(parameterUrl, contains(Uri.encodeQueryComponent("key&with=special")));
      expect(parameterUrl, contains(Uri.encodeQueryComponent("value&with=special")));
      // Should not contain unencoded special characters that could cause injection
      expect(parameterUrl.split('?')[1], isNot(contains("&with=special&")));
    });
    
    test("Validates URL structure and throws error for invalid URLs", () {
      // Arrange
      String invalidUrl = "not a valid url";
      Map<String, dynamic> parameters = {"key": "value"};

      // Act & Assert
      expect(() => buildUrlString(invalidUrl, parameters), 
             throwsA(isA<ArgumentError>()));
    });
  });
}
