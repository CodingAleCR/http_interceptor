/// Merge params into url
///
/// ```dart
/// var url = Uri.parse('http://example.com/xx?page=1&page=2&foo=bar');
/// Map<String, dynamic> params = {
///   'name': 'a',
///   'data': ['x', 'y'],
///   'foo': 'z'
/// };
/// var newUrl = mergeParams(url, params); // http://example.com/xx?page=1&page=2&foo=z&name=a&data=x&data=y
/// ```
Uri mergeParams(Uri url, Map<String, dynamic /*String|Iterable<String>*/ > params) {
  if (params != null) {
    try {
      url = url.replace(
        queryParameters: {
          ...url.queryParametersAll,
          ...params,
        },
      );
    } catch (e) {
      throw e;
    }
  }
  return url;
}
