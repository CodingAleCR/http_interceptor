# Migration guide to 3.0.0

Version 3 is a from-scratch rebuild. The API is simplified; there are breaking changes.

## Summary

- **Interceptor interface** is now `HttpInterceptor` (replaces `InterceptorContract`). Implement `HttpInterceptor`; methods are the same (`interceptRequest`, `interceptResponse`, `shouldInterceptRequest`, `shouldInterceptResponse`) with `FutureOr` support.
- **No RequestData/ResponseData** – use `BaseRequest` and `BaseResponse` from `package:http` only. Interceptors receive and return these types; use in-place mutation or return the same instance. There is no `copyWith` in the core API (cloning was removed to keep the library simple).
- **InterceptedClient** and **InterceptedHttp** are built with `InterceptedClient.build(...)` and `InterceptedHttp.build(...)` with the same options: `interceptors` (required), `client`, `retryPolicy`, `requestTimeout`, `onRequestTimeout`.
- **RetryPolicy** – implement the interface; same methods: `maxRetryAttempts`, `shouldAttemptRetryOnException(Exception, BaseRequest)`, `shouldAttemptRetryOnResponse(BaseResponse)`, `delayRetryAttemptOnException`, `delayRetryAttemptOnResponse`. All retry methods support `FutureOr<bool>`.
- **Params** – `get`, `post`, `put`, `patch`, `delete`, and `head` accept optional `params` and `paramsAll`; they are merged into the request URL. Use the `String.toUri()` extension for `'$baseUrl/path'.toUri()`.
- **Self-signed certificates** – pass your own `Client` (e.g. `IOClient` from `package:http/io_client.dart`). On Flutter web, do not import the IO client. For convenience, import `package:http_interceptor/http_interceptor_io.dart` on VM/mobile/desktop to get `IOClient` alongside the rest of the package.

## Steps

1. Replace `InterceptorContract` with `HttpInterceptor` and ensure your class implements (not extends) it.
2. Remove any use of `RequestData`/`ResponseData` and `copyWith` on requests/responses; work with `BaseRequest`/`BaseResponse` and mutate in place or return the same instance.
3. Keep using `InterceptedClient.build(interceptors: [...], client: ..., retryPolicy: ...)` and `InterceptedHttp.build(...)` with the same named parameters.
4. Update `RetryPolicy` implementations to implement the interface (all methods, including the delay methods if you need custom delays).
5. Use `'$url'.toUri()` for string URLs (extension from the package).
