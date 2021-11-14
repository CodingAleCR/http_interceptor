import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart';

extension IOStreamedResponseCopyWith on IOStreamedResponse {
  IOStreamedResponse copyWith({
    Stream<List<int>>? stream,
    int? statusCode,
    int? contentLength,
    BaseRequest? request,
    Map<String, String>? headers,
    bool? isRedirect,
    bool? persistentConnection,
    String? reasonPhrase,
    HttpClientResponse? inner,
  }) {
    return IOStreamedResponse(
      stream ?? this.stream,
      statusCode ?? this.statusCode,
      contentLength: contentLength ?? this.contentLength,
      request: request ?? this.request,
      headers: headers ?? this.headers,
      isRedirect: isRedirect ?? this.isRedirect,
      persistentConnection: persistentConnection ?? this.persistentConnection,
      reasonPhrase: reasonPhrase ?? this.reasonPhrase,
      inner: inner,
    );
  }
}
