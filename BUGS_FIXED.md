# Bugs Fixed in HTTP Interceptor

## Bug #1: `maxRetryAttempts` cannot be overridden in subclasses

**File**: `lib/models/retry_policy.dart`
**Issue**: The `maxRetryAttempts` field was declared as `final int maxRetryAttempts = 1;` which prevented subclasses from overriding it.
**Fix**: Changed it to `int get maxRetryAttempts => 1;` to allow subclasses to override the getter.
**Impact**: This allows proper inheritance for retry policies, as demonstrated in the example where `ExpiredTokenRetryPolicy` overrides `maxRetryAttempts` to return 2.

## Bug #2: `_attemptRequest` recursive calls missing `isStream` parameter

**File**: `lib/http/intercepted_client.dart`
**Issue**: When retrying requests, the recursive calls to `_attemptRequest` didn't pass the `isStream` parameter, which could cause issues when retrying streamed requests.
**Fix**: Added `isStream: isStream` parameter to both recursive calls in the retry logic (lines 295 and 304).
**Impact**: This ensures that streamed requests are properly handled during retries, maintaining the correct response type.

## Bug #3: URI fragment (#) is lost in `addParameters` method

**File**: `lib/extensions/uri.dart`
**Issue**: The `addParameters` method used `origin + path` to build the URL but ignored the fragment part of the URI, causing fragments to be lost.
**Fix**: Added logic to preserve the fragment by appending `#$fragment` to the final URL if a fragment exists.
**Impact**: This ensures that URI fragments are preserved when adding query parameters, maintaining the complete URL structure.

All three bugs have been successfully fixed and the code should now work correctly in all scenarios.