# http_interceptor

[![Pub](https://img.shields.io/pub/v/http_interceptor.svg)](https://pub.dev/packages/http_interceptor)
[![style: lints/recommended](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![codecov](https://codecov.io/gh/CodingAleCR/http_interceptor/branch/main/graph/badge.svg?token=hgsnPctaDz)](https://codecov.io/gh/CodingAleCR/http_interceptor)
[![Star on GitHub](https://img.shields.io/github/stars/codingalecr/http_interceptor.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/codingalecr/http_interceptor)

<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-21-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

This is a plugin that lets you intercept the different requests and responses from Dart's http package. You can use to add headers, modify query params, or print a log of the response.

## Quick Reference

**Already using `http_interceptor`? Check out the [1.0.0 migration guide](./guides/migration_guide_1.0.0.md) for quick reference on the changes made and how to migrate your code.**

- [http\_interceptor](#http_interceptor)
  - [Quick Reference](#quick-reference)
  - [Installation](#installation)
  - [Features](#features)
  - [Usage](#usage)
    - [Building your own interceptor](#building-your-own-interceptor)
    - [Using your interceptor](#using-your-interceptor)
      - [Using interceptors with Client](#using-interceptors-with-client)
      - [Using interceptors without Client](#using-interceptors-without-client)
    - [Retrying requests](#retrying-requests)
    - [Using self signed certificates](#using-self-signed-certificates)
    - [InterceptedClient](#interceptedclient)
    - [InterceptedHttp](#interceptedhttp)
  - [Roadmap](#roadmap)
  - [Troubleshooting](#troubleshooting)
  - [Contributions](#contributions)
    - [Contributors](#contributors)

## Installation

Include the package with the latest version available in your `pubspec.yaml`.

```dart
http_interceptor: <latest>
```

## Features

- 🚦 Intercept & change unstreamed requests and responses.
- ✨ Retrying requests when an error occurs or when the response does not match the desired (useful for handling custom error responses).
- 👓 `GET` requests with separated parameters.
- ⚡️ Standard `bodyBytes` on `ResponseData` to encode or decode in the desired format.
- 🙌🏼 Array parameters on requests.
- 🖋 Supports self-signed certificates (except on Flutter Web).
- 🍦 Compatible with vanilla Dart projects or Flutter projects.
- 🎉 Null-safety.
- ⏲ Timeout configuration with duration and timeout functions.
- ⏳ Configure the delay for each retry attempt.

## Usage

```dart
import 'package:http_interceptor/http_interceptor.dart';
```

### Building your own interceptor

In order to implement `http_interceptor` you need to implement the `InterceptorContract` and create your own interceptor. This abstract class has four methods:

 - `interceptRequest`, which triggers before the http request is called 
 - `interceptResponse`, which triggers after the request is called, it has a response attached to it which the corresponding to said request;
 
- `shouldInterceptRequest` and `shouldInterceptResponse`, which are used to determine if the request or response should be intercepted or not. These two methods are optional as they return `true` by default, but they can be useful if you want to conditionally intercept requests or responses based on certain criteria. 

You could use this package to do logging, adding headers, error handling, or many other cool stuff. It is important to note that after you proccess the request/response objects you need to return them so that `http` can continue the execute.

All four methods use `FutureOr` syntax, which makes it easier to support both synchronous and asynchronous behaviors.

- Logging with interceptor:

```dart
class LoggerInterceptor extends InterceptorContract {
  @override
  BaseRequest interceptRequest({
    required BaseRequest request,
  }) {
    print('----- Request -----');
    print(request.toString());
    print(request.headers.toString());
    return request;
  }

  @override
  BaseResponse interceptResponse({
    required BaseResponse response,
  }) {
    log('----- Response -----');
    log('Code: ${response.statusCode}');
    if (response is Response) {
      log((response).body);
    }
    return response;
  }
}
```

- Changing headers with interceptor:

```dart
class WeatherApiInterceptor implements InterceptorContract {
  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      request.url.queryParameters['appid'] = OPEN_WEATHER_API_KEY;
      request.url.queryParameters['units'] = 'metric';
      request.headers[HttpHeaders.contentTypeHeader] = "application/json";
    } catch (e) {
      print(e);
    }
    return request;
  }

  @override
  BaseResponse interceptResponse({
  required BaseResponse response,
  }) =>
      response;
  
  @override
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) async {
    // You can conditionally intercept requests here
    return true; // Intercept all requests
  }

  @override
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) async {
    // You can conditionally intercept responses here
    return true; // Intercept all responses
  }
}
```

- You can also react to and modify specific types of requests and responses, such as `StreamedRequest`,`StreamedResponse`, or `MultipartRequest` :

```dart
class MultipartRequestInterceptor implements InterceptorContract {
  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    if(request is MultipartRequest){
      request.fields['app_version'] = await PackageInfo.fromPlatform().version;
    }
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) async {
    if(response is StreamedResponse){
      response.stream.asBroadcastStream().listen((data){
        print(data);
      });
    }
    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) async {
    // You can conditionally intercept requests here
    return true; // Intercept all requests
  }

  @override
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) async {
    // You can conditionally intercept responses here
    return true; // Intercept all responses
  }
}
```

### Using your interceptor

Now that you actually have your interceptor implemented, now you need to use it. There are two general ways in which you can use them: by using the `InterceptedHttp` to do separate connections for different requests or using a `InterceptedClient` for keeping a connection alive while making the different `http` calls. The ideal place to use them is in the service/provider class or the repository class (if you are not using services or providers); if you don't know about the repository pattern you can just google it and you'll know what I'm talking about. 😉

#### Using interceptors with Client

Normally, this approach is taken because of its ability to be tested and mocked.

Here is an example with a repository using the `InterceptedClient` class.

```dart
class WeatherRepository {
  Client client = InterceptedClient.build(interceptors: [
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

Here is an example with a repository using the `InterceptedHttp` class.

```dart
class WeatherRepository {

    Future<Map<String, dynamic>> fetchCityWeather(int id) async {
    var parsedWeather;
    try {
      final http = InterceptedHttp.build(interceptors: [
          WeatherApiInterceptor(),
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
  int get maxRetryAttempts => 2;

  @override
  bool shouldAttemptRetryOnException(Exception reason, BaseRequest request) {
    // Log the exception for debugging
    print('Request failed: ${reason.toString()}');
    print('Request URL: ${request.url}');
    
    // Retry on network exceptions, but not on client errors
    return reason is SocketException || reason is TimeoutException;
  }

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 401) {
      // Perform your token refresh here.
      print('Token expired, refreshing...');
      
      return true;
    }

    return false;
  }
}
```

You can also set the maximum amount of retry attempts with `maxRetryAttempts` property or override the `shouldAttemptRetryOnException` if you want to retry the request after it failed with an exception.

### RetryPolicy Interface

The `RetryPolicy` abstract class provides the following methods that you can override:

- **`shouldAttemptRetryOnException(Exception reason, BaseRequest request)`**: Called when an exception occurs during the request. Return `true` to retry, `false` to fail immediately.
- **`shouldAttemptRetryOnResponse(BaseResponse response)`**: Called after receiving a response. Return `true` to retry, `false` to accept the response.
- **`maxRetryAttempts`**: The maximum number of retry attempts (default: 1).
- **`delayRetryAttemptOnException({required int retryAttempt})`**: Delay before retrying after an exception (default: no delay).
- **`delayRetryAttemptOnResponse({required int retryAttempt})`**: Delay before retrying after a response (default: no delay).

### Using Retry Policies

To use a retry policy, pass it to the `InterceptedClient` or `InterceptedHttp`:

```dart
final client = InterceptedClient.build(
  interceptors: [WeatherApiInterceptor()],
  retryPolicy: ExpiredTokenRetryPolicy(),
);
```

Sometimes it is helpful to have a cool-down phase between multiple requests. This delay could for example also differ between the first and the second retry attempt as shown in the following example.

```dart
class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 3;

  @override
  bool shouldAttemptRetryOnException(Exception reason, BaseRequest request) {
    // Only retry on network-related exceptions
    return reason is SocketException || reason is TimeoutException;
  }

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    // Retry on server errors (5xx) and authentication errors (401)
    return response.statusCode >= 500 || response.statusCode == 401;
  }

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) {
    // Exponential backoff for exceptions
    return Duration(milliseconds: (250 * math.pow(2.0, retryAttempt - 1)).round());
  }

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) {
    // Exponential backoff for response-based retries
    return Duration(milliseconds: (250 * math.pow(2.0, retryAttempt - 1)).round());
  }
}
```

### Using self signed certificates

You can achieve support for self-signed certificates by providing `InterceptedHttp` or `InterceptedClient` with the `client` parameter when using the `build` method on either of those, it should look something like this:

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

_**Note:** It is important to know that since both HttpClient and IOClient are part of `dart:io` package, this will not be a feature that you can perform on Flutter Web (due to `BrowserClient` and browser limitations)._

## Roadmap

Check out our roadmap [here](https://doc.clickup.com/p/h/82gtq-119/f552a826792c049).

_We migrated our roadmap to better suit the needs for development since we use ClickUp as our task management tool._

## Troubleshooting

Open an issue and tell me, I will be happy to help you out as soon as I can.

## Contributions

Contributions are always welcomed and encouraged, we will always give you credit for your work on this section. If you are interested in maintaining the project on a regular basis drop me a line at [me@codingale.dev](mailto:me@codingale.dev).

### Contributors

Thanks to all the wonderful people contributing to improve this package. Check the [Emoji Key](https://github.com/kentcdodds/all-contributors#emoji-key) for reference on what means what!

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://codingale.dev"><img src="https://avatars.githubusercontent.com/u/12262852?v=3?s=100" width="100px;" alt="Alejandro Ulate Fallas"/><br /><sub><b>Alejandro Ulate Fallas</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=codingalecr" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=codingalecr" title="Documentation">📖</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=codingalecr" title="Tests">⚠️</a> <a href="#ideas-codingalecr" title="Ideas, Planning, & Feedback">🤔</a> <a href="#maintenance-codingalecr" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://softmaestri.com/en/"><img src="https://avatars.githubusercontent.com/u/4113558?v=4?s=100" width="100px;" alt="Konstantin Serov"/><br /><sub><b>Konstantin Serov</b></sub></a><br /><a href="#ideas-caseyryan" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Virus1908"><img src="https://avatars.githubusercontent.com/u/4580305?v=4?s=100" width="100px;" alt="Virus1908"/><br /><sub><b>Virus1908</b></sub></a><br /><a href="#ideas-Virus1908" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=Virus1908" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=Virus1908" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/AsynchronySuperWes"><img src="https://avatars.githubusercontent.com/u/13644053?v=4?s=100" width="100px;" alt="Wes Ehrlichman"/><br /><sub><b>Wes Ehrlichman</b></sub></a><br /><a href="#ideas-AsynchronySuperWes" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=AsynchronySuperWes" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=AsynchronySuperWes" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jlubeck"><img src="https://avatars.githubusercontent.com/u/3067603?v=4?s=100" width="100px;" alt="Jan Lübeck"/><br /><sub><b>Jan Lübeck</b></sub></a><br /><a href="#ideas-jlubeck" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=jlubeck" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=jlubeck" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lucalves"><img src="https://avatars.githubusercontent.com/u/17712401?v=4?s=100" width="100px;" alt="Lucas Alves"/><br /><sub><b>Lucas Alves</b></sub></a><br /><a href="#ideas-lucalves" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=lucalves" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=lucalves" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stewemetal"><img src="https://avatars.githubusercontent.com/u/5860632?v=4?s=100" width="100px;" alt="István Juhos"/><br /><sub><b>István Juhos</b></sub></a><br /><a href="#ideas-stewemetal" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=stewemetal" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=stewemetal" title="Tests">⚠️</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/shyndman"><img src="https://avatars.githubusercontent.com/u/42326?v=4?s=100" width="100px;" alt="Scott Hyndman"/><br /><sub><b>Scott Hyndman</b></sub></a><br /><a href="#ideas-shyndman" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/II11II"><img src="https://avatars.githubusercontent.com/u/45257709?v=4?s=100" width="100px;" alt="Islam Akhrarov"/><br /><sub><b>Islam Akhrarov</b></sub></a><br /><a href="#ideas-II11II" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=II11II" title="Tests">⚠️</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=II11II" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/meysammahfouzi"><img src="https://avatars.githubusercontent.com/u/14848008?v=4?s=100" width="100px;" alt="Meysam"/><br /><sub><b>Meysam</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=meysammahfouzi" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Mawi137"><img src="https://avatars.githubusercontent.com/u/5464100?v=4?s=100" width="100px;" alt="Martijn"/><br /><sub><b>Martijn</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=Mawi137" title="Tests">⚠️</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=Mawi137" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MaciejZuk"><img src="https://avatars.githubusercontent.com/u/78476165?v=4?s=100" width="100px;" alt="MaciejZuk"/><br /><sub><b>MaciejZuk</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/issues?q=author%3AMaciejZuk" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lukaskurz"><img src="https://avatars.githubusercontent.com/u/22956519?v=4?s=100" width="100px;" alt="Lukas Kurz"/><br /><sub><b>Lukas Kurz</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=lukaskurz" title="Tests">⚠️</a> <a href="#ideas-lukaskurz" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=lukaskurz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/vixez"><img src="https://avatars.githubusercontent.com/u/3032294?v=4?s=100" width="100px;" alt="Glenn Ruysschaert"/><br /><sub><b>Glenn Ruysschaert</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=vixez" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=vixez" title="Tests">⚠️</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/dexcell"><img src="https://avatars.githubusercontent.com/u/41800?v=4?s=100" width="100px;" alt="Erick"/><br /><sub><b>Erick</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=dexcell" title="Code">💻</a> <a href="https://github.com/CodingAleCR/http_interceptor/commits?author=dexcell" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/javiermrz"><img src="https://avatars.githubusercontent.com/u/46677628?v=4?s=100" width="100px;" alt="javiermrz"/><br /><sub><b>javiermrz</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=javiermrz" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ntimesc"><img src="https://avatars.githubusercontent.com/u/5063898?v=4?s=100" width="100px;" alt="nihar"/><br /><sub><b>nihar</b></sub></a><br /><a href="#ideas-ntimesc" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ayyysh04"><img src="https://avatars.githubusercontent.com/u/74104690?v=4?s=100" width="100px;" alt="Ayush Yadav"/><br /><sub><b>Ayush Yadav</b></sub></a><br /><a href="#ideas-ayyysh04" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/shittyday"><img src="https://avatars.githubusercontent.com/u/88209828?v=4?s=100" width="100px;" alt="Alex"/><br /><sub><b>Alex</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=shittyday" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/iruizr7"><img src="https://avatars.githubusercontent.com/u/65398602?v=4?s=100" width="100px;" alt="Iñigo R."/><br /><sub><b>Iñigo R.</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=iruizr7" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/td2thinh"><img src="https://avatars.githubusercontent.com/u/75013885?v=4?s=100" width="100px;" alt="Thinh TRUONG"/><br /><sub><b>Thinh TRUONG</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=td2thinh" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KacperKluka"><img src="https://avatars.githubusercontent.com/u/62378170?v=4?s=100" width="100px;" alt="KacperKluka"/><br /><sub><b>KacperKluka</b></sub></a><br /><a href="https://github.com/CodingAleCR/http_interceptor/commits?author=KacperKluka" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
