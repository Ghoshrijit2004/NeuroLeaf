import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>> getWeather(
      double lat,
      double lon,
      ) async {

    final url =
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat'
        '&longitude=$lon'
        '&current=temperature_2m,relative_humidity_2m,weather_code';

    final response = await http.get(Uri.parse(url));

    final data = jsonDecode(response.body);
    final weatherCode =
    data['current']['weather_code'] ?? 0;
    String getWeatherCondition(int code) {
  switch (code) {
    case 0:
      return 'Clear Sky';
    case 1:
    case 2:
    case 3:
      return 'Partly Cloudy';
    case 45:
    case 48:
      return 'Fog';
    case 51:
    case 53:
    case 55:
      return 'Drizzle';
    case 61:
    case 63:
    case 65:
      return 'Rain';
    case 71:
    case 73:
    case 75:
      return 'Snow';
    case 95:
      return 'Thunderstorm';
    default:
      return 'Unknown';
  }
}

    return {
  'temp': data['current']['temperature_2m'] ?? 0,
  'humidity': data['current']['relative_humidity_2m'] ?? 0,
  'condition': getWeatherCondition(weatherCode),
};
  }
}