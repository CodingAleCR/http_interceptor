/// Takes a string and appends [parameters] as query parameters of [url].
///
/// It validates the URL structure and properly encodes both keys and values
/// to prevent URL injection attacks.
String buildUrlString(String url, Map<String, dynamic>? parameters) {
  // Avoids unnecessary processing.
  if (parameters == null) return url;

  // Check if there are parameters to add.
  if (parameters.isNotEmpty) {
    // Validate URL structure to prevent injection
    try {
      Uri.parse(url);
    } catch (e) {
      throw ArgumentError('Invalid URL structure: $url');
    }

    // Checks if the string url already has parameters.
    if (url.contains("?")) {
      url += "&";
    } else {
      url += "?";
    }

    // Concat every parameter to the string url with proper encoding
    parameters.forEach((key, value) {
      // Encode the key to prevent injection
      final encodedKey = Uri.encodeQueryComponent(key);
      
      if (value is List) {
        if (value is List<String>) {
          for (String singleValue in value) {
            url += "$encodedKey=${Uri.encodeQueryComponent(singleValue)}&";
          }
        } else {
          for (dynamic singleValue in value) {
            url += "$encodedKey=${Uri.encodeQueryComponent(singleValue.toString())}&";
          }
        }
      } else if (value is String) {
        url += "$encodedKey=${Uri.encodeQueryComponent(value)}&";
      } else {
        url += "$encodedKey=${Uri.encodeQueryComponent(value.toString())}&";
      }
    });

    // Remove last '&' character.
    url = url.substring(0, url.length - 1);
  }

  return url;
}
