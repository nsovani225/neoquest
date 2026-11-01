// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
// This project targets Flutter web only, so use the browser request API directly.
// ignore: deprecated_member_use
import 'dart:html' as html;

class CurrentWeather {
  const CurrentWeather({required this.temperatureF, required this.summary});
  final double temperatureF;
  final String summary;
}

/// Tiny public REST integration used to make the landing page API-driven today.
/// Open-Meteo does not require an API key for this demo request.
class WeatherApi {
  Future<CurrentWeather> forBerkeley() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '37.8715',
      'longitude': '-122.2730',
      'current': 'temperature_2m,weather_code',
      'temperature_unit': 'fahrenheit',
    });
    final response = await html.HttpRequest.request(
      uri.toString(),
      requestHeaders: const {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 7));
    final body =
        jsonDecode(response.responseText ?? '{}') as Map<String, dynamic>;
    final current = body['current'] as Map<String, dynamic>;
    return CurrentWeather(
      temperatureF: (current['temperature_2m'] as num).toDouble(),
      summary: _summary(current['weather_code'] as int),
    );
  }

  String _summary(int code) => switch (code) {
    0 => 'Clear skies',
    1 || 2 => 'A little cloudy',
    3 => 'Cloudy',
    45 || 48 => 'Foggy',
    51 || 53 || 55 || 56 || 57 => 'Light drizzle',
    61 || 63 || 65 || 66 || 67 => 'Rain nearby',
    71 || 73 || 75 || 77 => 'Snow nearby',
    80 || 81 || 82 => 'Passing showers',
    95 || 96 || 99 => 'Thunderstorms',
    _ => 'A good day to explore',
  };
}
