import 'package:http/http.dart';

/// Converts a [StreamedResponse] into the [BaseResponse] that will be passed
/// to response interceptors.
///
/// Used by the pipeline so the same chain can run on either [StreamedResponse]
/// (for [Client.send]) or [Response] (for get/post/put/patch/delete after
/// reading the body).
typedef ResponseToIntercept = Future<BaseResponse> Function(
  StreamedResponse streamed,
);

/// Returns the [StreamedResponse] as-is. Use for [Client.send].
Future<BaseResponse> interceptStreamedResponse(StreamedResponse streamed) =>
    Future.value(streamed);

/// Reads the response body and returns a [Response]. Use for get/post/put/patch/delete.
Future<BaseResponse> interceptBufferedResponse(StreamedResponse streamed) =>
    Response.fromStream(streamed);
