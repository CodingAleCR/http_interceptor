import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/functions/initialize_io_client.dart';

main() {
  test("initializeClient can instantiate  IOClient", () {
    // Arrange
    Client client;

    // Act
    client = initializeClient(null, null);

    // Assert
    expect(client, isNotNull);
  });
}
