import 'package:http_interceptor/http_interceptor.dart';
import 'package:test/test.dart';

void main() {
  group('Query Parameters Tests', () {
    test('should add parameters to URI with existing query', () {
      final uri = Uri.parse('https://example.com/api?existing=value');
      final params = {'new': 'param', 'another': 'value'};

      final result = uri.addParameters(params);

      expect(result.queryParameters['existing'], equals('value'));
      expect(result.queryParameters['new'], equals('param'));
      expect(result.queryParameters['another'], equals('value'));
      expect(result.queryParameters.length, equals(3));
    });

    test('should add parameters to URI without existing query', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {'param1': 'value1', 'param2': 'value2'};

      final result = uri.addParameters(params);

      expect(result.queryParameters['param1'], equals('value1'));
      expect(result.queryParameters['param2'], equals('value2'));
      expect(result.queryParameters.length, equals(2));
    });

    test('should handle empty parameters map', () {
      final uri = Uri.parse('https://example.com/api?existing=value');
      final params = <String, dynamic>{};

      final result = uri.addParameters(params);

      expect(result.queryParameters['existing'], equals('value'));
      expect(result.queryParameters.length, equals(1));
    });

    test('should handle null parameters', () {
      final uri = Uri.parse('https://example.com/api');

      final result = uri.addParameters(null);

      expect(result, equals(uri));
    });

    test('should handle parameters with null values', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {'param1': 'value1', 'param2': null, 'param3': 'value3'};

      final result = uri.addParameters(params);

      expect(result.queryParameters['param1'], equals('value1'));
      expect(result.queryParameters['param2'], equals('null'));
      expect(result.queryParameters['param3'], equals('value3'));
    });

    test('should handle parameters with different value types', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'string': 'value',
        'int': 42,
        'double': 3.14,
        'bool': true,
        'list': ['item1', 'item2'],
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['string'], equals('value'));
      expect(result.queryParameters['int'], equals('42'));
      expect(result.queryParameters['double'], equals('3.14'));
      expect(result.queryParameters['bool'], equals('true'));
      // Lists are handled as multiple parameters with the same key
      expect(result.queryParameters['list'], equals('item2'));
    });

    test('should preserve URI components', () {
      final uri = Uri.parse(
          'https://user:pass@example.com:8080/path?existing=value#fragment');
      final params = {'new': 'param'};

      final result = uri.addParameters(params);

      expect(result.scheme, equals('https'));
      expect(result.host, equals('example.com'));
      expect(result.port, equals(8080));
      expect(result.path, equals('/path'));
      expect(result.fragment, equals('fragment'));
      expect(result.queryParameters['existing'], equals('value'));
      expect(result.queryParameters['new'], equals('param'));
    });

    test('should handle complex parameter values', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'simple': 'value',
        'with spaces': 'value with spaces',
        'with&symbols': 'value&with=symbols',
        'with+plus': 'value+with+plus',
        'with%20encoding': 'value with encoding',
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['simple'], equals('value'));
      expect(
          result.queryParameters['with spaces'], equals('value with spaces'));
      expect(
          result.queryParameters['with&symbols'], equals('value&with=symbols'));
      expect(result.queryParameters['with+plus'], equals('value+with+plus'));
      expect(result.queryParameters['with%20encoding'],
          equals('value with encoding'));
    });

    test('should handle list parameters correctly', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'single': 'value',
        'multiple': ['item1', 'item2', 'item3'],
        'empty': <String>[],
        'mixed': ['item1', 42, true],
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['single'], equals('value'));
      // Lists create multiple parameters with the same key, so we get the last value
      expect(result.queryParameters['multiple'], equals('item3'));
      expect(result.queryParameters['empty'], isNull);
      expect(result.queryParameters['mixed'], equals('true'));
    });

    test('should handle map parameters', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'map': {'key1': 'value1', 'key2': 'value2'},
        'nested': {
          'level1': {'level2': 'value'}
        },
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['map'],
          equals('{key1: value1, key2: value2}'));
      expect(result.queryParameters['nested'],
          equals('{level1: {level2: value}}'));
    });

    test('should handle special characters in parameter names and values', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'param-name': 'value',
        'param_name': 'value',
        'param.name': 'value',
        'param:name': 'value',
        'param/name': 'value',
        'param\\name': 'value',
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['param-name'], equals('value'));
      expect(result.queryParameters['param_name'], equals('value'));
      expect(result.queryParameters['param.name'], equals('value'));
      expect(result.queryParameters['param:name'], equals('value'));
      expect(result.queryParameters['param/name'], equals('value'));
      expect(result.queryParameters['param\\name'], equals('value'));
    });

    test('should handle very long parameter values', () {
      final uri = Uri.parse('https://example.com/api');
      final longValue = 'a' * 1000; // 1000 character string
      final params = {'long': longValue};

      final result = uri.addParameters(params);

      expect(result.queryParameters['long'], equals(longValue));
    });

    test('should handle parameters with empty string values', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'empty': '',
        'whitespace': '   ',
        'normal': 'value',
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['empty'], equals(''));
      expect(result.queryParameters['whitespace'], equals('   '));
      expect(result.queryParameters['normal'], equals('value'));
    });

    test('should handle parameters with special unicode characters', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {
        'unicode': 'café',
        'emoji': '🚀',
        'chinese': '你好',
        'arabic': 'مرحبا',
      };

      final result = uri.addParameters(params);

      expect(result.queryParameters['unicode'], equals('café'));
      expect(result.queryParameters['emoji'], equals('🚀'));
      expect(result.queryParameters['chinese'], equals('你好'));
      expect(result.queryParameters['arabic'], equals('مرحبا'));
    });

    test('should handle parameters that override existing query parameters',
        () {
      final uri = Uri.parse('https://example.com/api?existing=old');
      final params = {'existing': 'new', 'additional': 'value'};

      final result = uri.addParameters(params);

      expect(
          result.queryParameters['existing'], equals('new')); // Should override
      expect(result.queryParameters['additional'], equals('value'));
      expect(result.queryParameters.length, equals(2));
    });

    test('should handle parameters with null keys', () {
      final uri = Uri.parse('https://example.com/api');
      final params = <String, dynamic>{'null_key': 'value'};

      final result = uri.addParameters(params);

      expect(result.queryParameters['null_key'], equals('value'));
    });

    test('should handle parameters with empty keys', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {'': 'value'};

      final result = uri.addParameters(params);

      // Empty keys are not supported by Uri.queryParameters
      expect(result.queryParameters.containsKey(''), isFalse);
    });

    test('should handle parameters with whitespace keys', () {
      final uri = Uri.parse('https://example.com/api');
      final params = {' ': 'value', '  ': 'another'};

      final result = uri.addParameters(params);

      expect(result.queryParameters[' '], equals('value'));
      expect(result.queryParameters['  '], equals('another'));
    });
  });
}
