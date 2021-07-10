import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:http_interceptor/models/response_data.dart';

main() {
  group("Initialization", () {
    test("ResponseData can be instantiated", () {
      // Arrange
      ResponseData responseData;

      // Act
      responseData = ResponseData(Uint8List(0), 200);

      // Assert
      expect(responseData, isNotNull);
    });

    test("ResponseData can be instantiated from HTTP Response", () {
      // Arrange
      final response = Response("Empty Body", 200);
      ResponseData responseData;

      // Act
      responseData = ResponseData.fromHttpResponse(response);

      // Assert
      expect(responseData, isNotNull);
    });
    test("ResponseData can all properties from HTTP Response", () {
      // Arrange
      Uri url = Uri.parse(
          "https://www.google.com/helloworld?key=123ABC&name=Hugo&type=3");

      Request request = Request("GET", url);
      Response response = Response("Empty Body", 200, request: request);
      ResponseData responseData;

      // Act
      responseData = ResponseData.fromHttpResponse(response);

      // Assert
      expect(responseData, isNotNull);
      expect(responseData.request, isNotNull);
      expect(responseData.body, isNotNull);
      expect(responseData.bodyBytes, isNotNull);
      expect(responseData.statusCode, isNotNull);
      expect(responseData.url, equals(response.request!.url.toString()));
      expect(responseData.isRedirect, equals(response.isRedirect));
      expect(responseData.persistentConnection,
          equals(response.persistentConnection));
      expect(responseData.headers, equals(response.headers));
    });
  });
}
