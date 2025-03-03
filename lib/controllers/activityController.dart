import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActivityController extends ChangeNotifier {
  
  int _page = 1;
  bool _hasMore = true;
  String error = '';
  List<Activity> activities = [];

  Activity? currentActivity;
  var checkCancelled = 0;
  bool _enableTrip = false;


  static final ApiClient apiClient = ApiClient.instance;

  getActivities(reset) async {
    try {
      if(reset){
        _page = 1;
        _hasMore = true;
        activities = [];
      }
      Response response = await Activity.getActivities(page: _page);
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
        removeCurrentActivity();
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
      removeCurrentActivity();
      return true;
    } on DioException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> finishActivity({Activity? trip,double? evaluation,String? evaluationComment}) async {
    try {
      Response response = await apiClient.dio.patch(
        '/api/activity/${trip!.id}',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
        data: {'nota_agente': evaluation,'obs_passageiro': evaluationComment}
      );
      removeCurrentActivity();
      return true;
    } catch (e) {
      return false;
    }
  }

  checkCurrentActivity() async {    
    //get pendent activity from API
    final response = await Activity.getActivities(unrated: checkCancelled == 0 ? true : false,cancelled: checkCancelled == 0 ? true : false);
    if (response.data['success']) {
        final data = response.data['data']['result'];
        try{
          if(checkCancelled != 0 && data[0]['id'] != checkCancelled){ throw Exception();}
          currentActivity = Activity.fromJson(data[0]);
        }catch(e){
          if(checkCancelled != 0){
            checkCancelled = 0;
            checkCurrentActivity();
            return;
          }else{
            currentActivity = null;
          }
        }
    } else {
      throw response.data['message'];
    }
  }

  toggleTrip({bool enabled = true,bool notify = false}){
    _enableTrip = enabled;
    if(notify){
      notifyListeners();
    }
  }

  get enableTrip => _enableTrip;

  removeCurrentActivity({bool notify = true}) async {
    currentActivity = null;
    toggleTrip(enabled: true,notify: notify);
  }

}
