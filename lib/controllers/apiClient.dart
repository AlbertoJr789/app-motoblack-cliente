
import 'package:dio/dio.dart';

class ApiClient {

  ApiClient._(){
     dio.options.connectTimeout = const Duration(seconds: 2);
     dio.options.receiveTimeout = const Duration(seconds: 3);
     dio.options.baseUrl = 'http://moto-black.domcloud.io';
     dio.options.responseType = ResponseType.json;
  }

  static final ApiClient instance = ApiClient._();

  Dio dio = Dio();

  String get baseUrl => dio.options.baseUrl;


}