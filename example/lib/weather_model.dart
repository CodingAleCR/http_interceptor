class Weather {
  Weather({
    required this.condition,
    required this.main,
    required this.wind,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List<dynamic>?) ?? const [];
    final conditionJson = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : const <String, dynamic>{};

    return Weather(
      condition: WeatherCondition.fromJson(conditionJson),
      main: WeatherMain.fromJson(json['main'] as Map<String, dynamic>),
      wind: WeatherWind.fromJson(json['wind'] as Map<String, dynamic>),
    );
  }

  final WeatherCondition condition;
  final WeatherMain main;
  final WeatherWind wind;
}

class WeatherCondition {
  WeatherCondition({
    required this.main,
    required this.icon,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      main: (json['main'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? '',
    );
  }

  final String main;
  final String icon;
}

class WeatherMain {
  WeatherMain({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
  });

  factory WeatherMain.fromJson(Map<String, dynamic> json) {
    return WeatherMain(
      temp: (json['temp'] as num?) ?? 0,
      tempMin: (json['temp_min'] as num?) ?? 0,
      tempMax: (json['temp_max'] as num?) ?? 0,
      humidity: (json['humidity'] as num?) ?? 0,
      pressure: (json['pressure'] as num?) ?? 0,
    );
  }

  final num temp;
  final num tempMin;
  final num tempMax;
  final num humidity;
  final num pressure;
}

class WeatherWind {
  WeatherWind({
    required this.speed,
  });

  factory WeatherWind.fromJson(Map<String, dynamic> json) {
    return WeatherWind(
      speed: (json['speed'] as num?) ?? 0,
    );
  }

  final num speed;
}
