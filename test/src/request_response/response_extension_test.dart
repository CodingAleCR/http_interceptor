import 'package:http/http.dart';
import 'package:http_interceptor/src/extensions/response_extension.dart';
import 'package:test/test.dart';

void main() {
  group('ResponseBodyDecoding', () {
    test('jsonBody returns null for empty body', () {
      // arrange
      final res = Response('', 200);

      // act
      final decoded = res.jsonBody;

      // assert
      expect(decoded, isNull);
    });

    test('jsonBody decodes JSON object', () {
      // arrange
      final res = Response('{"a":1}', 200);

      // act
      final decoded = res.jsonBody;

      // assert
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded, {'a': 1});
    });

    test('jsonBody decodes JSON array', () {
      // arrange
      final res = Response('[1,2,3]', 200);

      // act
      final decoded = res.jsonBody;

      // assert
      expect(decoded, [1, 2, 3]);
    });

    test('jsonMap decodes JSON object', () {
      // arrange
      final res = Response('{"a":1}', 200);

      // act
      final decoded = res.jsonMap;

      // assert
      expect(decoded, {'a': 1});
    });

    test('jsonMap throws when JSON is an array', () {
      // arrange
      final res = Response('[1,2,3]', 200);

      // act
      Map<String, dynamic> act() => res.jsonMap;

      // assert
      expect(act, throwsA(isA<TypeError>()));
    });

    test('jsonList decodes JSON array', () {
      // arrange
      final res = Response('[1,2,3]', 200);

      // act
      final decoded = res.jsonList;

      // assert
      expect(decoded, [1, 2, 3]);
    });

    test('jsonList throws when JSON is an object', () {
      // arrange
      final res = Response('{"a":1}', 200);

      // act
      List<dynamic> act() => res.jsonList;

      // assert
      expect(act, throwsA(isA<TypeError>()));
    });

    test('tryJsonBody returns null on invalid JSON', () {
      // arrange
      final res = Response('not json', 200);

      // act
      final decoded = res.tryJsonBody();

      // assert
      expect(decoded, isNull);
    });

    test('tryJsonBody returns decoded value on valid JSON', () {
      // arrange
      final res = Response('{"a":1}', 200);

      // act
      final decoded = res.tryJsonBody();

      // assert
      expect(decoded, {'a': 1});
    });

    test('decodeJson maps decoded JSON', () {
      // arrange
      final res = Response('{"a":1}', 200);

      // act
      final value = res.decodeJson(
        (json) => (json as Map<String, dynamic>)['a'],
      );

      // assert
      expect(value, 1);
    });
  });
}
