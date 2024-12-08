import 'dart:async';

import 'package:app_motoblack_cliente/controllers/tripController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Trip extends StatefulWidget {

  Activity trip;
  Function endTripAction;
  
  Trip({super.key,required this.trip,required this.endTripAction});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> with TickerProviderStateMixin {
    
  Timer? _timer;
  late String _time;
  final Stopwatch _stopwatch = Stopwatch();
  final TripController _controller = TripController();
  late StreamSubscription _tripStream;
  late Agent? _agent;   
  bool _foundAgent = false;

  @override
  void initState() {
    super.initState();
    _drawAgent();
  }

  _drawAgent() async {
    _agent = await _controller.drawAgent(widget.trip);
    _tripStream = FirebaseDatabase.instance.ref('trips').child(widget.trip.uuid!).onValue.listen((querySnapshot) async {
      final data = querySnapshot.snapshot.value as Map;
      print(data['agent']);
      if(data['agent'].containsKey('id')){
        _foundAgent = true;
        _tripStream.cancel();
        _manageTrip();
      }
      if(data['agent']['accepting'] == false){
        _agent = await _controller.drawAgent(widget.trip);
      }
    });
  }

  _manageTrip(){
       _tripStream = FirebaseDatabase.instance.ref('trips').child(widget.trip.uuid!).onValue.listen((querySnapshot) async {
        final data = querySnapshot.snapshot.value as Map;
        if(data['cancelled'] == true){ //agent cancelled

        }
        //update map coordinates
      });
  }


  @override
  Widget build(BuildContext context) {
    // _setTimer();
    // _stopwatch.start();
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
                      "Procurando um ${widget.trip.agentActivityType} pertinho de você...",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: (){
                      widget.endTripAction();
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

  _setTimer(){
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(_stopwatch.elapsed.inHours > 0){
        setState(() {
          _time = '${_stopwatch.elapsed.inHours.toString().padLeft(2, '0')}:${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }else{
        setState(() {
          _time = '${_stopwatch.elapsed.inMinutes.toString().padLeft(2, '0')}:${(_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  void dispose() {
    print('dispose trip');
    _stopwatch.reset();
    _stopwatch.stop();
    _timer!.cancel();           
    _tripStream.cancel(); 
    super.dispose();
  }

  // GoogleMap(
  //                     initialCameraPosition: CameraPosition(
  //                         target: LatLng(_driveRes.origin.latitude,
  //                             _driveRes.origin.longitude),
  //                         zoom: 16),
  //                   )
}