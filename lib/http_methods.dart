enum Method {
  HEAD,
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

Method methodFromString(String method) {
  switch (method) {
    case "HEAD":
      return Method.HEAD;
    case "GET":
      return Method.GET;
    case "POST":
      return Method.POST;
    case "PUT":
      return Method.PUT;
    case "PATCH":
      return Method.PATCH;
    case "DELETE":
      return Method.DELETE;
  }
  return null;
}
