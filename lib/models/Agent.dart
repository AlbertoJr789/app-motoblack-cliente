import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/models/Vehicle.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AgentType { motoblack, driver, unknown }

AgentType _agentTypeToEnum(int type) {
  switch (type) {
    case 1:
      return AgentType.motoblack;
    case 2:
      return AgentType.driver;
    default:
      return AgentType.unknown;
  }
}

class Agent {
  int? id;
  String name;
  Address? currentLocation;
  String? avatar;
  Vehicle? vehicle;

  Agent({this.id,required this.name,this.currentLocation, this.avatar,this.vehicle});

  factory Agent.fromJson(Map<String, dynamic> map) {
    return Agent(
        id: map['id'],
        name: map['name'],
        avatar: map['avatar'], 
        vehicle: Vehicle.fromJson(map['vehicle'])
        );
  }

  String get typeName {
    if(vehicle == null) return '';
    switch(vehicle!.type){
      case VehicleType.motorcycle: return 'Motoblack';
      case VehicleType.car: return 'Motorista';
      default: return '';
    }
  }


  static Future<String?> getUuid() async { 
    final prefs = await SharedPreferences.getInstance(); 
    return prefs.getString('uuid');
  }

  static setUuid(String uuid) {
   SharedPreferences.getInstance().then((instance)=> instance.setString('uuid', uuid));
  }


}
