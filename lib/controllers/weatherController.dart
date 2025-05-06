import 'package:app_motoblack_cliente/util/weather.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController {
  static const String _apiKey = '1ae3a9d5ab2096a975581c182159e08c'; // Replace with your actual API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getCurrentWeather(double latitude, double longitude) async {
    return await getWeather(latitude, longitude);
  }

  static Future<Map<String, dynamic>> getWeather(double latitude, double longitude) async {
    final url = Uri.parse('$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

} 