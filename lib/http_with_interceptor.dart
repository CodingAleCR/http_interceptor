import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:http_interceptor/http_methods.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:http_interceptor/interceptor_contract.dart';

///Class to be used by the user as a replacement for 'http' with interceptor supported.
///call the `build()` constructor passing in the list of interceptors.
///Example:
///```dart
/// HttpWithInterceptor http = HttpWithInterceptor.build(interceptors: [
///     Logger(),
/// ]);
///```
///Then call the functions you want to, on the created `http` object.
///```dart
/// http.get(...);
/// http.post(...);
/// http.put(...);
/// http.delete(...);
/// http.head(...);
/// http.patch(...);
/// http.read(...);
/// http.readBytes(...);
///```
class HttpWithInterceptor {
  List<InterceptorContract> interceptors;
  Duration requestTimeout;

  HttpWithInterceptor._internal({
    this.interceptors,
    this.requestTimeout,
  });

  factory HttpWithInterceptor.build({
    List<InterceptorContract> interceptors,
    Duration requestTimeout,
  }) {
    //Remove any value that is null.
    interceptors?.removeWhere((interceptor) => interceptor == null);
    return new HttpWithInterceptor._internal(
        interceptors: interceptors, requestTimeout: requestTimeout);
  }

  Future<Response> head(url, {Map<String, String> headers}) async {
    await _sendInterception(method: Method.HEAD, headers: headers, url: url);
    return _withClient((client) => client.head(url, headers: headers));
  }

  Future<Response> get(url, {Map<String, String> headers}) async {
    RequestData data =
        await _sendInterception(method: Method.GET, headers: headers, url: url);
    return _withClient((client) => client.get(data.url, headers: data.headers));
  }

  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    RequestData data = await _sendInterception(
        method: Method.POST,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.post(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    RequestData data = await _sendInterception(
        method: Method.PUT,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.put(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    RequestData data = await _sendInterception(
        method: Method.PATCH,
        headers: headers,
        url: url,
        body: body,
        encoding: encoding);
    return _withClient((client) => client.patch(data.url,
        headers: data.headers, body: data.body, encoding: data.encoding));
  }

  Future<Response> delete(url, {Map<String, String> headers}) async {
    RequestData data = await _sendInterception(
        method: Method.DELETE, headers: headers, url: url);
    return _withClient(
        (client) => client.delete(data.url, headers: data.headers));
  }

  Future<String> read(url, {Map<String, String> headers}) {
    return _withClient((client) => client.read(url, headers: headers));
  }

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) =>
      _withClient((client) => client.readBytes(url, headers: headers));

  Future<RequestData> _sendInterception(
      {Method method,
      Encoding encoding,
      dynamic body,
      String url,
      Map<String, String> headers}) async {
    RequestData data = RequestData(
        method: method,
        encoding: encoding,
        body: body,
        url: url,
        headers: headers ?? <String, String>{});

    //Perform request interception
    for (InterceptorContract interceptor in interceptors) {
      data = await interceptor.interceptRequest(
        data: data,
      );
    }
    return data;
  }

  Future<T> _withClient<T>(Future<T> fn(Client client)) async {
    var client = new Client();
    try {
      T response = requestTimeout == null
          ? await fn(client)
          : await fn(client).timeout(requestTimeout);
      if (response is Response) {
        var responseData = ResponseData.fromHttpResponse(response);
        for (InterceptorContract interceptor in interceptors) {
          responseData =
              await interceptor.interceptResponse(data: responseData);
        }

        return responseData.toHttpResponse() as T;
      }
      return response;
    } finally {
      client.close();
    }
  }
}
