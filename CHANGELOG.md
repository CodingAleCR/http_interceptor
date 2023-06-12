# Changelog

## 2.0.0-beta.7
### What's Changed
* docs: add ntimesc as a contributor for ideas by @allcontributors in https://github.com/CodingAleCR/http_interceptor/pull/116
* updated packages by @mauryagaurav947 in https://github.com/CodingAleCR/http_interceptor/pull/129

### New Contributors
* @mauryagaurav947 made their first contribution in https://github.com/CodingAleCR/http_interceptor/pull/129

**Full Changelog**: https://github.com/CodingAleCR/http_interceptor/compare/2.0.0-beta.6...2.0.0-beta.7

## 2.0.0-beta.6

- ✨&nbsp;&nbsp;Added: `Future<bool> shouldInterceptRequest()` and `Future<bool> shouldInterceptResponse()`. This enables individual interceptor checks and conditional intercepting configurations.
- ✨&nbsp;&nbsp;Added: `bodyBytes` to `Request.copyWith`. This adds support to set and modify the body as a stream of bytes.
- ❗️🛠&nbsp;&nbsp;Changed: `RetryPolicy` to be `Future<bool>` instead of `bool` so that you can support different exception retrying scenarios (See #115).
- 📖&nbsp;&nbsp;Changed: **example** project to showcase updated Flutter 3.0, new library APIs and `MultipartRequest` handling.

## 2.0.0-beta.5

- ✨&nbsp;&nbsp;Added: Support for `onRequestTimeout` when setting up `requestTimeout` on the interceptor.

## 2.0.0-beta.4

- ❗️🛠&nbsp;&nbsp;Changed: `shouldAttemptRetryOnException` will now also pass the `BaseRequest`.
- 🚦&nbsp;&nbsp;Tests: Updated tests.

## 2.0.0-beta.3

- 🐞&nbsp;&nbsp;Fixed: `MultipartRequest` does not get intercepted correctly (has missing fields).
- 🐞&nbsp;&nbsp;Fixed: `MultipartRequest` ignores retry policy.
- 🐞&nbsp;&nbsp;Fixed: Changing `body` causes that the `headers` also change and ignore previous interceptions (i.e. content-type headers are overriden).
- 🐞&nbsp;&nbsp;Fixed: `copyWith` was missing fields
- 🚦&nbsp;&nbsp;Tests: Updated tests.

## 2.0.0-beta.2

- 🐞&nbsp;&nbsp;Fixed: Changing `body` causes that the `headers` also change and ignore previous interceptions (i.e. content-type headers are overriden).
- 🚦&nbsp;&nbsp;Tests: Updated tests.

## 2.0.0-beta.1

- ❗️🛠&nbsp;&nbsp;Changed: Renamed `Method` to use `HttpMethod` and refactored helper functions into extensions (`StringToMethod`, and `MethodToString`).
- ❗️🛠&nbsp;&nbsp;Changed: `InterceptorContract` to use `BaseRequest` and `BaseResponse` instead of custom models.
- ❗️🛠&nbsp;&nbsp;Removed: `RequestData` and `ResponseData` since the classes are no longer used.
- ✨&nbsp;&nbsp;Added: Support for intercepting `Request`,`StreamedRequest` and `MultipartRequest`.
- ✨&nbsp;&nbsp;Added: Support for intercepting `Response`,`StreamedResponse` and `MultipartRequest`.
- ✨&nbsp;&nbsp;Added: Extensions for `BaseRequest`, `Request`,`StreamedRequest` and `MultipartRequest` that allows copying requests through a `copyWith` method.
- ✨&nbsp;&nbsp;Added: Extensions for `BaseResponse`, `Response`,`StreamedResponse` and `IOStreamedResponse` that allows copying responses through a `copyWith` method.
- 📖&nbsp;&nbsp;Changed: **example** project to showcase updated APIs.
- 🚦&nbsp;&nbsp;Tests: Improved testing and documentation.

## 1.0.2

- 📖&nbsp;&nbsp;Changed: example project to showcase `RetryPolicy` usage.
- 🐞&nbsp;&nbsp;Fixed: `parameters` were missing in requests of type `POST`, `PUT`, `PATCH`, and `DELETE`.
- 🐞&nbsp;&nbsp;Fixed: `int` or other non-string parameters are not being added to request. Thanks to @meysammahfouzi
- 🐞&nbsp;&nbsp;Fixed: `body` is not sent in delete requests despite being accepted as parameter. Thanks to @MaciejZuk

## 1.0.1

- ✨&nbsp;&nbsp;Changed: `ResponseData` now has `request` to allow checking on the request that triggered the response. Thanks to @II11II
- 🐞&nbsp;&nbsp;Fixed: Use `queryParametersAll` when creating `RequestData`. Thanks to @Mawi137
- 📖&nbsp;&nbsp;Fixed: `README` to include `required` keywords needed. Thanks to @meysammahfouzi
- 🚦&nbsp;&nbsp;Tests: Improved testing and documentation.

## 1.0.0

Check out the [1.0.0 migration guide](./guides/migration_guide_1.0.0.md) for information on how to migrate your code.

- ❗️🛠&nbsp;&nbsp;Changed: Renamed `HttpClientWithInterceptor` to `InterceptedClient`.
- ❗️🛠&nbsp;&nbsp;Changed: Renamed `HttpWithInterceptor` to `InterceptedHttp`.
- ❗️🛠&nbsp;&nbsp;Removed: `badCertificateCallback` from `InterceptedClient` and `InterceptedHttp` in order to fully support Flutter Web 🌐 . In order to use refer to the migration guide.
- ✨&nbsp;&nbsp;Added: Array parameters on `RequestData` following a similar principle than `http`'s `queryParametersAll` .
- ✨&nbsp;&nbsp;Changed: `ResponseData` now has `bodyBytes` to allow encoding or decoding in the format desired.
- ✨&nbsp;&nbsp;Changed: Migrated tests to use `test` package instead of `flutter_test`.
- ✨&nbsp;&nbsp;Changed: More tests and coverage, this is a work in progress.
- 🗑&nbsp;&nbsp;Removed: Package no longer depends on Flutter, which means that it can be used with standalone Dart projects.

## 0.4.1

- 🛠&nbsp;&nbsp;Changed: Pre initialized `headers` and `params` on `RequestData`. This was a missed change on null-safety migration.

## 0.4.0

Check out [our 0.4.0 migration guide](./guides/migration_guide_0.4.0.md) for information on how to migrate your code.

- ❗️✨&nbsp;&nbsp;Added: String extension to allow `toUri()` usage when importing the library. Since `http` dropped support for string url usage and since Dart does not yet support function overloading, we had to implement an alternative through extensions.
- ✨&nbsp;&nbsp;Added: Flutter web support 🌐 &nbsp;&nbsp;(`badCertificateCallback` and `findProxy` features are not supported on Flutter Web due to browser limitations)
- 🛠&nbsp;&nbsp;Changed: Upgraded `http` to `0.13.0`.
- 🛠&nbsp;&nbsp;Changed: Upgraded `effective_dart` to `1.3.0`.
- 🛠&nbsp;&nbsp;Changed: Upgraded Dart `sdk` to `>=2.12.0 <3.0.0`. (Yay! Sound null safety! 🎉)
- 🗑&nbsp;&nbsp;Removed: `meta` is removed since Dart's null safety now covers all uses inside this plugin

## 0.3.3

- 🛠&nbsp;&nbsp;Changed: Plugin no longer depends on the `flutter/foundation.dart`, instead it uses `meta` plugin which allows for usage on non flutter environments.
- 🛠&nbsp;&nbsp;Changed: README now features a contribution and a roadmap sections for improving visibility on the project's future.
- 🛠&nbsp;&nbsp;Changed: `badCertificateCallback` is now available to use without the experimental tag.

## 0.3.2

- 🛠&nbsp;&nbsp;Changed: Example now showcases exception handling.
- 🛠&nbsp;&nbsp;Changed: README now showcases exception handling.
- 🐞&nbsp;&nbsp;Fixed: Interceptor no longer using custom exceptions, instead it rethrows in the case that the retry policy is not set or if it has reached max attempts.

## 0.3.1

- 🐞&nbsp;&nbsp;Fixed: Retry Policy's `shouldAttemptRetryOnResponse` was synchronous which would not allow async token updates.
- 🐞&nbsp;&nbsp;Fixed: Retry Policy would only trigger once when using `HttpClientWithInterceptor`.
- 🐞&nbsp;&nbsp;Fixed: Retry Policy would use the `http` Response class, which would force plugin users to add http plugin separately.
- 🧪&nbsp;&nbsp;Experimental: `badCertificateCallback` allows you to use self-signing certificates.

## 0.3.0

- ✨&nbsp;&nbsp;Added: RetryPolicy. It allows to attempt retries on a request when an exception occurs or when a condition from the response is met.
- 🐞&nbsp;&nbsp;Fixed: URI type urls not concatenating parameters.

## 0.2.0

- ✨&nbsp;&nbsp;Added: Unit testing for a few of the files.
- 🛠&nbsp;&nbsp;Changed: Android and iOS projects both in the plugin and the example now use Kotlin/Swift.
- 🛠&nbsp;&nbsp;Changed: Android projects both in the plugin and the example now use AndroidX namespaces.
- 🐞&nbsp;&nbsp;Fixed: Last ' ' character was not removed from parametized URLs.
- 🐞&nbsp;&nbsp;Fixed: Duplicate GET parameters when using `get`.

## 0.1.1

- 🐞&nbsp;&nbsp;Fixed: HTTP Methods have misaligned parameters. Now they are called via named parameters to avoid type mismatch exceptions when being used.

## 0.1.0

- ✨&nbsp;&nbsp;Added: Query Parameters to GET requests, it allows you to set proper parameters without having to add them to the URL beforehand.
- 🛠&nbsp;&nbsp;Changed: Documentation for the example to include the new Query Parameters usage.

## 0.0.3

- ✨&nbsp;&nbsp;Added: Documentation for the example.

## 0.0.2

- 🐞&nbsp;&nbsp;Fixed: All the warnings regarding plugin publication.

## 0.0.1

- ✨&nbsp;&nbsp;Added: Initial plugin implementation.
- ✨&nbsp;&nbsp;Added: Example of usage for the plugin.
- ✨&nbsp;&nbsp;Added: README.md and LICENSE files.
