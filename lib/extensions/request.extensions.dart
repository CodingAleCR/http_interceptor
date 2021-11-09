import 'dart:convert';

import 'package:http/http.dart';

extension RequestCopyWith on Request {
  Request copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final req = Request(
      method ?? this.method,
      url ?? this.url,
    );
    if (headers != null) {
      req.headers.clear();
      req.headers.addAll(headers);
    }
    if (body != null) {
      if (body is String) {
        req.body = body;
      } else if (body is List<int>) {
        req.bodyBytes = body;
      } else if (body is Map<String, String>) {
        req.bodyFields = body;
      }
      throw UnsupportedError('Unsupported body type: ${body.runtimeType}');
    }
    if (encoding != null) {
      req.encoding = encoding;
    }
    if (followRedirects != null) {
      req.followRedirects = followRedirects;
    }
    if (maxRedirects != null) {
      req.maxRedirects = maxRedirects;
    }
    if (persistentConnection != null) {
      req.persistentConnection = persistentConnection;
    }

    return req;
  }
}

extension MultipartCopyWith on MultipartRequest {
  MultipartRequest copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<MultipartFile>? files,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final req = MultipartRequest(
      method ?? this.method,
      url ?? this.url,
    );
    if (headers != null) {
      req.headers.clear();
      req.headers.addAll(headers);
    }

    if (fields != null) {
      req.fields.clear();
      req.fields.addAll(fields);
    }
    if (files != null) {
      req.files.clear();
      req.files.addAll(files);
    }

    if (followRedirects != null) {
      req.followRedirects = followRedirects;
    }
    if (maxRedirects != null) {
      req.maxRedirects = maxRedirects;
    }
    if (persistentConnection != null) {
      req.persistentConnection = persistentConnection;
    }

    return req;
  }
}

extension StreamedRequestCopyWith on StreamedRequest {
  StreamedRequest copyWith({
    String? method,
    Uri? url,
    Map<String, String>? headers,
    Stream<List<int>>? stream,
    Encoding? encoding,
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final req = StreamedRequest(
      method ?? this.method,
      url ?? this.url,
    );
    if (headers != null) {
      req.headers.clear();
      req.headers.addAll(headers);
    }
    if (stream != null) {
      stream.listen((data) {
        req.sink.add(data);
      });
      this.finalize().listen((data) {
        req.sink.add(data);
      });
    }
    if (followRedirects != null) {
      req.followRedirects = followRedirects;
    }
    if (maxRedirects != null) {
      req.maxRedirects = maxRedirects;
    }
    if (persistentConnection != null) {
      req.persistentConnection = persistentConnection;
    }

    return req;
  }
}
