/// When having an URL as String and no parameters sent then it adds
/// them to the string.
String addParametersToUrl(String url, Map<String, String> parameters) {
  if (parameters == null) return url;

  String paramUrl = url;
  if (parameters != null && parameters.length > 0) {
    if (paramUrl.contains("?"))
      paramUrl += "&";
    else
      paramUrl += "?";
    parameters.forEach((key, value) {
      paramUrl += "$key=$value&";
    });
    paramUrl = paramUrl.substring(0, paramUrl.length - 1);
  }
  return paramUrl;
}
