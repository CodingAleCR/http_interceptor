import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

main() {
  late BaseResponse baseResponse;
  late Response response;

  setUpAll(() {
    baseResponse = Response("{'foo': 'bar'}", 200);
    response = baseResponse as Response;
  });

  group('BaseResponse.copyWith: ', () {
    test('Response is copied from BaseResponse', () {
      // Arrange
      final copiedBaseRequest = baseResponse.copyWith();

      // Act
      final copied = copiedBaseRequest as Response;

      // Assert
      expect(copied.hashCode, isNot(equals(response.hashCode)));
      expect(copied.statusCode, equals(response.statusCode));
      expect(copied.body, equals(response.body));
      expect(copied.headers, equals(response.headers));
      expect(copied.isRedirect, equals(response.isRedirect));
      expect(copied.reasonPhrase, equals(response.reasonPhrase));
      expect(
          copied.persistentConnection, equals(response.persistentConnection));
    });
  });
}
