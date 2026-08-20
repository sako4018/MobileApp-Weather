import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../models/weather.dart';

class WeatherService {
  static const BASE_URL =
      'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;

  WeatherService({required this.apiKey});

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse(
        '$BASE_URL?q=$cityName&appid=$apiKey&units=metric',
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Weather.fromJson(data);
    } else {
      throw Exception(
        'API грешка (${response.statusCode}): ${data['message']}',
      );
    }
  }

  Future<Weather> getWeatherByLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Достъпът до локацията е отказан.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Достъпът до локацията е окончателно отказан. '
        'Разреши Location от настройките на браузъра.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final response = await http.get(
      Uri.parse(
        '$BASE_URL'
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
        'API грешка (${response.statusCode}): ${data['message']}',
      );
    }
  }

  Future<String> getCurrentCity() async {
    if (kIsWeb) {
      return "Plovdiv";
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Достъпът до локацията е отказан.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Достъпът до локацията е окончателно отказан.');
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final geocoding = Geocoding();

    List<Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      throw Exception(
        'Не може да се определи градът от координатите',
      );
    }

    String? city = placemarks[0].locality;

    return city ?? "";
  }
}