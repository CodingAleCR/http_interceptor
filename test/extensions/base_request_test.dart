import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  group('BaseRequest.copyWith: ', () {
    test('Request is copied from BaseRequest', () {
      // Arrange
      final BaseRequest baseRequest =
          Request("GET", Uri.https("www.google.com", "/helloworld"))
            ..body = jsonEncode(<String, String>{'some_param': 'some value'});
      final copiedBaseRequest = baseRequest.copyWith();

      // Act
      final copied = copiedBaseRequest as Request;

      // Assert
      final request = baseRequest as Request;
      expect(copied.hashCode, isNot(equals(request.hashCode)));
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(copied.headers, equals(request.headers));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
  });
}
