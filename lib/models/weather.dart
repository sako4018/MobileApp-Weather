class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final int dt;        // текущо unix време от API-то
  final int sunrise;   // unix време на изгрев
  final int sunset;    // unix време на залез

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.dt,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
      dt: json['dt'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
    );
  }

  bool get isNight => dt < sunrise || dt > sunset;
}