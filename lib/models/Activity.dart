import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/models/Vehicle.dart';

class Activity {
  int id;
  String type;
  Agent agent;
  Vehicle vehicle;
  Address origin;
  Address destiny;
  double price;
  double evaluation;
  String? obs;
  String route;
  bool canceled;
  String? cancellingReason;

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
      this.cancellingReason});

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
        id: map['id'],
        type: map['type'],
        agent: Agent.fromMap(map['agent']),
        vehicle: Vehicle.fromMap(map['vehicle']),
        origin: Address.fromMap(map['origin']),
        destiny: Address.fromMap(map['destiny']),
        price: map['price'],
        evaluation: map['evaluation'],
        route: map['route'],
        canceled: map['canceled'],
        obs: map['obs'],
        cancellingReason: map['cancellingReason']);
  }
}
