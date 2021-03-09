# http_interceptor

[![Pub](https://img.shields.io/pub/v/http_interceptor.svg)](https://pub.dev/packages/http_interceptor)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![codecov](https://codecov.io/gh/CodingAleCR/http_interceptor/branch/master/graph/badge.svg)](https://codecov.io/gh/CodingAleCR/http_interceptor)
[![Star on GitHub](https://img.shields.io/github/stars/codingalecr/http_interceptor.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/codingalecr/http_interceptor)

This is a plugin that lets you intercept the different requests and responses from Dart's http package. You can use to add headers, modify query params, or print a log of the response.

## Quick Reference

**Already using `http_interceptor`? Check out the [0.4.0 migration guide](./guides/migration_guide_4.md) for quick reference on the changes made and how to migrate your code.**

- [Installation](#installation)
- [Usage](#usage)
  - [Building your own interceptor](#building-your-own-interceptor)
  - [Using your interceptor](#using-your-interceptor)
  - [Retrying requests](#retrying-requests)
  - [Using self-signed certificates](#using-self-signed-certificates)
- [Having trouble? Fill an issue](#troubleshooting)
- [Roadmap](https://doc.clickup.com/p/h/82gtq-119/f552a826792c049)
- [Contribution](#contributions)

## Installation

Include the package with the latest version available in your `pubspec.yaml`.

```dart
    http_interceptor: ^0.4.0
```

## Usage

```dart
import 'package:http_interceptor/http_interceptor.dart';
```

### Building your own interceptor

In order to implement `http_interceptor` you need to implement the `InterceptorContract` and create your own interceptor. This abstract class has two methods: `interceptRequest`, which triggers before the http request is called; and `interceptResponse`, which triggers after the request is called, it has a response attached to it which the corresponding to said request. You could use this to do logging, adding headers, error handling, or many other cool stuff. It is important to note that after you proccess the request/response objects you need to return them so that `http` can continue the execute.

- Logging with interceptor:

```dart
class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    print(data.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
      print(data.toString());
      return data;
  }

}
```

- Changing headers with interceptor:

```dart
class WeatherApiInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    try {
      data.params['appid'] = OPEN_WEATHER_API_KEY;
      data.params['units'] = 'metric';
      data.headers["Content-Type"] = "application/json";
    } catch (e) {
      print(e);
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async => data;
}
```

### Using your interceptor

Now that you actually have your interceptor implemented, now you need to use it. There are two general ways in which you can use them: by using the `HttpWithInterceptor` to do separate connections for different requests or using a `HttpClientWithInterceptor` for keeping a connection alive while making the different `http` calls. The ideal place to use them is in the service/provider class or the repository class (if you are not using services or providers); if you don't know about the repository pattern you can just google it and you'll know what I'm talking about. 😉

#### Using interceptors with Client

Normally, this approach is taken because of its ability to be tested and mocked.

Here is an example with a repository using the `HttpClientWithInterceptor` class.

```dart
class WeatherRepository {
  Client client = HttpClientWithInterceptor.build(interceptors: [
      WeatherApiInterceptor(),
  ]);

  Future<Map<String, dynamic>> fetchCityWeather(int id) async {
    var parsedWeather;
    try {
      final response =
          await client.get("$baseUrl/weather".toUri(), params: {'id': "$id"});
      if (response.statusCode == 200) {
        parsedWeather = json.decode(response.body);
      } else {
        throw Exception("Error while fetching. \n ${response.body}");
      }
    } catch (e) {
      print(e);
    }
    return parsedWeather;
  }

}
```

#### Using interceptors without Client

This is mostly the straight forward approach for a one-and-only call that you might need intercepted.

Here is an example with a repository using the `HttpWithInterceptor` class.

```dart
class WeatherRepository {

    Future<Map<String, dynamic>> fetchCityWeather(int id) async {
    var parsedWeather;
    try {
      WeatherApiInterceptor http = HttpWithInterceptor.build(interceptors: [
          Logger(),
      ]);
      final response =
          await http.get("$baseUrl/weather".toUri(), params: {'id': "$id"});
      if (response.statusCode == 200) {
        parsedWeather = json.decode(response.body);
      } else {
        return Future.error(
          "Error while fetching.",
          StackTrace.fromString("${response.body}"),
        );
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException {
      return Future.error('Bad response format 👎');
    } on Exception {
      return Future.error('Unexpected error 😢');
    }

    return parsedWeather;
  }

}
```

### Retrying requests

Sometimes you need to retry a request due to different circumstances, an expired token is a really good example. Here's how you could potentially implement an expired token retry policy with `http_interceptor`.

```dart
class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    if (response.statusCode == 401) {
      // Perform your token refresh here.

      return true;
    }

    return false;
  }
}
```

You can also set the maximum amount of retry attempts with `maxRetryAttempts` property or override the `shouldAttemptRetryOnException` if you want to retry the request after it failed with an exception.

### Using self signed certificates (Only on iOS and Android)

This plugin allows you to override the default `badCertificateCallback` provided by Dart's `io` package, this is really useful when working with self-signed certificates in your server. This can be done by sending a the callback to the HttpInterceptor builder functions. This feature is marked as experimental and **will be subject to change before release 1.0.0 comes**.

```dart
class WeatherRepository {

  Future<Map<String, dynamic>> fetchCityWeather(int id) async {
    var parsedWeather;
    try {
      var response = await HttpWithInterceptor.build(
              interceptors: [WeatherApiInterceptor()],
              badCertificateCallback: (certificate, host, port) => true)
          .get("$baseUrl/weather", params: {'id': "$id"});
      if (response.statusCode == 200) {
        parsedWeather = json.decode(response.body);
      } else {
        throw Exception("Error while fetching. \n ${response.body}");
      }
    } catch (e) {
      print(e);
    }
    return parsedWeather;
  }

}
```

## Roadmap

Check out our roadmap [here](https://doc.clickup.com/p/h/82gtq-119/f552a826792c049).

_We migrated our roadmap to better suit the needs for development since we use ClickUp as our task management tool._

## Troubleshooting

Open an issue and tell me, I will be happy to help you out as soon as I can.

## Contributions

Contributions are always welcomed and encouraged, we will always give you credit for your work on this section. If you are interested in maintaining the project on a regular basis drop me a line at me@codingale.dev.

### Team

- Alejandro Ulate ([@CodingAleCR](https://github.com/CodingAleCR))

### Contributors

- Wes Ehrlichman ([@AsynchronySuperWes](https://github.com/AsynchronySuperWes))
- Jan Lübeck ([@jlubeck](https://github.com/jlubeck))
- Lucas Alves ([@lucalves](https://github.com/lucalves))
- István Juhos ([@stewemetal](https://github.com/stewemetal))
