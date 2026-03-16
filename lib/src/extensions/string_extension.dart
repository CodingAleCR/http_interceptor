/// Extension to parse a [String] as a [Uri].
///
/// Allows `"$baseUrl/path".toUri()` when using the library.
extension StringToUri on String {
  /// Parses this string as a [Uri].
  Uri toUri() => Uri.parse(this);
}
