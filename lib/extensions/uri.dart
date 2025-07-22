import 'package:http_interceptor/extensions/string.dart';
import 'package:http_interceptor/utils/utils.dart';

/// Extends `Uri` to allow adding parameters to already created instances.
extension AddParameters on Uri {
  /// Returns a new [Uri] instance based on `this` and adds [parameters].
  Uri addParameters([Map<String, dynamic>? parameters]) {
    if (parameters?.isNotEmpty ?? false) {
      String finalUrl = buildUrlString(
        "$origin$path",
        {
          ...queryParametersAll,
          ...?parameters,
        },
      );
      if (fragment.isNotEmpty) {
        finalUrl += '#$fragment';
      }
      return finalUrl.toUri();
    }
    return this;
  }
}
