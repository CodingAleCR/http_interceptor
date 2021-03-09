import 'package:http_interceptor/utils/utils.dart';

extension AddParameters on Uri {
  Uri addParameters(Map<String, String>? parameters) {
    if (parameters == null) return this;

    String paramUrl = origin + path;

    Map<String, String> newParameters = {};

    queryParameters.forEach((key, value) {
      newParameters[key] = value;
    });

    parameters.forEach((key, value) {
      newParameters[key] = value;
    });

    return Uri.parse(buildUrlString(paramUrl, newParameters));
  }
}
