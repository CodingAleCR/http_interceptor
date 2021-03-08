/// When having an URL as String and no parameters sent then it adds
/// them to the string.
String addParametersToStringUrl(String url, Map<String, String>? parameters) {
  return buildUrlString(url, parameters);
}

Uri addParametersToUrl(Uri url, Map<String, String>? parameters) {
  if (parameters == null) return url;

  String paramUrl = url.origin + url.path;

  Map<String, String> newParameters = {};

  url.queryParameters.forEach((key, value) {
    newParameters[key] = value;
  });

  parameters.forEach((key, value) {
    newParameters[key] = value;
  });

  return Uri.parse(buildUrlString(paramUrl, newParameters));
}

String buildUrlString(String url, Map<String, String>? parameters) {
  // Avoids unnecessary processing.
  if (parameters == null) return url;

  // Check if there are parameters to add.
  if (parameters.length > 0) {
    // Checks if the string url already has parameters.
    if (url.contains("?")) {
      url += "&";
    } else {
      url += "?";
    }

    // Concat every parameter to the string url.
    parameters.forEach((key, value) {
      url += "$key=$value&";
    });

    // Remove last '&' character.
    url = url.substring(0, url.length - 1);
  }

  return url;
}
