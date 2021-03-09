import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/functions/initialize_browser_client.dart';

main() {
  test("initializeClient can instantiate BrowserClient", () {
    // Arrange
    http.Client client;

    // Act
    client = initializeClient(null, null);

    // Assert
    expect(client, isNotNull);
  });
}
