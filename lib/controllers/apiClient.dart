
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {

  ApiClient._(){
     dio.options.connectTimeout = const Duration(seconds: 2);
     dio.options.receiveTimeout = const Duration(seconds: 3);
     dio.options.baseUrl = 'http://10.0.0.40:8000';
     dio.options.responseType = ResponseType.json;
  }

  static final ApiClient instance = ApiClient._();

  Dio dio = Dio();

  String get baseUrl => dio.options.baseUrl;

  Future<String?> get token async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     return prefs.getString('token');
  }

}