
import 'package:app_motoblack_cliente/main.dart';
import 'package:app_motoblack_cliente/screens/login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {

  ApiClient._(){
    dio.options.connectTimeout = const Duration(seconds: 2);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.baseUrl = 'http://10.0.0.46:8000';
    dio.options.responseType = ResponseType.json;
    dio.interceptors.add( //wrapper that will be called upon every request
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Authorization'] = 'Bearer ${await token}';
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) { //the goal is to treat 401 responses and redirect to login screen again
              navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => Login()), (route) => false);
          }
          return handler.next(e);
        },
      ),
    );


  }

  static final ApiClient instance = ApiClient._();

  Dio dio = Dio();

  String get baseUrl => dio.options.baseUrl;

  Future<String?> get token async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     return prefs.getString('token');
  }

}