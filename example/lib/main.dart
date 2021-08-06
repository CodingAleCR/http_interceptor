import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'credentials.dart'; // If you are going to run this example you need to replace the key.
import 'cities.dart'; // This is just a List of Maps that contains the suggested cities.

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    cache.setString(appToken, OPEN_WEATHER_EXPIRED_API_KEY);
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
            icon: Icon(Icons.search),
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
            Icon(
              Icons.wb_sunny,
              size: 64,
              color: Colors.grey,
            ),
            Container(
              height: 16,
            ),
            Text(
              "Search for a city",
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
        icon: Icon(Icons.clear),
        onPressed: () {
          selected = -1;
          query = "";
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
        : cities.where((p) => p["name"].toString().startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            selected = index;
            query = cities[selected]["name"] as String;
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
      future: repo.fetchCityWeather(city["id"]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error as String),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final weather = snapshot.data;
        final iconWeather = weather!["weather"][0]["icon"];
        final main = weather["main"];
        final wind = weather["wind"];
        return Card(
          margin: EdgeInsets.all(16.0),
          child: Container(
            width: Size.infinite.width,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Tooltip(
                    child: Image.network(
                        "https://openweathermap.org/img/w/$iconWeather.png"),
                    message: weather["weather"][0]["main"],
                  ),
                  title: Text(city["name"]),
                  subtitle: Text(city["country"]),
                ),
                ListTile(
                  title: Text("${main["temp"]} °C"),
                  subtitle: Text("Temperature"),
                ),
                ListTile(
                  title: Text("${main["temp_min"]} °C"),
                  subtitle: Text("Min Temperature"),
                ),
                ListTile(
                  title: Text("${main["temp_max"]} °C"),
                  subtitle: Text("Max Temperature"),
                ),
                ListTile(
                  title: Text("${main["humidity"]} %"),
                  subtitle: Text("Humidity"),
                ),
                ListTile(
                  title: Text("${main["pressure"]} hpa"),
                  subtitle: Text("Pressure"),
                ),
                ListTile(
                  title: Text("${wind["speed"]} m/s"),
                  subtitle: Text("Wind Speed"),
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
          Icon(
            Icons.wb_sunny,
            size: 64,
            color: Colors.grey,
          ),
          Container(
            height: 16,
          ),
          Text(
            "Search for a city",
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

const baseUrl = "https://api.openweathermap.org/data/2.5";

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
  //     print(e);
  //   }
  //   return parsedWeather;
  // }

  Future<Map<String, dynamic>> fetchCityWeather(int? id) async {
    var parsedWeather;
    try {
      final response =
          await client.get("$baseUrl/weather".toUri(), params: {'id': "$id"});
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
    } on Exception catch (error) {
      print(error);
      return Future.error('Unexpected error 😢');
    }

    return parsedWeather;
  }
}

class LoggerInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print("----- Request -----");
    print(data.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print("----- Response -----");
    print(data.toString());
    return data;
  }
}

const String appToken = "TOKEN";

class WeatherApiInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    try {
      final cache = await SharedPreferences.getInstance();

      data.params['appid'] = cache.getString(appToken);
      data.params['units'] = 'metric';
      data.headers[HttpHeaders.contentTypeHeader] = "application/json";
    } catch (e) {
      print(e);
    }
    print(data.params);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async =>
      data;
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  int get maxRetryAttempts => 2;

  @override
  bool shouldAttemptRetryOnException(Exception reason) {
    print(reason);

    return false;
  }

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
