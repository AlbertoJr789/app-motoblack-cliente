import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ActivityController extends ChangeNotifier {
  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Activity> activities = [];

  final ApiClient apiClient = ApiClient.instance;

  getActivities() async {
    try {
      String? token = await apiClient.token;
      Response response = await apiClient.dio.get(
        '/api/activities?page=$_page',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
            'Authorization': "Bearer $token"
          },
        ),
        queryParameters: {'page': _page},
      );
    print(response.data);
      if (response.data['success']) {
        final data = response.data['data']['result'];
        _hasMore = response.data['data']['hasMore'];
        _page++;
        for (var i = 0; i < data.length; i++) {
          activities.add(Activity.fromMap(data[i]));
        }
      } else {
        _page = 1;
        _hasMore = true;
        throw new Exception(response.data['message']);
      }
      this.error = '';
    } catch (e) {
      this.error = e.toString();
    }
    print(this.error);
    notifyListeners();
  }

  bool get hasMore => _hasMore;

}
