class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final String description;

  final int sunrise;
  final int sunset;
  final int timezone;
  final int timestamp;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.description,
    required this.sunrise,
    required this.sunset,
    required this.timezone,
    required this.timestamp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature:
          (json['main']['temp'] as num).toDouble(),
      mainCondition:
          json['weather'][0]['main'] ?? 'Unknown',
      description:
          json['weather'][0]['description'] ?? '',
      sunrise:
          json['sys']['sunrise'] ?? 0,
      sunset:
          json['sys']['sunset'] ?? 0,
      timezone:
          json['timezone'] ?? 0,
      timestamp:
          json['dt'] ?? 0,
    );
  }

  bool get isNight {
    final localTime =
        DateTime.fromMillisecondsSinceEpoch(
      (timestamp + timezone) * 1000,
      isUtc: true,
    );

    final sunriseTime =
        DateTime.fromMillisecondsSinceEpoch(
      (sunrise + timezone) * 1000,
      isUtc: true,
    );

    final sunsetTime =
        DateTime.fromMillisecondsSinceEpoch(
      (sunset + timezone) * 1000,
      isUtc: true,
    );

    return localTime.isBefore(sunriseTime) ||
        localTime.isAfter(sunsetTime);
  }
}