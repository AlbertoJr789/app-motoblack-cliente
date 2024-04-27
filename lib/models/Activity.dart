import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/models/Vehicle.dart';

enum ActivityType { delivery, trip, unknown }

ActivityType _activityTypeToEnum(int type) {
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
      required this.createdAt});

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
        id: map['id'],
        type: _activityTypeToEnum(map['type']['tipo']),
        agent: Agent.fromMap(map['agent']),
        vehicle: Vehicle.fromMap(map['vehicle']),
        origin: Address.fromMap(map['origin']),
        destiny: Address.fromMap(map['destiny']),
        price: double.parse(map['price'].toString()),
        evaluation: map['passengerEvaluation'],
        route: map['route'],
        canceled: map['cancelled'] == 1 ? true : false,
        obs: map['obs'],
        cancellingReason: map['cancellingReason'],
        createdAt: DateTime.parse(map['createdAt']));
  }

  String get typeName {
    switch(type){
      case ActivityType.trip: return 'Corrida';
      case ActivityType.delivery: return 'Entrega';
      default: return '';
    }
  }

}
