import 'package:http_interceptor/extensions/string.dart';
import 'package:http_interceptor/utils/utils.dart';

/// Extends `Uri` to allow adding parameters to already created instances.
extension AddParameters on Uri {
  /// Returns a new [Uri] instance based on `this` and adds [parameters].
  Uri addParameters([Map<String, dynamic>? parameters]) =>
      parameters?.isNotEmpty ?? false
          ? (StringBuffer()
                ..writeAll([
                  buildUrlString(
                    "$origin$path",
                    {
                      ...queryParametersAll,
                      ...?parameters,
                    },
                  ),
                  if (fragment.isNotEmpty) '#$fragment',
                ]))
              .toString()
              .toUri()
          : this;
}
