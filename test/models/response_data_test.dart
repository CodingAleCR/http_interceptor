import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:http_interceptor/models/response_data.dart';

main() {
  group("Initialization", () {
    test("ResponseData can be instantiated", () {
      // Arrange
      ResponseData requestData;

      // Act
      requestData = ResponseData(bodyBytes: Uint8List(0));

      // Assert
      expect(requestData, isNotNull);
    });
  });
}
