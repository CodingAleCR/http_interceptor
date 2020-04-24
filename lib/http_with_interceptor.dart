import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';
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
  RetryPolicy retryPolicy;
  bool Function(X509Certificate, String, int) badCertificateCallback;

  HttpWithInterceptor._internal({
    this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.badCertificateCallback,
  });

  factory HttpWithInterceptor.build({
    @required List<InterceptorContract> interceptors,
    Duration requestTimeout,
    RetryPolicy retryPolicy,
    bool Function(X509Certificate, String, int) badCertificateCallback,
  }) {
    assert(interceptors != null);

    //Remove any value that is null.
    interceptors?.removeWhere((interceptor) => interceptor == null);
    return new HttpWithInterceptor._internal(
      interceptors: interceptors,
      requestTimeout: requestTimeout,
      retryPolicy: retryPolicy,
      badCertificateCallback: badCertificateCallback
    );
  }

  Future<Response> head(url, {Map<String, String> headers}) async {
    return _withClient((client) => client.head(url, headers: headers));
  }

  Future<Response> get(url,
      {Map<String, String> headers, Map<String, String> params}) async {
    return _withClient((client) => client.get(url, headers: headers, params: params));
  }

  Future<Response> post(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    return _withClient((client) =>
        client.post(url, headers: headers, body: body, encoding: encoding));
  }

  Future<Response> put(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    return _withClient((client) =>
        client.put(url, headers: headers, body: body, encoding: encoding));
  }

  Future<Response> patch(url,
      {Map<String, String> headers, body, Encoding encoding}) async {
    return _withClient((client) =>
        client.patch(url, headers: headers, body: body, encoding: encoding));
  }

  Future<Response> delete(url, {Map<String, String> headers}) async {
    return _withClient((client) => client.delete(url, headers: headers));
  }

  Future<String> read(url, {Map<String, String> headers}) {
    return _withClient((client) => client.read(url, headers: headers));
  }

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) =>
      _withClient((client) => client.readBytes(url, headers: headers));

  Future<T> _withClient<T>(
      Future<T> fn(HttpClientWithInterceptor client)) async {
    var client = new HttpClientWithInterceptor.build(
      interceptors: interceptors,
      requestTimeout: requestTimeout,
      retryPolicy: retryPolicy,
      badCertificateCallback: badCertificateCallback,
    );
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }
}
