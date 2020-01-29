import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/models/response_data.dart';

main() {
  group("Initialization", () {
    test("ResponseData can be instantiated", () {
      // Arrange
      ResponseData requestData;

      // Act
      requestData = ResponseData();

      // Assert
      expect(requestData, isNotNull);
    });
  });
}
