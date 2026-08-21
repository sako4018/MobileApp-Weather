import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(
    apiKey: 'c1f9e9253234c2881cde3c9bd2a67f65',
  );

  final TextEditingController _searchController =
      TextEditingController();

  Weather? _weather;
  String? _error;
  bool _isLoading = false;

  // --------------------------------------------------
  // Текуща локация
  // --------------------------------------------------

  Future<void> _fetchWeatherByLocation() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather =
          await _weatherService.getWeatherByLocation();

      if (!mounted) return;

      setState(() {
        _weather = weather;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _cleanErrorMessage(e);
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------
  // Търсене на град
  // --------------------------------------------------

  Future<void> _searchCity(String cityName) async {
    final city = cityName.trim();

    if (city.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather =
          await _weatherService.getWeather(city);

      if (!mounted) return;

      setState(() {
        _weather = weather;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Градът не е намерен. Провери изписването.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------
  // Чисто съобщение за грешка
  // --------------------------------------------------

  String _cleanErrorMessage(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.substring(11);
    }

    return message;
  }

  // --------------------------------------------------
  // Weather animation
  // --------------------------------------------------

  String getWeatherAnimation(Weather? weather) {
    if (weather == null) {
      return 'assets/sunny.json';
    }

    final mainCondition =
        weather.mainCondition.toLowerCase();

    final isNight = weather.isNight;

    switch (mainCondition) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return isNight
            ? 'assets/cloudy-night.json'
            : 'assets/windy.json';

      case 'thunderstorm':
        return 'assets/stormy.json';

      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return isNight
            ? 'assets/rainy-night.json'
            : 'assets/rainy.json';

      case 'snow':
        return 'assets/snow.json';

      default:
        return isNight
            ? 'assets/night.json'
            : 'assets/sunny.json';
    }
  }

  // --------------------------------------------------
  // Background
  // --------------------------------------------------

  List<Color> getBackgroundGradient(Weather? weather) {
    if (weather == null) {
      return [
        Colors.blue.shade300,
        Colors.blue.shade700,
      ];
    }

    if (weather.isNight) {
      return [
        Colors.indigo.shade900,
        Colors.black,
      ];
    }

    switch (weather.mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return [
          Colors.blueGrey.shade400,
          Colors.blueGrey.shade800,
        ];

      case 'thunderstorm':
        return [
          Colors.grey.shade800,
          Colors.black,
        ];

      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return [
          Colors.indigo.shade400,
          Colors.indigo.shade900,
        ];

      case 'snow':
        return [
          Colors.blueGrey.shade200,
          Colors.blueGrey.shade500,
        ];

      default:
        return [
          Colors.orange.shade300,
          Colors.deepOrange.shade600,
        ];
    }
  }

  // --------------------------------------------------
  // INIT
  // --------------------------------------------------

  @override
  void initState() {
    super.initState();

    // НЕ искаме GPS автоматично.
    //
    // Потребителят ще натисне 📍,
    // когато иска да използва текущата си локация.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        getBackgroundGradient(_weather);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // ------------------------------------------------
                  // SEARCH BAR
                  // ------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction:
                              TextInputAction.search,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Търси град...',
                            hintStyle: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.7),
                            ),
                            filled: true,
                            fillColor:
                                Colors.white.withOpacity(0.15),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                          onSubmitted: _searchCity,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ------------------------------------------------
                      // LOCATION BUTTON
                      // ------------------------------------------------

                      IconButton(
                        onPressed: _isLoading
                            ? null
                            : _fetchWeatherByLocation,
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white.withOpacity(0.15),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // ------------------------------------------------
                  // LOADING
                  // ------------------------------------------------

                  if (_isLoading)
                    const Column(
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Зареждане...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )

                  // ------------------------------------------------
                  // ERROR
                  // ------------------------------------------------

                  else if (_error != null)
                    Column(
                      children: [
                        const Icon(
                          Icons.location_off,
                          color: Colors.white,
                          size: 60,
                        ),

                        const SizedBox(height: 20),

                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed:
                              _fetchWeatherByLocation,
                          icon: const Icon(
                            Icons.location_on,
                          ),
                          label: const Text(
                            'Опитай отново',
                          ),
                        ),
                      ],
                    )

                  // ------------------------------------------------
                  // NO WEATHER YET
                  // ------------------------------------------------

                  else if (_weather == null)
                    Column(
                      children: [
                        Lottie.asset(
                          'assets/sunny.json',
                          width: 180,
                          height: 180,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Какво е времето?',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Потърси град или използвай\n'
                          'текущата си локация.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color:
                                Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    )

                  // ------------------------------------------------
                  // WEATHER
                  // ------------------------------------------------

                  else ...[
                    Text(
                      _weather!.cityName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Lottie.asset(
                      getWeatherAnimation(_weather),
                      width: 220,
                      height: 220,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${_weather!.temperature.round()}°C',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _weather!.mainCondition,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color:
                            Colors.white.withOpacity(0.9),
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _weather!.description,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}