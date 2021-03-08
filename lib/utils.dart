/// When having an URL as String and no parameters sent then it adds
/// them to the string.
String addParametersToStringUrl(String url, Map<String, dynamic> parameters) {
  return buildUrlString(url, parameters);
}

Uri addParametersToUrl(Uri url, Map<String, dynamic> parameters) {
  if (parameters == null) return url;

  String paramUrl = url.origin + url.path;

  Map<String, dynamic> newParameters = {};

  url.queryParametersAll.forEach((key, values) {
    if (values.length == 1) {
      newParameters[key] = values.single;
    } else {
      newParameters[key] = values;
    }
  });

  parameters.forEach((key, value) {
    newParameters[key] = value;
  });

  return Uri.parse(buildUrlString(paramUrl, newParameters));
}

String buildUrlString(String url, Map<String, dynamic> parameters) {
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
      if (value is Iterable) {
        Iterable values = value;
        for (String value in values) {
          url += "$key=$value&";
        }
      } else {
        url += "$key=$value&";
      }
    });

    // Remove last '&' character.
    url = url.substring(0, url.length - 1);
  }

  return url;
}
