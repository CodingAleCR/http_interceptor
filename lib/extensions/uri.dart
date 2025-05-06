import 'package:http_interceptor/extensions/string.dart';
import 'package:http_interceptor/utils/utils.dart';

/// Extends `Uri` to allow adding parameters to already created intstances
extension AddParameters on Uri {
  /// Returns a new [Uri] instance based on `this` and adds [parameters].
  Uri addParameters(Map<String, dynamic>? parameters) => parameters != null
      ? buildUrlString(
          origin + path,
          {
            ...queryParametersAll,
            ...parameters,
          },
        ).toUri()
      : this;
}
