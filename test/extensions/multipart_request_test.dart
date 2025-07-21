import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

void main() {
  group('MultipartRequest Extension', () {
    test('should copy multipart request without modifications', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field1'] = 'value1';
      originalRequest.fields['field2'] = 'value2';

      final textFile = MultipartFile.fromString(
        'file1',
        'file content',
        filename: 'test.txt',
      );
      originalRequest.files.add(textFile);

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.files.length, equals(originalRequest.files.length));
      expect(copiedRequest.headers, equals(originalRequest.headers));
      expect(copiedRequest.followRedirects,
          equals(originalRequest.followRedirects));
      expect(copiedRequest.maxRedirects, equals(originalRequest.maxRedirects));
      expect(copiedRequest.persistentConnection,
          equals(originalRequest.persistentConnection));
    });

    test('should copy multipart request with different method', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field1'] = 'value1';

      final copiedRequest = originalRequest.copyWith(method: HttpMethod.PUT);

      expect(copiedRequest.method, equals('PUT'));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
    });

    test('should copy multipart request with different URL', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field1'] = 'value1';

      final newUrl = Uri.parse('https://example.com/new-upload');
      final copiedRequest = originalRequest.copyWith(url: newUrl);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(newUrl));
      expect(copiedRequest.fields, equals(originalRequest.fields));
    });

    test('should copy multipart request with different headers', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.headers['Content-Type'] = 'multipart/form-data';
      originalRequest.fields['field1'] = 'value1';

      final newHeaders = {'Authorization': 'Bearer token', 'X-Custom': 'value'};
      final copiedRequest = originalRequest.copyWith(headers: newHeaders);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(newHeaders));
      expect(copiedRequest.fields, equals(originalRequest.fields));
    });

    test('should copy multipart request with different fields', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field1'] = 'value1';
      originalRequest.fields['field2'] = 'value2';

      final newFields = {
        'new_field': 'new_value',
        'another_field': 'another_value'
      };
      final copiedRequest = originalRequest.copyWith(fields: newFields);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(newFields));
    });

    test('should copy multipart request with different files', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field1'] = 'value1';

      final originalFile = MultipartFile.fromString(
        'file1',
        'original content',
        filename: 'original.txt',
      );
      originalRequest.files.add(originalFile);

      final newFiles = [
        MultipartFile.fromString(
          'new_file',
          'new content',
          filename: 'new.txt',
        ),
        MultipartFile.fromBytes(
          'binary_file',
          [1, 2, 3, 4],
          filename: 'binary.bin',
        ),
      ];

      final copiedRequest = originalRequest.copyWith(files: newFiles);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.files.length, equals(newFiles.length));
    });

    test('should copy multipart request with different followRedirects', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.followRedirects = true;
      originalRequest.fields['field1'] = 'value1';

      final copiedRequest = originalRequest.copyWith(followRedirects: false);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.followRedirects, equals(false));
    });

    test('should copy multipart request with different maxRedirects', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.maxRedirects = 5;
      originalRequest.fields['field1'] = 'value1';

      final copiedRequest = originalRequest.copyWith(maxRedirects: 10);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.maxRedirects, equals(10));
    });

    test('should copy multipart request with different persistentConnection',
        () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.persistentConnection = true;
      originalRequest.fields['field1'] = 'value1';

      final copiedRequest =
          originalRequest.copyWith(persistentConnection: false);

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.persistentConnection, equals(false));
    });

    test('should copy multipart request with multiple modifications', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.headers['Content-Type'] = 'multipart/form-data';
      originalRequest.fields['field1'] = 'value1';
      originalRequest.followRedirects = true;
      originalRequest.maxRedirects = 5;
      originalRequest.persistentConnection = true;

      final newUrl = Uri.parse('https://example.com/new-upload');
      final newHeaders = {'Authorization': 'Bearer token'};
      final newFields = {'new_field': 'new_value'};
      final newFiles = [
        MultipartFile.fromString(
          'new_file',
          'new content',
          filename: 'new.txt',
        ),
      ];

      final copiedRequest = originalRequest.copyWith(
        method: HttpMethod.PUT,
        url: newUrl,
        headers: newHeaders,
        fields: newFields,
        files: newFiles,
        followRedirects: false,
        maxRedirects: 10,
        persistentConnection: false,
      );

      expect(copiedRequest.method, equals('PUT'));
      expect(copiedRequest.url, equals(newUrl));
      expect(copiedRequest.headers, equals(newHeaders));
      expect(copiedRequest.fields, equals(newFields));
      expect(copiedRequest.files.length, equals(newFiles.length));
      expect(copiedRequest.followRedirects, equals(false));
      expect(copiedRequest.maxRedirects, equals(10));
      expect(copiedRequest.persistentConnection, equals(false));
    });

    test('should copy multipart request with complex files', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['description'] = 'Complex files test';

      // Add different types of files
      final textFile = MultipartFile.fromString(
        'text_file',
        'Text file content',
        filename: 'text.txt',
        contentType: MediaType('text', 'plain'),
      );
      originalRequest.files.add(textFile);

      final jsonFile = MultipartFile.fromString(
        'json_file',
        '{"key": "value", "number": 42}',
        filename: 'data.json',
        contentType: MediaType('application', 'json'),
      );
      originalRequest.files.add(jsonFile);

      final binaryFile = MultipartFile.fromBytes(
        'binary_file',
        [1, 2, 3, 4, 5],
        filename: 'data.bin',
        contentType: MediaType('application', 'octet-stream'),
      );
      originalRequest.files.add(binaryFile);

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.files.length, equals(originalRequest.files.length));

      // Verify file properties are copied correctly
      for (int i = 0; i < originalRequest.files.length; i++) {
        final originalFile = originalRequest.files[i];
        final copiedFile = copiedRequest.files[i];

        expect(copiedFile.field, equals(originalFile.field));
        expect(copiedFile.filename, equals(originalFile.filename));
        expect(copiedFile.contentType, equals(originalFile.contentType));
        expect(copiedFile.length, equals(originalFile.length));
      }
    });

    test('should copy multipart request with special characters in fields', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field with spaces'] = 'value with spaces';
      originalRequest.fields['field&with=special'] = 'value&with=special';
      originalRequest.fields['field+with+plus'] = 'value+with+plus';
      originalRequest.fields['field_with_unicode'] = 'café 🚀 你好';

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
    });

    test('should copy multipart request with empty fields and files', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.files.length, equals(originalRequest.files.length));
    });

    test('should copy multipart request with large files', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['description'] = 'Large file test';

      // Create a large text file (1KB)
      final largeContent = 'A' * 1024;
      final largeFile = MultipartFile.fromString(
        'large_file',
        largeContent,
        filename: 'large.txt',
      );
      originalRequest.files.add(largeFile);

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.fields, equals(originalRequest.fields));
      expect(copiedRequest.files.length, equals(originalRequest.files.length));

      final copiedFile = copiedRequest.files.first;
      expect(copiedFile.field, equals(largeFile.field));
      expect(copiedFile.filename, equals(largeFile.filename));
      expect(copiedFile.length, equals(largeFile.length));
    });

    test('should copy multipart request with different HTTP methods', () {
      final methods = [
        HttpMethod.GET,
        HttpMethod.POST,
        HttpMethod.PUT,
        HttpMethod.PATCH,
        HttpMethod.DELETE
      ];

      for (final method in methods) {
        final originalRequest = MultipartRequest(
            method.asString, Uri.parse('https://example.com/upload'));
        originalRequest.fields['field1'] = 'value1';

        final copiedRequest = originalRequest.copyWith();

        expect(copiedRequest.method, equals(method.asString));
        expect(copiedRequest.url, equals(originalRequest.url));
        expect(copiedRequest.fields, equals(originalRequest.fields));
      }
    });

    test('should copy multipart request with custom headers', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.headers['Content-Type'] =
          'multipart/form-data; boundary=----WebKitFormBoundary';
      originalRequest.headers['Authorization'] = 'Bearer custom-token';
      originalRequest.headers['X-Custom-Header'] = 'custom-value';
      originalRequest.fields['field1'] = 'value1';

      final copiedRequest = originalRequest.copyWith();

      expect(copiedRequest.method, equals(originalRequest.method));
      expect(copiedRequest.url, equals(originalRequest.url));
      expect(copiedRequest.headers, equals(originalRequest.headers));
      expect(copiedRequest.fields, equals(originalRequest.fields));
    });

    test('should not modify original request when using copyWith', () {
      final originalRequest =
          MultipartRequest('POST', Uri.parse('https://example.com/upload'));
      originalRequest.fields['field1'] = 'value1';
      originalRequest.followRedirects = true;
      originalRequest.maxRedirects = 5;
      originalRequest.persistentConnection = true;

      final copiedRequest = originalRequest.copyWith(
        method: HttpMethod.PUT,
        followRedirects: false,
        maxRedirects: 10,
        persistentConnection: false,
      );

      // Verify the copied request has the new values
      expect(copiedRequest.method, equals('PUT'));
      expect(copiedRequest.followRedirects, equals(false));
      expect(copiedRequest.maxRedirects, equals(10));
      expect(copiedRequest.persistentConnection, equals(false));

      // Verify the original request remains unchanged
      expect(originalRequest.method, equals('POST'));
      expect(originalRequest.followRedirects, equals(true));
      expect(originalRequest.maxRedirects, equals(5));
      expect(originalRequest.persistentConnection, equals(true));
      expect(originalRequest.fields, equals({'field1': 'value1'}));
    });
  });
}
