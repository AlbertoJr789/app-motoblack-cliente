import 'package:app_motoblack_cliente/models/Address.dart';

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
  String name;
  AgentType type;
  Address? currentLocation;
  String? avatar;

  Agent({required this.name, required this.type, this.currentLocation, this.avatar});

  factory Agent.fromJson(Map<String, dynamic> map) {
    return Agent(
        name: map['name'],
        avatar: map['avatar'], 
        type: _agentTypeToEnum(map['type']['tipo']),
        );
  }

  String get typeName {
    switch(type){
      case AgentType.motoblack: return 'Motoblack';
      case AgentType.driver: return 'Motorista';
      default: return '';
    }
  }


}
