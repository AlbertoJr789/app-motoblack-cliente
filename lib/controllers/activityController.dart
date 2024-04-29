import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ActivityController extends ChangeNotifier {
  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Activity> activities = [];

  getActivities() async {
    try {
      Response response = await Activity.getActivities(_page);
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
        throw response.data['message'];
      }
      error = '';
    } catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  bool get hasMore => _hasMore;

}
