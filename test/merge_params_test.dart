import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/models/merge_params.dart';

main() {
  test('test merge params', () {
    var url = Uri.parse('http://example.com/xx?page=1&page=2&foo=bar');
    Map<String, dynamic> params = {
      'name': 'a',
      'data': ['x', 'y'],
      'foo': 'z'
    };
    var newUrl = mergeParams(url, params);
    expect(newUrl.queryParametersAll['data'] != null, true);
    expect(newUrl.queryParametersAll['foo'] != null, true);
    expect(newUrl.queryParametersAll['foo'], ['z']);
  });
}
