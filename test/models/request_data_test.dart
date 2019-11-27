import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/models/request_data.dart';
import 'package:http_interceptor/http_methods.dart';

main() {
  group("Initialization: ", () {
    test("can be instantiated", () {
      // Arrange
      RequestData requestData;

      // Act
      requestData = RequestData();

      // Assert
      expect(requestData, isNotNull);
    });
    test("can be instantiated from HTTP Request", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld");

      Request request = Request("GET", url);
      RequestData requestData;

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData, isNotNull);
      expect(requestData.method, equals(Method.GET));
      expect(requestData.url, equals("https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3"));
      expect(requestData.requestUrl, equals("https://www.google.com/helloworld"));
    });
  });
  group("Parsing request paramters: ", () {
    Uri url;
    Request request;
    RequestData requestData;
    setUpAll(() {
      url = Uri.parse(
          "https://www.google.com/helloword?key=123ABC&name=Hugo&type=3");
    });
    test("Can parse parameters from GET Request", () {
      // Arrange
      request = Request("GET", url);

      // Act
      requestData = RequestData.fromHttpRequest(request);

      // Assert
      expect(requestData.method, equals(Method.GET));

    });
  });
}
