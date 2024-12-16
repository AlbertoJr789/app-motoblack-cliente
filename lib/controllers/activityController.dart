import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ActivityController extends ChangeNotifier {
  
  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Activity> activities = [];
  Activity? currentActivity;

  static final ApiClient apiClient = ApiClient.instance;


  getActivities() async {
    try {
      Response response = await Activity.getActivities(_page);
      if (response.data['success']) {
        final data = response.data['data']['result'];
        _hasMore = response.data['data']['hasMore'];
        _page++;
        for (var i = 0; i < data.length; i++) {
          activities.add(Activity.fromJson(data[i]));
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

  Future<Map<String,dynamic>> initActivity(Address origin,Address destiny,int type) async {
      try {
        FormData data = FormData.fromMap({
          'origin': origin.toMap(),
          'destiny': destiny.toMap(),
          'type': type,
        });
        Response response = await Activity.storeActivity(data);
        if (response.data['success']) {
          return {"error": false,"activity": Activity.fromJson(response.data['data'])};
        } else {
          return {"error": response.data['data'],"status": response.statusCode};
        }
      } on DioException catch (e) {
        return {"error": e.response!.data['message'],"status": e.response!.statusCode};
      } catch (e) {
        return {"error": e.toString(),"status": 500};
      }
  }

   Future<Agent?> drawAgent(Activity trip) async {
      try {
      Response response = await apiClient.dio.get(
        '/api/drawAgent/${trip.id}',
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {
            'accept': 'application/json',
          },
        )
      );
      return Agent.fromJson(response.data['data']); 
    } on DioException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }
  
   Future<bool> cancelActivity({Activity? trip,String? reason,bool alreadyCancelled=false}) async {
    try {

      if(alreadyCancelled){ //if it was cancelled from somewhere else
        currentActivity = null;
        notifyListeners();
        return true;
      }

      Response response = await apiClient.dio.post(
        '/api/cancel/${trip!.id}',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
        data: {'reason': reason}
      );
      currentActivity = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

}
