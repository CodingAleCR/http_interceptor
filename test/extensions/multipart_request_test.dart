import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  group('MultipartRequest.copyWith:', () {
    test('copies followRedirects to cloned request', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..followRedirects = true;

      // Act
      final copied = request.copyWith(followRedirects: false);

      // Assert
      expect(copied.followRedirects, equals(false));
    });

    test('copies maxRedirects to cloned request', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..maxRedirects = 5;

      // Act
      final copied = request.copyWith(maxRedirects: 10);

      // Assert
      expect(copied.maxRedirects, equals(10));
    });

    test('copies persistentConnection to cloned request', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..persistentConnection = true;

      // Act
      final copied = request.copyWith(persistentConnection: false);

      // Assert
      expect(copied.persistentConnection, equals(false));
    });

    test('does not mutate original request properties', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..followRedirects = true
        ..maxRedirects = 5
        ..persistentConnection = true;

      // Act
      request.copyWith(
        followRedirects: false,
        maxRedirects: 10,
        persistentConnection: false,
      );

      // Assert - original should be unchanged
      expect(request.followRedirects, equals(true));
      expect(request.maxRedirects, equals(5));
      expect(request.persistentConnection, equals(true));
    });

    test('preserves original values when no overrides provided', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..followRedirects = false
        ..maxRedirects = 3
        ..persistentConnection = false;

      // Act
      final copied = request.copyWith();

      // Assert
      expect(copied.followRedirects, equals(false));
      expect(copied.maxRedirects, equals(3));
      expect(copied.persistentConnection, equals(false));
    });

    test('uses provided files parameter instead of original files', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..files.add(MultipartFile.fromString('original', 'original content'));

      final newFiles = [
        MultipartFile.fromString('replacement', 'replacement content'),
      ];

      // Act
      final copied = request.copyWith(files: newFiles);

      // Assert
      expect(copied.files.length, equals(1));
      expect(copied.files.first.field, equals('replacement'));
    });

    test('copies original files when files parameter is not provided', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..files.add(MultipartFile.fromString('doc', 'file content'));

      // Act
      final copied = request.copyWith();

      // Assert
      expect(copied.files.length, equals(1));
      expect(copied.files.first.field, equals('doc'));
    });

    test('uses provided files with multiple files', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..files.add(MultipartFile.fromString('old1', 'old content 1'))
        ..files.add(MultipartFile.fromString('old2', 'old content 2'));

      final newFiles = [
        MultipartFile.fromString('new1', 'new content 1'),
        MultipartFile.fromString('new2', 'new content 2'),
        MultipartFile.fromString('new3', 'new content 3'),
      ];

      // Act
      final copied = request.copyWith(files: newFiles);

      // Assert
      expect(copied.files.length, equals(3));
      expect(copied.files[0].field, equals('new1'));
      expect(copied.files[1].field, equals('new2'));
      expect(copied.files[2].field, equals('new3'));
    });

    test('copies method and url', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'));

      // Act
      final copied = request.copyWith(
        method: HttpMethod.PUT,
        url: Uri.https('www.example.com', '/update'),
      );

      // Assert
      expect(copied.method, equals('PUT'));
      expect(copied.url, equals(Uri.https('www.example.com', '/update')));
    });

    test('copies headers', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..headers.addAll({'Authorization': 'Bearer token'});

      // Act
      final copied = request.copyWith();

      // Assert
      expect(copied.headers['Authorization'], equals('Bearer token'));
    });

    test('copies fields', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..fields.addAll({'name': 'test', 'value': '123'});

      // Act
      final copied = request.copyWith();

      // Assert
      expect(copied.fields['name'], equals('test'));
      expect(copied.fields['value'], equals('123'));
    });

    test('overrides fields when provided', () {
      // Arrange
      final request = MultipartRequest(
          'POST', Uri.https('www.example.com', '/upload'))
        ..fields.addAll({'name': 'test'});

      // Act
      final copied = request.copyWith(fields: {'name': 'overridden'});

      // Assert
      expect(copied.fields['name'], equals('overridden'));
    });
  });
}
