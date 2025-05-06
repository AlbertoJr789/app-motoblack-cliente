import 'package:app_motoblack_cliente/controllers/destinySelectionController.dart';
import 'package:flutter/material.dart';
import 'package:app_motoblack_cliente/controllers/weatherController.dart';
import 'package:lottie/lottie.dart';

class WeatherDisplay extends StatefulWidget {
 
  const WeatherDisplay({Key? key}) : super(key: key);

  @override
  State<WeatherDisplay> createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {
  final WeatherController _weatherController = WeatherController();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final position = await DestinySelectionController().getUserLocation();
      final data = await _weatherController.getCurrentWeather(position.latitude, position.longitude);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getWeatherAnimation(String weather) {
    final userTime = DateTime.now().hour;
    switch (weather.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':{
        if(userTime > 18 || userTime < 6){
          return 'moon_cloud';
        }else{
          return 'sun_cloud';
        }
      }
      case 'rain':
      case 'drizzle':{
        if(userTime > 18 || userTime < 6){
          return 'moon_rain';
        }else{
          return 'sun_rain';
        }
      }
      case 'thunderstorm':
        return 'thunder';
      default:
        return 'sun';
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: const CircularProgressIndicator());
    }
    if (_error != null) {
      return const Text('');
    }
    if (_weatherData == null) {
      return const Text('');
    }

    final city = _weatherData!['name'];
    final temp = _weatherData!['main']['temp'];
    final weather = _weatherData!['weather'][0]['main'];

    return Center(
      child: Column(
        children: [
          SizedBox(height: 50,),
          Column(
            children: [
              Icon(Icons.location_on, color: Colors.white, size: 32),
              Text('$city',style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,color: Colors.white),),
            ],
          ),
          Lottie.asset('assets/weather/${_getWeatherAnimation(weather)}.json'),
          Text('${temp.round()}°C',style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,color: Colors.white),),
        ],
      ),
    );
  }
} 