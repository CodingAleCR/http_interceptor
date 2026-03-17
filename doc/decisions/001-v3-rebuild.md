# V3 from-scratch rebuild

Date: 2025-03-15

Status: accepted

## Context

The library was initally a rewrite of [http_middleware](https://pub.dev/packages/http_middleware). It has reached 2.0.0 with a full feature set (interceptors, retry, timeout, copyWith on requests/responses, query params, etc.). However, the existing implementation had accumulated complexity and made a clean evolution difficult. A from-scratch rebuild was chosen to:

- Apply the principles, design patterns, and best practices.
- Avoid inheriting code smells and anti-patterns from the previous implementation.
- Prioritize a small API surface and clear behavior over backwards compatibility with 2.x.

The 2.0.0 API was used as a feature and API reference only; no backwards compatibility with 2.x is required.

## Decision

Rebuild the library as version 3 with the following decisions:

- **Decorator pattern**: The intercepted client wraps a `Client`, implements `Client`, and delegates to the inner client while adding interception. New behavior is added by composition (interceptors, retry, timeout), not by one large class.
- **Strategy pattern**: Interceptors define how to transform request/response; `RetryPolicy` defines when to retry and with what delay. Both are injectable strategies.
- **No copyWith in core**: Interceptors receive and return `BaseRequest`/`BaseResponse` from `package:http`. The supported pattern is in-place mutation or returning the same instance. Cloning (copyWith) was not added to the core API to keep the library simple; it can be a code smell (many clone surfaces). Importantly, `StreamedRequest` and `StreamedResponse` carry streams, which can be consumed only once—you cannot meaningfully “copy” a stream. A copyWith for those types would therefore be either limited (e.g. only URL and headers) or error-prone (e.g. reusing or re-wrapping the same stream). That constraint makes a uniform copyWith story across all request/response types fragile and reinforces the decision to avoid it in core.
- **Small composable units**: Interceptor chain runner, retry executor, and timeout wrapper are separate, testable units. The client’s `send()` orchestrates them in a clear order: request interceptors → (optional) timeout → send → response interceptors; retry re-runs from request interceptors when the policy allows.
- **InterceptedClient and InterceptedHttp**: `InterceptedClient` extends `BaseClient` and overrides `send()`; `InterceptedHttp` is a facade that holds an `InterceptedClient` and exposes `get`, `post`, etc., plus optional `close()`.
- **Single interceptor and retry abstractions**: One `HttpInterceptor` interface and one `RetryPolicy` interface; avoid overlapping or redundant abstractions (YAGNI).

## Consequences

- **Removed**: Backwards compatibility with 2.x; `RequestData`/`ResponseData`; copyWith in the core API; any structure or naming copied from the deleted implementation.
- **Added**: Clean implementation under `lib/src/` with interceptors, chain, retry, timeout, and client/facade; alignment with Decorator/Strategy and SOLID; guard clauses and linear control flow where possible.
- **Preserved (conceptually)**: Interceptor contract (intercept request/response, shouldIntercept flags), retry policy (on exception and on response, configurable delay), request timeout and callback, query params (`params`/`paramsAll`) on convenience methods, Uri and String extensions where they fit the minimal API.
- **Documentation**: Migration guide (e.g. [migration_guide_3.0.0.md](../../guides/migration_guide_3.0.0.md)) explains the break from 2.x and how to migrate (e.g. work with `BaseRequest`/`BaseResponse`, no copyWith).

