# 🚀 Migration guide to 1.0.0

## ❗️ Using `Client`

- Replace all instances of `HttpClientWithInterceptor` with `InterceptedClient`.

## ❗️ Using without `Client`

- Replace all instances of `HttpWithInterceptor` with `InterceptedHttp`.

## ❗️ Using self-signed certificates

Since the `badCertificatesCallback` can only be set for `HttpClient` which is part of the `dart:io` package, removing the built-in property was necessary in order to support Flutter Web.

You can still achieve support for self-signed certificates by providing `InterceptedHttp` or `InterceptedClient` with the `client` parameter when using the `build` method on either of those, it should look something like this:

### InterceptedClient

```dart
Client client = InterceptedClient.build(
  interceptors: [
    WeatherApiInterceptor(),
  ],
  client: IOClient(
    HttpClient()
      ..badCertificateCallback = badCertificateCallback
      ..findProxy = findProxy,
  );
);
```

### InterceptedHttp

```dart
final http = InterceptedHttp.build(
  interceptors: [
    WeatherApiInterceptor(),
  ],
  client: IOClient(
    HttpClient()
      ..badCertificateCallback = badCertificateCallback
      ..findProxy = findProxy,
  );
);
```
