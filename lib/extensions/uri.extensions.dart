import 'package:http_interceptor/utils/utils.dart';
import 'package:http_interceptor/extensions/extensions.dart';

extension AddParameters on Uri {
  Uri addParameters(Map<String, dynamic>? parameters) {
    if (parameters == null) return this;

    String paramUrl = origin + path;

    Map<String, dynamic> newParameters = {};

    queryParametersAll.forEach((key, values) {
      newParameters[key] = values;
    });

    parameters.forEach((key, value) {
      newParameters[key] = value;
    });

    return buildUrlString(paramUrl, newParameters).toUri();
  }
}
