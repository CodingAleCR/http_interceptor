import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_interceptor_example/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is just a List of Maps that contains the suggested cities.
/// If you are going to run this example you need to replace the key.
import 'cities.dart';
import 'credentials.dart';

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (ctx) => const WeatherApp());
  }

  @override
  WeatherAppState createState() => WeatherAppState();
}

class WeatherAppState extends State<WeatherApp> {
  WeatherRepository repository = WeatherRepository(
    InterceptedClient.build(
      interceptors: [
        WeatherApiInterceptor(),
        LoggerInterceptor(),
      ],
      retryPolicy: ExpiredTokenRetryPolicy(),
    ),
  );

  @override
  void initState() {
    super.initState();

    clearStorageForDemoPurposes();
  }

  Future<void> clearStorageForDemoPurposes() async {
    final cache = await SharedPreferences.getInstance();

    cache.setString(kOWApiToken, kOpenWeatherExpiredApiKey);
  }

  @override
  void dispose() {
    repository.client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Weather App'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: WeatherSearch(repository),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.wb_sunny,
              size: 64,
              color: Colors.grey,
            ),
            Container(
              height: 16,
            ),
            const Text(
              'Search for a city',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherSearch extends SearchDelegate<String?> {
  int selected = -1;
  WeatherRepository repo;

  WeatherSearch(this.repo);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          selected = -1;
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final city = selected == -1 ? null : cities[selected];

    return city != null ? buildWeatherCard(city) : buildEmptyCard();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? cities
        : cities.where((p) => p['name'].toString().startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            selected = index;
            query = cities[selected]['name'] as String;
            showResults(context);
          },
          title: Text(suggestionList[index]['name'] as String),
          subtitle: Text(suggestionList[index]['country'] as String),
        );
      },
    );
  }

  Widget buildWeatherCard(final city) {
    return FutureBuilder<Map<String, dynamic>>(
      future: repo.fetchCityWeather(city['id']),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error?.toString() ?? 'Error'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final weather = snapshot.data;
        final iconWeather = weather!['weather'][0]['icon'];
        final main = weather['main'];
        final wind = weather['wind'];
        return Card(
          margin: const EdgeInsets.all(16.0),
          child: Container(
            width: Size.infinite.width,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Tooltip(
                    message: weather['weather'][0]['main'],
                    child: Image.network(
                        'https://openweathermap.org/img/w/$iconWeather.png'),
                  ),
                  title: Text(city['name']),
                  subtitle: Text(city['country']),
                ),
                ListTile(
                  title: Text("${main["temp"]} °C"),
                  subtitle: const Text('Temperature'),
                ),
                ListTile(
                  title: Text("${main["temp_min"]} °C"),
                  subtitle: const Text('Min Temperature'),
                ),
                ListTile(
                  title: Text("${main["temp_max"]} °C"),
                  subtitle: const Text('Max Temperature'),
                ),
                ListTile(
                  title: Text("${main["humidity"]} %"),
                  subtitle: const Text('Humidity'),
                ),
                ListTile(
                  title: Text("${main["pressure"]} hpa"),
                  subtitle: const Text('Pressure'),
                ),
                ListTile(
                  title: Text("${wind["speed"]} m/s"),
                  subtitle: const Text('Wind Speed'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildEmptyCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.wb_sunny,
            size: 64,
            color: Colors.grey,
          ),
          Container(
            height: 16,
          ),
          const Text(
            'Search for a city',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

const baseUrl = 'https://api.openweathermap.org/data/2.5';

class WeatherRepository {
  InterceptedClient client;

  WeatherRepository(this.client);

  // Alternatively you can forget about using the Client and just doing the HTTP request with
  // the InterceptedHttp.build() call.
  // Future<Map<String, dynamic>> fetchCityWeather(int id) async {
  //   var parsedWeather;
  //   try {
  //     var response = await InterceptedHttp.build(
  //             interceptors: [WeatherApiInterceptor()])
  //         .get("$baseUrl/weather", params: {'id': "$id"});
  //     if (response.statusCode == 200) {
  //       parsedWeather = json.decode(response.body);
  //     } else {
  //       throw Exception("Error while fetching. \n ${response.body}");
  //     }
  //   } catch (e) {
  //     log(e);
  //   }
  //   return parsedWeather;
  // }

  Future<Map<String, dynamic>> fetchCityWeather(int? id) async {
    Map<String, dynamic> parsedWeather;
    try {
      final response =
          await client.get('$baseUrl/weather'.toUri(), params: {'id': '$id'});
      if (response.statusCode == 200) {
        parsedWeather = jsonDecode(response.body);
      } else {
        return Future.error(
          'Error while fetching.',
          StackTrace.fromString(response.body),
        );
      }
    } on SocketException {
      return Future.error('No Internet connection 😑');
    } on FormatException {
      return Future.error('Bad response format 👎');
    } on Exception catch (error) {
      log(error.toString());
      return Future.error('Unexpected error 😢');
    }

    return parsedWeather;
  }
}

const String kOWApiToken = 'TOKEN';

class WeatherApiInterceptor extends InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final cache = await SharedPreferences.getInstance();

    final Map<String, String> headers = Map.from(request.headers);
    headers[HttpHeaders.contentTypeHeader] = 'application/json';

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

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 2;

  @override
  Future<bool> shouldAttemptRetryOnException(
    Exception reason,
    BaseRequest request,
  ) async {
    log(reason.toString());

    return false;
  }

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response.statusCode == 401) {
      log('Retrying request...');
      final cache = await SharedPreferences.getInstance();

      cache.setString(kOWApiToken, kOpenWeatherApiKey);

      return true;
    }

    return false;
  }
}
