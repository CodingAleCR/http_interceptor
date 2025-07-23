import 'dart:convert';

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

    test('MultipartRequest is copied from BaseRequest', () {
      // Arrange
      final testUrl = Uri.parse('https://example.com');
      final testHeaders = {'Content-Type': 'multipart/form-data'};
      final testFields = {'field1': 'value1', 'field2': 'value2'};

      final MultipartRequest multipartRequest = MultipartRequest('POST', testUrl)
        ..headers.addAll(testHeaders)
        ..fields.addAll(testFields);

      // Add a test file to the request
      final testFileBytes = utf8.encode('test file content');
      final testFile = MultipartFile.fromBytes(
        'file',
        testFileBytes,
        filename: 'test.txt',
      );
      multipartRequest.files.add(testFile);

      // Act
      final copied = multipartRequest.copyWith();

      // Assert
      expect(copied.hashCode, isNot(equals(multipartRequest.hashCode)));
      expect(copied.url, equals(multipartRequest.url));
      expect(copied.method, equals(multipartRequest.method));
      expect(copied.headers, equals(multipartRequest.headers));
      expect(copied.fields, equals(multipartRequest.fields));
      expect(copied.files.length, equals(multipartRequest.files.length));
    });

    test('throws UnsupportedError for unsupported request type', () {
      // Arrange
      final unsupportedRequest = _UnsupportedRequest();

      // Act & Assert
      expect(
        () => unsupportedRequest.copyWith(),
        throwsA(isA<UnsupportedError>().having(
          (e) => e.message,
          'message',
          'Cannot copy unsupported type of request _UnsupportedRequest',
        )),
      );
    });
  });
}

// Custom request type that doesn't extend any of the supported types
class _UnsupportedRequest extends BaseRequest {
  _UnsupportedRequest() : super('GET', Uri.parse('https://example.com'));
}
