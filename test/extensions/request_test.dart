import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  late BaseRequest baseRequest;
  late Request request;

  setUpAll(() {
    baseRequest = Request("GET", Uri.https("www.google.com", "/helloworld"))
      ..body = jsonEncode(<String, String>{'some_param': 'some value'});
    request = baseRequest as Request;
  });

  group('BaseRequest.copyWith: ', () {
    test('Request is copied from BaseRequest', () {
      // Arrange
      final copiedBaseRequest = baseRequest.copyWith();

      // Act
      final copied = copiedBaseRequest as Request;

      // Assert
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

  group('Request.copyWith:', () {
    test('Request is copied without differences', () {
      // Arrange

      // Act
      Request copied = request.copyWith();

      // Assert
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
    test('Request is copied with different URI', () {
      // Arrange
      Uri newUrl = Uri.https("www.google.com", "/foobar");

      // Act
      Request copied = request.copyWith(
        url: newUrl,
      );

      // Assert
      expect(
          copied.url,
          allOf([
            equals(newUrl),
            isNot(equals(request.url)),
          ]));
      expect(copied.method, equals(request.method));
      expect(copied.headers, equals(request.headers));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different method', () {
      // Arrange
      final newMethod = HttpMethod.POST;

      // Act
      Request copied = request.copyWith(
        method: newMethod,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(
          copied.method,
          allOf([
            equals(HttpMethod.POST.asString),
            isNot(equals(request.method)),
          ]));
      expect(copied.headers, equals(request.headers));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different headers', () {
      // Arrange
      final newHeaders = Map<String, String>.from(request.headers);
      newHeaders['Authorization'] = 'Bearer token';

      // Act
      Request copied = request.copyWith(
        headers: newHeaders,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(
          copied.headers,
          allOf([
            equals(newHeaders),
            isNot(equals(request.headers)),
          ]));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different headers', () {
      // Arrange
      final newHeaders = Map<String, String>.from(request.headers);
      newHeaders['Authorization'] = 'Bearer token';

      // Act
      Request copied = request.copyWith(
        headers: newHeaders,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(
          copied.headers,
          allOf([
            equals(newHeaders),
            isNot(equals(request.headers)),
          ]));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied overriding headers', () {
      // Arrange
      final newHeaders = Map<String, String>.from(request.headers);
      newHeaders['content-type'] = 'application/json; charset=utf-8';

      // Act
      Request copied = request.copyWith(
        headers: newHeaders,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(
          copied.headers,
          allOf([
            equals(newHeaders),
            isNot(equals(request.headers)),
          ]));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different body', () {
      // Arrange
      final newBody =
          jsonDecode(request.body.isNotEmpty ? request.body : '{}') as Map;
      newBody['hello'] = 'world';

      // Act
      Request copied = request.copyWith(
        body: jsonEncode(newBody),
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(copied.headers, equals(request.headers));
      expect(
          copied.body,
          allOf([
            equals(jsonEncode(newBody)),
            isNot(equals(request.body)),
          ]));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different encoding', () {
      // Arrange
      final newEncoding = Encoding.getByName('latin1');
      final changedHeaders = {'content-type': 'text/plain; charset=iso-8859-1'};

      // Act
      Request copied = request.copyWith(
        encoding: newEncoding,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(copied.headers.length, equals(request.headers.length));
      expect(copied.headers, equals(changedHeaders));
      expect(copied.body, equals(request.body));
      expect(
          copied.encoding,
          allOf([
            equals(newEncoding),
            isNot(equals(request.encoding)),
          ]));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different followRedirects', () {
      // Arrange
      final newFollowRedirects = false;

      // Act
      Request copied = request.copyWith(
        followRedirects: newFollowRedirects,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(copied.headers, equals(request.headers));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(
          copied.followRedirects,
          allOf([
            equals(newFollowRedirects),
            isNot(equals(request.followRedirects)),
          ]));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });
    test('Request is copied with different maxRedirects', () {
      // Arrange
      final newMaxRedirects = 2;

      // Act
      Request copied = request.copyWith(
        maxRedirects: newMaxRedirects,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(copied.headers, equals(request.headers));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(
          copied.maxRedirects,
          allOf([
            equals(newMaxRedirects),
            isNot(equals(request.maxRedirects)),
          ]));
      expect(copied.persistentConnection, equals(request.persistentConnection));
    });

    test('Request is copied with different persistentConnection', () {
      // Arrange
      final newPersistentConnection = false;

      // Act
      Request copied = request.copyWith(
        persistentConnection: newPersistentConnection,
      );

      // Assert
      expect(copied.url, equals(request.url));
      expect(copied.method, equals(request.method));
      expect(copied.headers, equals(request.headers));
      expect(copied.body, equals(request.body));
      expect(copied.encoding, equals(request.encoding));
      expect(copied.followRedirects, equals(request.followRedirects));
      expect(copied.maxRedirects, equals(request.maxRedirects));
      expect(
          copied.persistentConnection,
          allOf([
            equals(newPersistentConnection),
            isNot(equals(request.persistentConnection)),
          ]));
    });
  });
}
