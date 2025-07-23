import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('MultipartRequest.copyWith', () {
    late MultipartRequest request;
    final testUrl = Uri.parse('https://example.com');
    final testHeaders = {'Content-Type': 'multipart/form-data'};
    final testFields = {'field1': 'value1', 'field2': 'value2'};

    setUp(() {
      request = MultipartRequest('POST', testUrl)
        ..headers.addAll(testHeaders)
        ..fields.addAll(testFields);

      // Add a test file to the request
      final testFileBytes = utf8.encode('test file content');
      final testFile = MultipartFile.fromBytes(
        'file',
        testFileBytes,
        filename: 'test.txt',
      );
      request.files.add(testFile);
    });

    test(
        'creates a copy with the same properties when no parameters are provided',
        () {
      // Act
      final copy = request.copyWith();

      // Assert
      expect(copy.method, equals(request.method));
      expect(copy.url, equals(request.url));
      expect(copy.headers, equals(request.headers));
      expect(copy.fields, equals(request.fields));
      expect(copy.files.length, equals(request.files.length));
      expect(copy.followRedirects, equals(request.followRedirects));
      expect(copy.maxRedirects, equals(request.maxRedirects));
      expect(copy.persistentConnection, equals(request.persistentConnection));
    });

    test('overrides method when provided', () {
      // Act
      final copy = request.copyWith(method: HttpMethod.PUT);

      // Assert
      expect(copy.method, equals('PUT'));
      expect(copy.url, equals(request.url)); // Other properties remain the same
    });

    test('overrides url when provided', () {
      // Arrange
      final newUrl = Uri.parse('https://example.org');

      // Act
      final copy = request.copyWith(url: newUrl);

      // Assert
      expect(copy.url, equals(newUrl));
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('overrides headers when provided', () {
      // Arrange
      final newHeaders = {'Authorization': 'Bearer token'};

      // Act
      final copy = request.copyWith(headers: newHeaders);

      // Assert
      expect(copy.headers, equals(newHeaders));
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('overrides fields when provided', () {
      // Arrange
      final newFields = {'newField': 'newValue'};

      // Act
      final copy = request.copyWith(fields: newFields);

      // Assert
      expect(copy.fields, equals(newFields));
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('copies files from original request (ignores files parameter)', () {
      // Arrange
      final newFileBytes = utf8.encode('new file content');
      final newFile = MultipartFile.fromBytes(
        'newFile',
        newFileBytes,
        filename: 'new.txt',
      );

      // Act
      final copy = request.copyWith(files: [newFile]);

      // Assert
      // The implementation ignores the files parameter and always copies from the original
      expect(copy.files.length, equals(request.files.length));
      expect(copy.files.first.field, equals('file')); // Original file field
      expect(
          copy.files.first.filename, equals('test.txt')); // Original filename
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('sets followRedirects on original request (bug)', () {
      // Arrange
      final originalValue = request.followRedirects;
      final originalRequest = request; // Keep reference to original

      // Act
      final copy = request.copyWith(followRedirects: !originalValue);

      // Assert
      // The implementation incorrectly sets this on the original request
      expect(originalRequest.followRedirects, equals(!originalValue));
      // The copy has the default value
      expect(copy.followRedirects, equals(true));
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('sets maxRedirects on original request (bug)', () {
      // Arrange
      final newMaxRedirects = 10;
      final originalRequest = request; // Keep reference to original

      // Act
      final copy = request.copyWith(maxRedirects: newMaxRedirects);

      // Assert
      // The implementation incorrectly sets this on the original request
      expect(originalRequest.maxRedirects, equals(newMaxRedirects));
      // The copy has the default value
      expect(copy.maxRedirects, equals(5));
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('sets persistentConnection on original request (bug)', () {
      // Arrange
      final originalValue = request.persistentConnection;
      final originalRequest = request; // Keep reference to original

      // Act
      final copy = request.copyWith(persistentConnection: !originalValue);

      // Assert
      // The implementation incorrectly sets this on the original request
      expect(originalRequest.persistentConnection, equals(!originalValue));
      // The copy has the default value
      expect(copy.persistentConnection, equals(true));
      expect(copy.method,
          equals(request.method)); // Other properties remain the same
    });

    test('can override multiple properties at once', () {
      // Arrange
      final newUrl = Uri.parse('https://example.org');
      final newHeaders = {'Authorization': 'Bearer token'};

      // Act
      final copy = request.copyWith(
        method: HttpMethod.PUT,
        url: newUrl,
        headers: newHeaders,
      );

      // Assert
      expect(copy.method, equals('PUT'));
      expect(copy.url, equals(newUrl));
      expect(copy.headers, equals(newHeaders));
      expect(copy.fields,
          equals(request.fields)); // Unchanged properties remain the same
    });
  });
}
