import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import 'intercepted_client.dart';
import 'interceptor_contract.dart';

///Class to be used by the user as a replacement for 'http' with interceptor supported.
///call the `build()` constructor passing in the list of interceptors.
///Example:
///```dart
/// InterceptedHttp http = InterceptedHttp.build(interceptors: [
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
class InterceptedHttp {
  List<InterceptorContract> interceptors;
  Duration? requestTimeout;
  RetryPolicy? retryPolicy;
  String Function(Uri)? findProxy;
  Client? client;

  InterceptedHttp._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.findProxy,
    this.client,
  });

  factory InterceptedHttp.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    RetryPolicy? retryPolicy,
    String Function(Uri)? findProxy,
    Client? client,
  }) =>
      InterceptedHttp._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        findProxy: findProxy,
        client: client,
      );

  Future<Response> head(
    url, {
    Map<String, String>? headers,
  }) async {
    return _withClient((client) => client.head(
          url,
          headers: headers,
        ));
  }

  Future<Response> get(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) async {
    return _withClient((client) => client.get(
          url,
          headers: headers,
          params: params,
        ));
  }

  Future<Response> post(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    return _withClient((client) => client.post(
          url,
          headers: headers,
          params: params,
          body: body,
          encoding: encoding,
        ));
  }

  Future<Response> put(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    return _withClient((client) => client.put(
          url,
          headers: headers,
          params: params,
          body: body,
          encoding: encoding,
        ));
  }

  Future<Response> patch(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    return _withClient((client) => client.patch(
          url,
          headers: headers,
          params: params,
          body: body,
          encoding: encoding,
        ));
  }

  Future<Response> delete(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    return _withClient((client) => client.delete(
          url,
          headers: headers,
          params: params,
          body: body,
          encoding: encoding,
        ));
  }

  Future<String> read(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    return _withClient((client) => client.read(
          url,
          headers: headers,
          params: params,
        ));
  }

  Future<Uint8List> readBytes(
    url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) =>
      _withClient((client) => client.readBytes(
            url,
            headers: headers,
            params: params,
          ));

  Future<T> _withClient<T>(
    Future<T> fn(InterceptedClient client),
  ) async {
    final client = InterceptedClient.build(
      interceptors: interceptors,
      requestTimeout: requestTimeout,
      retryPolicy: retryPolicy,
      findProxy: findProxy,
      client: this.client,
    );
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }
}
