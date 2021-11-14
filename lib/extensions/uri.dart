import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/utils/utils.dart';

/// Extends `Uri` to allow adding parameters to already created intstances
extension AddParameters on Uri {
  /// Returns a new `Uri` instance based on `this` and adds [parameters].
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
