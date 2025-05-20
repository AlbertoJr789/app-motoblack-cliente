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

  Widget _getWeatherAnimation(String weather) {
    final userTime = DateTime.now().hour;
    switch (weather.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':{
        if(userTime > 18 || userTime < 6){
          return Lottie.asset('assets/weather/moon_cloud.json',height: 200);
        }else{
          return Lottie.asset('assets/weather/sun_cloud.json',height: 200);
        }
      }
      case 'rain':
      case 'drizzle':{
        if(userTime > 18 || userTime < 6){
          return Lottie.asset('assets/weather/moon_rain.json',height: 200);
        }else{
          return Lottie.asset('assets/weather/sun_rain.json',height: 200);
        }
      }
      case 'thunderstorm':
        return Lottie.asset('assets/weather/thunder.json',height: 200);
      default:
        if(userTime > 18 || userTime < 6){
          return Lottie.asset('assets/weather/moon.json',height: 200,);
        }else{
          return Lottie.asset('assets/weather/sun.json',height: 250);
        }
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
          _getWeatherAnimation(weather),
          Text('${temp.round()}°C',style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,color: Colors.white),),
        ],
      ),
    );
  }
} 