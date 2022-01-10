# 🚀 Migration guide to 2.0.0

## ❗️ Migrate interceptors & retry policies

### Summary

`RequestData` and `ResponseData` were removed to make the library easier to maintain and extend on new request and response types.

Their usage was substituded on `InterceptorContract` and `RetryPolicy`, which now use `BaseRequest` and `BaseResponse` along with a new `copyWith` syntax that allows you to easily copy and manipulate requests and responses.

The new `copyWith` syntax also extends to `StreamedRequest`, `MultipartRequest`, `StreamedResponse` and `IOStreamedResponse` as well as the simple `Request` and `Response` classes.

### Migrating Interceptors

For interceptors you need to change the signature of the methods along with the logic around your interception. You can find an example in the code below:

v1.0.2 or lower

```dart
class WeatherApiInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    final cache = await SharedPreferences.getInstance();

    data.params['appid'] = cache.getString(kOWApiToken);
    data.params['units'] = 'metric';
    data.headers[HttpHeaders.contentTypeHeader] = "application/json";
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async =>
      data;
}
```

v2.0.0 and up

```dart
class WeatherApiInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final cache = await SharedPreferences.getInstance();

    final Map<String, String>? headers = Map.from(request.headers);
    headers?[HttpHeaders.contentTypeHeader] = "application/json";

    return request.copyWith(
      url: request.url.addParameters({
        'appid': cache.getString(kOWApiToken) ?? '',
        'units': 'metric',
      }),
      headers: headers,
    );
  }

  @override
  Future<BaseResponse> interceptResponse(
          {required BaseResponse response}) async =>
      response;
}
```

### Migrating Retry Policies

For `RetryPolicy` classes you just need to change the signature of `shouldAttemptRetryOnResponse`. You can find an example in the code below:

v1.0.2 or lower

```dart
class ExpiredTokenRetryPolicy extends RetryPolicy {

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    if (response.statusCode == 401) {
      print("Retrying request...");
      final cache = await SharedPreferences.getInstance();

      cache.setString(appToken, OPEN_WEATHER_API_KEY);

      return true;
    }

    return false;
  }
}
```

v2.0.0 and up

```dart
class ExpiredTokenRetryPolicy extends RetryPolicy {

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 401) {
      log("Retrying request...");
      final cache = await SharedPreferences.getInstance();

      cache.setString(kOWApiToken, OPEN_WEATHER_API_KEY);

      return true;
    }

    return false;
  }
}
```
