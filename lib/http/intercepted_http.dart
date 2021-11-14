import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

import 'intercepted_client.dart';
import 'interceptor_contract.dart';

/// Class to be used by the user as a replacement for 'http' with interceptor
/// support.
///
/// It is a useful class if you want to centralize HTTP request calls
/// since it creates and discards [InterceptedClient] instances after the
/// request is done and that allows you to avoid handling your own [Client]
/// instances.
///
///
/// Call `build()` and pass list of interceptors as parameter.
///
/// Example:
/// ```dart
///  InterceptedHttp http = InterceptedHttp.build(interceptors: [
///      LoggingInterceptor(),
///  ]);
/// ```
///
/// Then call the functions you want to, on the created `http` object.
/// ```dart
///  http.get(...);
///  http.post(...);
///  http.put(...);
///  http.delete(...);
///  http.head(...);
///  http.patch(...);
///  http.send(...);
///  http.read(...);
///  http.readBytes(...);
/// ```
class InterceptedHttp {
  /// List of interceptors that will be applied to the requests and responses.
  final List<InterceptorContract> interceptors;

  /// Maximum duration of a request.
  final Duration? requestTimeout;

  /// A policy that defines whether a request or response should trigger a
  /// retry. This is useful for implementing JWT token expiration
  final RetryPolicy? retryPolicy;

  /// Inner client that is wrapped for intercepting.
  ///
  /// If you don't specify your own client then the library will instantiate
  /// a default one.
  Client? client;

  InterceptedHttp._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    this.client,
  });

  /// Builds a new [InterceptedHttp] instance. It helps avoid creating and
  /// managing your own `Client` instances.
  ///
  /// Interceptors are applied in a linear order. For example a list that looks
  /// like this:
  ///
  /// ```dart
  /// InterceptedClient.build(
  ///   interceptors: [
  ///     WeatherApiInterceptor(),
  ///     LoggerInterceptor(),
  ///   ],
  /// ),
  /// ```
  ///
  /// Will apply first the `WeatherApiInterceptor` interceptor, so when
  /// `LoggerInterceptor` receives the request/response it has already been
  /// intercepted.
  factory InterceptedHttp.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    RetryPolicy? retryPolicy,
    Client? client,
  }) =>
      InterceptedHttp._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        client: client,
      );

  /// Performs a HEAD request with a new [Client] instance and closes it after
  /// it has been used.
  Future<Response> head(
    url, {
    Map<String, String>? headers,
  }) async {
    return _withClient((client) => client.head(
          url,
          headers: headers,
        ));
  }

  /// Performs a GET request with a new [Client] instance and closes it after
  /// it has been used.
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

  /// Performs a POST request with a new [Client] instance and closes it after
  /// it has been used.
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

  /// Performs a PUT request with a new [Client] instance and closes it after
  /// it has been used.
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

  /// Performs a PATCH request with a new [Client] instance and closes it after
  /// it has been used.
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

  /// Performs a DELETE request with a new [Client] instance and closes it after
  /// it has been used.
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

  /// Executes `client.read` with a new [Client] instance and closes it after
  /// it has been used.
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

  /// Executes `client.readBytes` with a new [Client] instance and closes it
  /// after it has been used.
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

  /// Internal convenience utility to create a new [Client] instance for each
  /// request. It closes the client after using it for the request.
  Future<T> _withClient<T>(
    Future<T> fn(InterceptedClient client),
  ) async {
    final client = InterceptedClient.build(
      interceptors: interceptors,
      requestTimeout: requestTimeout,
      retryPolicy: retryPolicy,
      client: this.client,
    );
    try {
      return await fn(client);
    } finally {
      client.close();
    }
  }
}
