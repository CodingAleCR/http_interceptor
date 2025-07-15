import 'package:test/test.dart';
import 'package:http_interceptor/utils/query_parameters.dart';

void main() {
  group('Query Parameters Utility', () {
    group('buildUrlString', () {
      test('should return original URL when parameters are null', () {
        const url = 'https://example.com/api';
        final result = buildUrlString(url, null);

        expect(result, equals(url));
      });

      test('should return original URL when parameters are empty', () {
        const url = 'https://example.com/api';
        final result = buildUrlString(url, {});

        expect(result, equals(url));
      });

      test('should add single parameter to URL without existing parameters',
          () {
        const url = 'https://example.com/api';
        final parameters = {'param1': 'value1'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com/api?param1=value1'));
      });

      test('should add multiple parameters to URL without existing parameters',
          () {
        const url = 'https://example.com/api';
        final parameters = {'param1': 'value1', 'param2': 'value2'};
        final result = buildUrlString(url, parameters);

        expect(
            result,
            anyOf([
              'https://example.com/api?param1=value1&param2=value2',
              'https://example.com/api?param2=value2&param1=value1',
            ]));
      });

      test('should add parameters to URL with existing parameters', () {
        const url = 'https://example.com/api?existing=param';
        final parameters = {'param1': 'value1'};
        final result = buildUrlString(url, parameters);

        expect(result,
            equals('https://example.com/api?existing=param&param1=value1'));
      });

      test('should handle string list parameters', () {
        const url = 'https://example.com/api';
        final parameters = {
          'tags': ['red', 'blue', 'green']
        };
        final result = buildUrlString(url, parameters);

        expect(result,
            equals('https://example.com/api?tags=red&tags=blue&tags=green'));
      });

      test('should handle mixed list parameters (non-string)', () {
        const url = 'https://example.com/api';
        final parameters = {
          'values': [1, 2, 'three']
        };
        final result = buildUrlString(url, parameters);

        expect(result,
            equals('https://example.com/api?values=1&values=2&values=three'));
      });

      test('should handle non-string parameter values', () {
        const url = 'https://example.com/api';
        final parameters = {
          'number': 42,
          'boolean': true,
          'double': 3.14,
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('number=42'));
        expect(result, contains('boolean=true'));
        expect(result, contains('double=3.14'));
      });

      test('should properly encode query parameter values', () {
        const url = 'https://example.com/api';
        final parameters = {
          'query': 'hello world',
          'special': '!@#\$%^&*()',
          'email': 'user@example.com',
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('query=hello+world'));
        expect(result, contains('special=%21%40%23%24%25%5E%26%2A%28%29'));
        expect(result, contains('email=user%40example.com'));
      });

      test('should handle empty string parameter values', () {
        const url = 'https://example.com/api';
        final parameters = {'empty': ''};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com/api?empty='));
      });

      test('should handle null parameter values', () {
        const url = 'https://example.com/api';
        final parameters = {'nullable': null};
        final result = buildUrlString(url, parameters);

        expect(result, contains('nullable='));
      });

      test('should handle complex nested scenarios', () {
        const url = 'https://example.com/search?page=1';
        final parameters = {
          'q': 'search term',
          'filters': ['category1', 'category2'],
          'limit': 20,
          'sort': 'date',
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('page=1'));
        expect(result, contains('q=search+term'));
        expect(result, contains('filters=category1&filters=category2'));
        expect(result, contains('limit=20'));
        expect(result, contains('sort=date'));
      });

      test('should handle URL with fragment', () {
        const url = 'https://example.com/page#section';
        final parameters = {'param': 'value'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com/page#section?param=value'));
      });

      test('should handle URL with port', () {
        const url = 'https://example.com:8080/api';
        final parameters = {'param': 'value'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com:8080/api?param=value'));
      });

      test('should handle relative URLs', () {
        const url = '/api/endpoint';
        final parameters = {'param': 'value'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('/api/endpoint?param=value'));
      });

      test('should handle URLs with userinfo', () {
        const url = 'https://user:pass@example.com/api';
        final parameters = {'param': 'value'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://user:pass@example.com/api?param=value'));
      });

      test('should handle empty list parameters', () {
        const url = 'https://example.com/api';
        final parameters = {'empty_list': <String>[]};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com/api'));
      });

      test('should handle single item list parameters', () {
        const url = 'https://example.com/api';
        final parameters = {
          'single_item': ['only_one']
        };
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com/api?single_item=only_one'));
      });

      test('should handle parameters with special characters in keys', () {
        const url = 'https://example.com/api';
        final parameters = {'key with spaces': 'value', 'key@symbol': 'value2'};
        final result = buildUrlString(url, parameters);

        expect(result, contains('key+with+spaces=value'));
        expect(result, contains('key%40symbol=value2'));
      });

      test('should handle unicode characters', () {
        const url = 'https://example.com/api';
        final parameters = {'unicode': '测试', 'emoji': '😀'};
        final result = buildUrlString(url, parameters);

        expect(result, contains('unicode='));
        expect(result, contains('emoji='));
        // The exact encoding may vary, but it should be URL-encoded
      });

      test('should handle very long parameter values', () {
        const url = 'https://example.com/api';
        final longValue = 'a' * 1000;
        final parameters = {'long_param': longValue};
        final result = buildUrlString(url, parameters);

        expect(result, startsWith('https://example.com/api?long_param='));
        expect(result, contains('a'));
      });

      test('should handle multiple parameters with same name in existing URL',
          () {
        const url = 'https://example.com/api?tag=existing1&tag=existing2';
        final parameters = {'tag': 'new'};
        final result = buildUrlString(url, parameters);

        expect(result, contains('tag=existing1'));
        expect(result, contains('tag=existing2'));
        expect(result, contains('tag=new'));
      });

      test('should handle boolean parameters', () {
        const url = 'https://example.com/api';
        final parameters = {
          'enabled': true,
          'disabled': false,
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('enabled=true'));
        expect(result, contains('disabled=false'));
      });

      test('should handle numeric parameters', () {
        const url = 'https://example.com/api';
        final parameters = {
          'int': 42,
          'double': 3.14159,
          'negative': -10,
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('int=42'));
        expect(result, contains('double=3.14159'));
        expect(result, contains('negative=-10'));
      });

      test('should handle mixed type lists', () {
        const url = 'https://example.com/api';
        final parameters = {
          'mixed': [1, 'two', true, 3.14],
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('mixed=1'));
        expect(result, contains('mixed=two'));
        expect(result, contains('mixed=true'));
        expect(result, contains('mixed=3.14'));
      });

      test('should preserve existing URL structure', () {
        const url = 'https://example.com/api/v1/users?sort=name&order=asc';
        final parameters = {'filter': 'active'};
        final result = buildUrlString(url, parameters);

        expect(result, startsWith('https://example.com/api/v1/users?'));
        expect(result, contains('sort=name'));
        expect(result, contains('order=asc'));
        expect(result, contains('filter=active'));
      });
    });

    group('Edge cases and error handling', () {
      test('should handle malformed URLs gracefully', () {
        const url = 'not-a-valid-url';
        final parameters = {'param': 'value'};

        // Should not throw, but behavior may vary
        expect(() => buildUrlString(url, parameters), returnsNormally);
      });

      test('should handle empty URL', () {
        const url = '';
        final parameters = {'param': 'value'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('?param=value'));
      });

      test('should handle URL with only query separator', () {
        const url = 'https://example.com/api?';
        final parameters = {'param': 'value'};
        final result = buildUrlString(url, parameters);

        expect(result, equals('https://example.com/api?param=value'));
      });

      test('should handle parameters with null values in lists', () {
        const url = 'https://example.com/api';
        final parameters = {
          'list_with_null': ['value1', null, 'value3']
        };
        final result = buildUrlString(url, parameters);

        expect(result, contains('list_with_null=value1'));
        expect(result, contains('list_with_null='));
        expect(result, contains('list_with_null=value3'));
      });
    });
  });
}
