import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/src/extensions/request_extension.dart';
import 'package:test/test.dart';

void main() {
  group('CopyRequest', () {
    group('Request', () {
      test('copy produces an unfinalized duplicate', () {
        final original = Request('POST', Uri.parse('https://example.com/'))
          ..headers['authorization'] = 'Bearer token'
          ..bodyBytes = Uint8List.fromList([1, 2, 3])
          ..followRedirects = false
          ..maxRedirects = 3
          ..persistentConnection = false;

        final copy = original.copy() as Request;

        expect(copy.method, original.method);
        expect(copy.url, original.url);
        expect(copy.headers, original.headers);
        expect(copy.bodyBytes, original.bodyBytes);
        expect(copy.followRedirects, original.followRedirects);
        expect(copy.maxRedirects, original.maxRedirects);
        expect(copy.persistentConnection, original.persistentConnection);
        expect(copy.finalized, isFalse);
      });

      test('copy of a finalized request is still unfinalized', () async {
        final original = Request('GET', Uri.parse('https://example.com/'));
        original.finalize(); // marks it finalized

        expect(original.finalized, isTrue);

        final copy = original.copy() as Request;
        expect(copy.finalized, isFalse);
        // Should be sendable (finalize() should not throw).
        expect(() => copy.finalize(), returnsNormally);
      });

      test('copy is independent – mutating original does not affect copy', () {
        final original = Request('GET', Uri.parse('https://example.com/'))
          ..headers['x-custom'] = 'a';

        final copy = original.copy() as Request;
        original.headers['x-custom'] = 'changed';

        expect(copy.headers['x-custom'], 'a');
      });
    });

    group('MultipartRequest', () {
      test('copy produces an unfinalized duplicate', () {
        final original = MultipartRequest(
          'POST',
          Uri.parse('https://example.com/upload'),
        )
          ..fields['name'] = 'test'
          ..files.add(MultipartFile.fromBytes('file', [1, 2, 3]));

        final copy = original.copy() as MultipartRequest;

        expect(copy.method, original.method);
        expect(copy.url, original.url);
        expect(copy.fields, original.fields);
        expect(copy.files.length, original.files.length);
        expect(copy.finalized, isFalse);
      });
    });

    test('unsupported type throws UnsupportedError', () {
      final streamed = StreamedRequest(
        'PUT',
        Uri.parse('https://example.com/'),
      );
      expect(() => streamed.copy(), throwsUnsupportedError);
    });
  });
}
