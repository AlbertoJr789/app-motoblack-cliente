import 'dart:async';

import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/controllers/tripController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Trip extends StatefulWidget {

  
  Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
    
  late ActivityController _controller;
  late StreamSubscription _tripStream;
  late Agent? _agent;   
  bool _foundAgent = false;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _drawAgent();
  }

  _drawAgent() async {
    _agent = await _controller.drawAgent(_controller.currentActivity!);
    _tripStream = FirebaseDatabase.instance.ref('trips').child(_controller.currentActivity!.uuid!).onValue.listen((querySnapshot) async {
      final data = querySnapshot.snapshot.value as Map;
      if(data['agent'].containsKey('id')){
        _foundAgent = true;
        _tripStream.cancel();
        _manageTrip();
      }
      if(data['agent']['accepting'] == false){
        _agent = await _controller.drawAgent(_controller.currentActivity!);
      }
    });
  }

  _manageTrip(){
       _tripStream = FirebaseDatabase.instance.ref('trips').child(_controller.currentActivity!.uuid!).onValue.listen((querySnapshot) async {
        final data = querySnapshot.snapshot.value as Map;
        if(data['cancelled'] == true){ //agent cancelled

        }
        //update map coordinates
      });
  }


  @override
  Widget build(BuildContext context) {

    return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors:  [
                    Color.fromARGB(255, 197, 179, 88),
                    Color.fromARGB(255, 238, 205, 39),
                  ],),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Procurando um ${_controller.currentActivity!.agentActivityType} pertinho de você...",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: (){
                      _endTripDialog();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors
                              .red), // Set the background color of the icon
                    ),
                  )
                ],
              ),
            ),
          );
  }

    void _endTripDialog(){
      showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tem certeza que deseja cancelar a corrida ?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                
              });
              Navigator.pop(ctx);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('dispose trip');      
    _tripStream.cancel(); 
    super.dispose();
  }

}