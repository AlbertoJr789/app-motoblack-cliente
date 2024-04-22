import 'package:app_motoblack_cliente/models/Address.dart';

class Agent{

  String name;
  int? type;
  Address? currentLocation;
    
  Agent({required this.name,this.type,this.currentLocation});


  factory Agent.fromMap(Map<String,dynamic> map){
      return Agent(name: map['name']);
  }

}