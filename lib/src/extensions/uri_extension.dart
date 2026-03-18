/// Merges [params] and [paramsAll] into this [Uri]'s query.
///
/// [params] are single-value query parameters; [paramsAll] support multiple
/// values per key (array parameters). Existing query parameters are preserved
/// and merged with the new ones.
extension UriQueryParams on Uri {
  /// Returns a new [Uri] with [params] and [paramsAll] merged into the query.
  Uri addQueryParams({
    Map<String, String>? params,
    Map<String, List<String>>? paramsAll,
  }) {
    if (params == null && paramsAll == null) return this;
    final p = Map<String, String>.from(queryParameters);
    if (params != null) p.addAll(params);
    final pa = Map<String, List<String>>.from(queryParametersAll);
    if (paramsAll != null) {
      for (final e in paramsAll.entries) {
        pa[e.key] = List.from(e.value);
      }
    }
    // Uri.replace only has queryParameters (single value per key); build query
    // manually to support multiple values per key.
    final parts = <String>[
      ...p.entries.map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      ),
      ...pa.entries.expand(
        (e) => e.value.map(
          (v) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(v)}',
        ),
      ),
    ];
    return replace(query: parts.isEmpty ? null : parts.join('&'));
  }
}
