import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/models/Vehicle.dart';
import 'package:dio/dio.dart';

enum ActivityType { delivery, trip, unknown }

ActivityType activityTypeToEnum(int type) {
  switch (type) {
    case 1:
      return ActivityType.trip;
    case 2:
      return ActivityType.delivery;
    default:
      return ActivityType.unknown;
  }
}

class Activity {
  int id;
  ActivityType type;
  Agent agent;
  Vehicle vehicle;
  Address origin;
  Address destiny;
  double price;
  int evaluation;
  String? obs;
  String? route;
  bool canceled;
  String? cancellingReason;
  DateTime createdAt;
  DateTime? finishedAt;

  static final ApiClient apiClient = ApiClient.instance;

  Activity(
      {required this.id,
      required this.type,
      required this.agent,
      required this.vehicle,
      required this.origin,
      required this.destiny,
      required this.price,
      required this.evaluation,
      this.obs,
      required this.canceled,
      required this.route,
      this.cancellingReason,
      required this.createdAt,
      this.finishedAt});

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
        id: map['id'],
        type: activityTypeToEnum(map['type']['tipo']),
        agent: Agent.fromMap(map['agent']),
        vehicle: Vehicle.fromMap(map['vehicle']),
        origin: Address.fromMap(map['origin']),
        destiny: Address.fromMap(map['destiny']),
        price: double.parse(map['price'].toString()),
        evaluation: map['passengerEvaluation'],
        route: map['route'],
        canceled: map['cancelled'] == 1 ? true : false,
        obs: map['passengerObs'],
        cancellingReason: map['cancellingReason'],
        createdAt: DateTime.parse(map['createdAt']),
        finishedAt: DateTime.parse(map['finishedAt']));
  }

  String get typeName {
    switch(type){
      case ActivityType.trip: return 'Corrida';
      case ActivityType.delivery: return 'Entrega';
      default: return '';
    }
  }

  static getActivities(int page) async {
    return await apiClient.dio.get(
        '/api/activities',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        queryParameters: {'page': page},
      );
  }

  initActivity(Map<String,double> latitude,Map<String,double> longitude,ActivityType type) async {
      try {
        String? token = await apiClient.token;
        // FormData data = FormData.fromMap({
        //   'name': name,
        //   'phone': phone,
        //   'email': email,
        //   'photo': picture != null ? await MultipartFile.fromFile(picture.path) : null
        // });
        // Response response = await apiClient.dio.post(
        //   '/api/updateProfile',
        //   options: Options(
        //     contentType: Headers.multipartFormDataContentType,
        //     headers: {
        //       'accept': 'application/json',
        //       'Authorization': "Bearer $token"
        //     },
        //   ),
        //   data: data,
        // );
        // if (response.data['success']) {
        //   return {"error": false};
        // } else {
        //   return {"error": response.data['message'],"status": response.statusCode};
        // }
    } on DioException catch (e) {
      return {"error": e.response!.data['message'],"status": e.response!.statusCode};
    } catch (e) {
      return {"error": e.toString(),"status": 500};
    }
  }


}
