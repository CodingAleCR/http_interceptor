/// Extends [String] to provide URI compatibility.
extension ToURI on String {
  /// Converts the current string into a valid URI. Since it uses
  /// `Uri.parse` then it can throw `FormatException` if `this` is not
  /// a valid string for parsing.
  Uri toUri() => Uri.parse(this);
}
