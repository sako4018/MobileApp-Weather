import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static const String reverseGeocodingUrl =
      'https://api.openweathermap.org/geo/1.0/reverse';

  final String apiKey;

  WeatherService({
    required this.apiKey,
  });

  // --------------------------------------------------
  // Времето по име на град
  // --------------------------------------------------

  Future<Weather> getWeather(String cityName) async {
    final url = Uri.parse(
      '$baseUrl?q=${Uri.encodeComponent(cityName)}'
      '&appid=$apiKey'
      '&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 404) {
      throw Exception('Градът не е намерен.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Неуспешно зареждане на времето. '
        'Код: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    return Weather.fromJson(data);
  }

  // --------------------------------------------------
  // Времето според текущата GPS локация
  // --------------------------------------------------

  Future<Weather> getWeatherByLocation() async {
    try {
      // Проверяваме дали Location Services са включени
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Местоположението е изключено. '
          'Включи Location Services и опитай отново.',
        );
      }

      // Проверяваме текущото permission състояние
      LocationPermission permission =
          await Geolocator.checkPermission();

      // Все още не сме питали потребителя
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Потребителят е отказал
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Нямаме достъп до местоположението. '
          'Разреши Location достъпа и опитай отново.',
        );
      }

      // Потребителят е блокирал достъпа окончателно
      if (permission == LocationPermission.deniedForever) {
        if (kIsWeb) {
          throw Exception(
            'Достъпът до местоположението е блокиран за този сайт. '
            'Разреши Location от настройките на браузъра.',
          );
        }

        throw Exception(
          'Достъпът до местоположението е блокиран. '
          'Разреши го от настройките на устройството.',
        );
      }

      // Получаваме GPS координатите
      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // --------------------------------------------------
      // GPS координати -> град
      //
      // Използваме OpenWeather Reverse Geocoding,
      // вместо Flutter geocoding package.
      // --------------------------------------------------

      final cityName = await _getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Получаваме времето за този град
      return await getWeather(cityName);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception(
        'Не успяхме да получим текущото местоположение.',
      );
    }
  }

  // --------------------------------------------------
  // GPS координати -> име на град
  // --------------------------------------------------

  Future<String> _getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$reverseGeocodingUrl'
      '?lat=$latitude'
      '&lon=$longitude'
      '&limit=1'
      '&appid=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Не успяхме да определим текущия град.',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body);

    if (data.isEmpty) {
      throw Exception(
        'Не успяхме да определим текущия град.',
      );
    }

    final location = data.first;

    final city =
        location['local_names']?['en'] ??
        location['name'];

    if (city == null || city.toString().isEmpty) {
      throw Exception(
        'Не успяхме да определим текущия град.',
      );
    }

    return city.toString();
  }
}