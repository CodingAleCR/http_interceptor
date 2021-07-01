import 'package:test/test.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:http_interceptor/models/request_data.dart';

main() {
  group("Initialization: ", () {
    test("can be instantiated", () {
      // Arrange
      RequestData requestData;

      // Act
      requestData = RequestData(
          method: Method.GET, baseUrl: "https://www.google.com/helloworld");

      // Assert
      expect(requestData, isNotNull);
    });
    test("can be instantiated from HTTP GET Request", () {
      // Arrange
      Uri url = Uri.parse("https://www.google.com/helloworld");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(requestData.url, equals("https://www.google.com/helloworld"));
    });
    test("can be instantiated from HTTP GET Request with long path", () {
      // Arrange
      Uri url = Uri.parse("https://www.google.com/helloworld/foo/bar");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(
          requestData.url, equals("https://www.google.com/helloworld/foo/bar"));
    });
    test("can be instantiated from HTTP GET Request with parameters", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(requestData.baseUrl, equals("https://www.google.com/helloworld"));
      expect(
          requestData.url,
          equals(
              "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
    });
    test("can be instantiated from HTTP GET Request with multiple parameters with same key", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?name=Hugo&type=2&type=3&type=4");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(
          requestData.url,
          equals(
              "https://www.google.com/helloworld?name=Hugo&type=2&type=3&type=4"));
    });
    test("correctly creates the request URL string", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(
          requestData.url,
          equals(
              "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
    });
  });
}
