# Changelog

## 0.3.2

* Fixed: Interceptor no longer using custom exceptions, instead it rethrows in the case that the retry policy is not set or if it has reached max attempts.

## 0.3.1

* Fixed: Retry Policy's `shouldAttemptRetryOnResponse` was synchronous which would not allow async token updates.
* Fixed: Retry Policy would only trigger once when using `HttpClientWithInterceptor`.
* Fixed: Retry Policy would use the `http` Response class, which would force plugin users to add http plugin separately.
* Experimental: `badCertificateCallback` allows you to use self-signing certificates.

## 0.3.0

* Added: RetryPolicy. It allows to attempt retries on a request when an exception occurs or when a condition from the response is met.
* Fixed: URI type urls not concatenating parameters.

## 0.2.0

* Added: Unit testing for a few of the files.
* Modified: Android and iOS projects both in the plugin and the example now use Kotlin/Swift.
* Modified: Android projects both in the plugin and the example now use AndroidX namespaces.
* Fixed: Last '&' character was not removed from parametized URLs.
* Fixed: Duplicate GET parameters when using `get`.

## 0.1.1

* Fixed: HTTP Methods have misaligned parameters. Now they are called via named parameters to avoid type mismatch exceptions when being used.

## 0.1.0

* Added: Query Parameters to GET requests, it allows you to set proper parameters without having to add them to the URL beforehand.
* Modified: Documentation for the example to include the new Query Parameters usage.

## 0.0.3

* Added: Documentation for the example.

## 0.0.2

* Fixed: All the warnings regarding plugin publication.

## 0.0.1

* Added: Initial plugin implementation.
* Added: Example of usage for the plugin.
* Added: README.md and LICENSE files.
