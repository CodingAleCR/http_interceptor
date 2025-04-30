import 'package:qs_dart/qs_dart.dart' as qs;
import 'package:validators/validators.dart' as validators;

/// Takes a string and appends [parameters] as query parameters of [url].
///
/// Throws [ArgumentError] if [url] is not a valid URL.
String buildUrlString(String url, Map<String, dynamic>? parameters) {
  late final Uri uri;

  try {
    if (!validators.isURL(url)) {
      throw FormatException('Invalid URL format');
    }
    uri = Uri.parse(url);
  } on FormatException {
    throw ArgumentError.value(url, 'url', 'Must be a valid URL');
  }

  return parameters?.isNotEmpty ?? false
      ? uri
          .replace(
              query: qs.encode(
                <String, dynamic>{
                  ...uri.queryParametersAll,
                  ...?parameters,
                },
                qs.EncodeOptions(
                  listFormat: qs.ListFormat.repeat,
                  skipNulls: false,
                  strictNullHandling: false,
                ),
              ),
              queryParameters: null)
          .toString()
      : url;
}
