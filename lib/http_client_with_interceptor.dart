import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:http_interceptor/interceptor_contract.dart';

///Class to be used by the user to set up a new `http.Client` with interceptor supported.
///call the `build()` constructor passing in the list of interceptors.
///Example:
///```dart
/// HttpClientWithInterceptor httpClient = HttpClientWithInterceptor.build(interceptors: [
///     Logger(),
/// ]);
///```
///
///Then call the functions you want to, on the created `http` object.
///```dart
/// httpClient.get(...);
/// httpClient.post(...);
/// httpClient.put(...);
/// httpClient.delete(...);
/// httpClient.head(...);
/// httpClient.patch(...);
/// httpClient.read(...);
/// httpClient.readBytes(...);
/// httpClient.send(...);
/// httpClient.close();
///```
///Don't forget to close the client once you are done, as a client keeps
///the connection alive with the server.
class HttpClientWithInterceptor extends http.BaseClient {
  List<InterceptorContract> interceptors;
  Duration requestTimeout;

  final Client _client = Client();

  HttpClientWithInterceptor._internal({this.interceptors, this.requestTimeout});

  factory HttpClientWithInterceptor.build({
    List<InterceptorContract> interceptors,
    Duration requestTimeout,
  }) {
    //Remove any value that is null.
    interceptors?.removeWhere((interceptor) => interceptor == null);
    return HttpClientWithInterceptor._internal(
      interceptors: interceptors,
      requestTimeout: requestTimeout,
    );
  }

  Future<Response> head(url, {Map<String, String> headers}) =>
      _sendUnstreamed("HEAD", url, headers);

  Future<Response> get(url, {Map<String, String> headers}) =>
      _sendUnstreamed("GET", url, headers);

  Future<Response> post(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed("POST", url, headers, body, encoding);

  Future<Response> put(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed("PUT", url, headers, body, encoding);

  Future<Response> patch(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed("PATCH", url, headers, body, encoding);

  Future<Response> delete(url, {Map<String, String> headers}) =>
      _sendUnstreamed("DELETE", url, headers);

  Future<String> read(url, {Map<String, String> headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  Future<Response> _sendUnstreamed(
      String method, url, Map<String, String> headers,
      [body, Encoding encoding]) async {
    if (url is String) url = Uri.parse(url);
    var request = new Request(method, url);

    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw new ArgumentError('Invalid request body "$body".');
      }
    }

    //Perform request interception
    for (InterceptorContract interceptor in interceptors) {
      RequestData interceptedData = await interceptor.interceptRequest(
        data: RequestData.fromHttpRequest(request),
      );
      request = interceptedData.toHttpRequest();
    }

    var stream = requestTimeout == null
        ? await send(request)
        : await send(request).timeout(requestTimeout);

    var response = await Response.fromStream(stream);

    var responseData = ResponseData.fromHttpResponse(response);
    for (InterceptorContract interceptor in interceptors) {
      responseData = await interceptor.interceptResponse(data: responseData);
    }

    return responseData.toHttpResponse();
  }

  void _checkResponseSuccess(url, Response response) {
    if (response.statusCode < 400) return;
    var message = "Request to $url failed with status ${response.statusCode}";
    if (response.reasonPhrase != null) {
      message = "$message: ${response.reasonPhrase}";
    }
    if (url is String) url = Uri.parse(url);
    throw new ClientException("$message.", url);
  }

  void close() {
    _client.close();
  }
}
