import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';
//

class WeatherService {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl?q=$cityName&appid=$apiKey&units=metric',
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Weather.fromJson(data);
    } else {
      throw Exception(
        'API error (${response.statusCode}): ${data['message']}',
      );
    }
  }

  Future<Weather> getWeatherByLocation() async {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission was permanently denied. '
        'Please enable Location access in your browser settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final response = await http.get(
      Uri.parse(
        '$baseUrl'
        '?lat=${position.latitude}'
        '&lon=${position.longitude}'
        '&appid=$apiKey'
        '&units=metric',
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Weather.fromJson(data);
    } else {
      throw Exception(
        'API error (${response.statusCode}): ${data['message']}',
      );
    }
  }
}