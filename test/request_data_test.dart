import 'package:flutter_test/flutter_test.dart';
import 'package:http_interceptor/http_methods.dart';
import 'package:http_interceptor/models/request_data.dart';

main() {
  var rd = RequestData(
    method: Method.GET,
    url: Uri.parse('http://192.168.1.91:5000/test?name=a&name=b'),
    params: {
      "page": ["1", "2"],
      "age": "12",
    },
  );
  test('test request data', () {
    expect(rd.method, Method.GET);
    Uri rr = Uri.parse(rd.requestUrl);
    expect(rr.queryParametersAll['age'], ['12']);
    expect(rr.queryParametersAll['page'][0], "1");
    expect(rr.queryParametersAll['name'], ["a", "b"]);
  });

  test('test RequestData.toHttpRequest', () {
    rd.params = {"age": "13"};
    var r = rd.toHttpRequest();
    expect(r.url.queryParametersAll['age'], ['13']);
  });
}
