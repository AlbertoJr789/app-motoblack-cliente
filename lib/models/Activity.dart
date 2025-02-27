import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/models/Vehicle.dart';
import 'package:dio/dio.dart';

enum ActivityType { unknown, trip, carTrip, delivery }
enum WhoCancelled { unknown, passenger, agent }

ActivityType activityTypeToEnum(int type) {
  switch (type) {
    case 1:
      return ActivityType.trip;
    case 2:
      return ActivityType.carTrip;
    case 3:
      return ActivityType.delivery;
    default:
      return  ActivityType.unknown;
  }
}

WhoCancelled whoCancelledToEnum(int whoCancelled) {
  switch (whoCancelled) {
    case 1:
      return WhoCancelled.passenger;
    case 2: 
      return WhoCancelled.agent;
    default:
      return WhoCancelled.unknown;
  }
}

class Activity {
  int? id;
  String? uuid;
  ActivityType type;
  Agent? agent;
  Vehicle? vehicle;
  Address origin;
  Address destiny;
  double? price;
  double? evaluation;
  String? obs;
  String? route;
  bool? canceled;
  WhoCancelled? whoCancelled;
  String? cancellingReason;
  DateTime? createdAt;
  DateTime? finishedAt;

  static final ApiClient apiClient = ApiClient.instance;

  Activity(
      {this.id,
      this.uuid,
       required this.type,
       this.agent,
       this.vehicle,
      required this.origin,
      required this.destiny,
       this.price,
       this.evaluation,
      this.obs,
       this.canceled,
       this.route,
       this.whoCancelled,
      this.cancellingReason,
       this.createdAt,
      this.finishedAt});

  factory Activity.fromJson(Map<String, dynamic> map) {
    return Activity(
        id: map['id'],
        uuid: map['uuid'],
        type: activityTypeToEnum(map['type']['tipo']),
        agent: map['agent'] != null ? Agent.fromJson(map['agent']) : null,
        vehicle: map['vehicle'] != null ? Vehicle.fromJson(map['vehicle']) : null,
        origin: Address.fromJson(map['origin']),
        destiny: Address.fromJson(map['destiny']),
        price: map['price'] != null ? double.parse(map['price'].toString()) : null,
        evaluation: map['passengerEvaluation'] != null ? double.parse(map['passengerEvaluation'].toString()) : null,
        route: map['route'],
        canceled: map['cancelled'] == 1 ? true : false,
        obs: map['passengerObs'],
        cancellingReason: map['cancellingReason'],
        whoCancelled: map['whoCancelled'] != null ? whoCancelledToEnum(map['whoCancelled']) : null,
        createdAt: DateTime.parse(map['createdAt']),
        finishedAt: map['finishedAt'] != null ? DateTime.parse(map['finishedAt']) : null
        );
  }

  String get typeName {
    switch(type){
      case ActivityType.trip: return 'Corrida';
      case ActivityType.carTrip: return 'Corrida';
      case ActivityType.delivery: return 'Entrega';
      default: return '';
    }
  }

  String get agentActivityType {
    switch(type){
      case ActivityType.trip: return 'Moto Black';
      case ActivityType.carTrip: return 'Motorista';
      case ActivityType.delivery: return 'Entregador';
      default: return '';
    }
  }

 static Future<Response> getActivities({int page=1,bool unrated=false}) async {
    var queryParameters = {'page': page};
    if(unrated){
      queryParameters['unrated'] = 1;
    }
    return await apiClient.dio.get(
        '/api/activity',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        queryParameters: queryParameters,
      );
  }

  static Future<Response> storeActivity(FormData data) async {
    return await apiClient.dio.post(
        '/api/activity',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            'accept': 'application/json',
          },
        ),
        data: data,
      );
  }


}
