import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_interceptor/models/merge_params.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:http_interceptor/interceptor_contract.dart';

import 'http_methods.dart';

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

  Future<Response> head(url, {Map<String, String> headers}) => _sendUnstreamed(
        method: Method.HEAD,
        url: url,
        headers: headers,
      );

  Future<Response> get(url,
          {Map<String, String> headers,
          Map<String, dynamic /*String|Iterable<String>*/ > params}) =>
      _sendUnstreamed(
        method: Method.GET,
        url: url,
        headers: headers,
        params: params,
      );

  Future<Response> post(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed(
        method: Method.POST,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> put(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed(
        method: Method.PUT,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> patch(url,
          {Map<String, String> headers, body, Encoding encoding}) =>
      _sendUnstreamed(
        method: Method.PATCH,
        url: url,
        headers: headers,
        body: body,
        encoding: encoding,
      );

  Future<Response> delete(url, {Map<String, String> headers}) =>
      _sendUnstreamed(
        method: Method.DELETE,
        url: url,
        headers: headers,
      );

  Future<String> read(url, {Map<String, String> headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  /// send file
  ///
  /// ```dart
  /// import 'dart:io';
  /// import 'package:async/async.dart';
  /// import 'package:http_interceptor/http_interceptor.dart';
  /// import 'package:image_picker/image_picker.dart';
  /// import 'package:http/http.dart';
  /// import 'package:path/path.dart';
  ///
  ///// Create http sender
  /// HttpClientWithInterceptor client = HttpClientWithInterceptor.build(
  ///   interceptors: [
  ///     BaseUrlInterceptor(),
  ///   ],
  /// );
  ///
  /// // Create an interceptor that will stitch the url
  /// class BaseUrlInterceptor implements InterceptorContract {
  ///   final baseUrl = "http://192.168.1.91:5000";
  ///   @override
  ///   Future<RequestData> interceptRequest({RequestData data}) async {
  ///     data.url = Uri.parse(baseUrl.toString() + data.url.toString());
  ///     return data;
  ///   }
  ///   @override
  ///   Future<ResponseData> interceptResponse({ResponseData data}) async {
  ///     return data;
  ///   }
  /// }
  ///
  /// floatingActionButton: FloatingActionButton(
  ///   child: Icon(Icons.add),
  ///   onPressed: () async {
  ///     // Get image
  ///     File imageFile =  await ImagePicker.pickImage(source: ImageSource.gallery);
  ///     if (imageFile != null) {
  ///       var stream = ByteStream(
  ///         DelegatingStream.typed(imageFile.openRead()),
  ///       );
  ///       int length = await imageFile.length();
  ///       MultipartFile file = MultipartFile(
  ///         'file',
  ///         stream,
  ///         length,
  ///         filename: basename(imageFile.path),
  ///       );
  ///       // send
  ///       var r = await client.postFile(
  ///        "/upload",
  ///         body: {
  ///           'name': 'foo',
  ///         },
  ///         files: [file],
  ///       );
  ///       print(r.statusCode);
  ///       print(r.body);
  ///     }
  ///   },
  /// ),
  /// ```
  Future<Response> postFile(
    url, {
    Map<String, String> headers,
    Map<String, String> body,
    List<MultipartFile> files,
  }) =>
      _sendUnstreamed(
        method: Method.POST,
        url: url,
        headers: headers,
        body: body,
        files: files,
      );

  Future<Uint8List> readBytes(url, {Map<String, String> headers}) {
    return get(url, headers: headers).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  Future<StreamedResponse> send(BaseRequest request) => _client.send(request);

  Future<Response> _sendUnstreamed({
    @required Method method,
    @required dynamic url,
    @required Map<String, String> headers,
    Map<String, dynamic /*String|Iterable<String>*/ > params,
    dynamic body,
    Encoding encoding,
    List<MultipartFile> files,
  }) async {
    Uri paramUrl = url is Uri ? url : Uri.parse(url);
    paramUrl = mergeParams(paramUrl, params);
    var request;
    if (files == null) {
      request = new Request(methodToString(method), paramUrl);
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
    } else {
      request = MultipartRequest(methodToString(method), paramUrl);
      if (headers != null) request.headers.addAll(headers);
      if (body != null) request.fields.addAll(body);
      if (files != null) request.files.addAll(files);
    }

    //Perform request interception
    for (InterceptorContract interceptor in interceptors) {
      RequestData interceptedData = await interceptor.interceptRequest(
        data: RequestData.fromHttpRequest(request),
      );
      request = files == null
          ? interceptedData.toHttpRequest()
          : interceptedData.toHttpRequest<MultipartRequest>();
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
