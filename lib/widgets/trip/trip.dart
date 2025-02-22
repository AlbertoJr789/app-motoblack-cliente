import 'dart:async';

import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/controllers/apiClient.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/widgets/assets/toast.dart';
import 'package:app_motoblack_cliente/widgets/trip/tripAgentDetails.dart';
import 'package:app_motoblack_cliente/widgets/trip/tripIcon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Trip extends StatefulWidget {
  Trip({super.key});

  @override
  State<Trip> createState() => _TripState();
}

class _TripState extends State<Trip> {
  late ActivityController _controller;
  late StreamSubscription _tripStream;
  late StreamSubscription _agentStream;
  late StreamSubscription _locationListener;
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _showMap = true;

  BitmapDescriptor? _agentIcon;
  late Agent? _tempAgent;
  
  bool _allowConclusion = false;
  double _acceptableRadius = 30;


  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _drawAgent();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.currentActivity!.agent == null
        ? Container(
            width: double.infinity,
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 197, 179, 88),
                  Color.fromARGB(255, 238, 205, 39),
                ],
              ),
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
                    onPressed: _endTripDialog,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.red), // Set the background color of the icon
                    ),
                  ),
                ],
              ),
            ),
          )
        : Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_showMap)
                Container(
                  width: double.infinity,
                  // height: 200,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            _controller.currentActivity!.origin.latitude!,
                            _controller.currentActivity!.origin.longitude!),
                        zoom: 16),
                    markers: Set<Marker>.of(_markers),
                    polylines: Set<Polyline>.of(_polylines),
                    circles: {
                      Circle(
                        circleId: const CircleId('destination-area'),
                        center: LatLng(_controller.currentActivity!.destiny.latitude!,
                            _controller.currentActivity!.destiny.longitude!),
                        radius: _acceptableRadius,
                        strokeWidth: 2,
                        strokeColor: _allowConclusion  ? Colors.green : Colors.red,
                        fillColor: _allowConclusion ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                      ),
                    },
                    ),
                  ),   

                
                Align(
                  alignment: Alignment.bottomCenter,
                  child: DraggableScrollableSheet(
                    controller: _scrollController,
                    maxChildSize: 0.3, // Max height relative to the screen
                    minChildSize: 0.075, // Min height relative to the screen
                    initialChildSize:
                        0.075, // Initial height relative to the screen
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black,
                                    ),
                                    width: 50,
                                    height: 10,
                                  ),
                                ),
                                Text('Informações da Corrida'),
                                TripAgentDetails(
                                    activity: _controller.currentActivity!),
                              ],
                            )),
                      );
                    },
                  ),
                ),
                 Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: Tooltip(
                    message: 'Esconder/Exibir Mapa',
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _showMap = !_showMap;
                        });
                      },
                      child: Icon(
                        _showMap ? Icons.map : Icons.map_outlined,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                if (_showMap)
                    Positioned(
                      top: 30.0,
                      left: 0.0,
                      right: 0.0,
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: _endTripDialog,
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.red), // Set the background color of the icon
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      top: 20.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "Corrida em andamento. Ative o mapa para ver o ${_controller.currentActivity!.agentActivityType}.",
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              textAlign: TextAlign.center,
                            ),
                            ElevatedButton.icon(
                              onPressed: _endTripDialog,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Cancelar",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Colors.red), // Set the background color of the icon
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

              ],
            ),
          );
  }

  void _endTripDialog() {
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
              Navigator.pop(ctx);
              _cancelTripDialog();
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }
  
  _createMarkerIcon() async {
    try {
      final String url =
          '${ApiClient.instance.baseUrl}/api/marker/${_controller.currentActivity!.agent!.userId}';
      _agentIcon = await getMarkerImageFromUrl(url, targetWidth: 120);
      setState(() {});
    } catch (e) {
      print(e);
      _agentIcon = BitmapDescriptor.defaultMarker;
      setState(() {});
    }
  }

  _drawAgent() async {
    _tempAgent = await _controller.drawAgent(_controller.currentActivity!);
    _tripStatus();
  }

  _addMarkers() async {
    final originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(_controller.currentActivity!.origin.latitude!,
          _controller.currentActivity!.origin.longitude!),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag, color: Theme.of(context).colorScheme.secondary)),
      infoWindow: const InfoWindow(title: 'Ponto de partida (fique próximo dessa área)'),
    );

    final destinyMarker = Marker(
      markerId: const MarkerId('destiny'),
      position: LatLng(_controller.currentActivity!.destiny.latitude!,
          _controller.currentActivity!.destiny.longitude!),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag_circle_rounded, color: Theme.of(context).colorScheme.surface)),
      infoWindow: const InfoWindow(title: 'Ponto de destino'),
    );

    _markers.add(originMarker);
    _markers.add(destinyMarker);

    final polyline = Polyline(
      width: 4,
      polylineId: const PolylineId('origin-destiny'),
      points: [
        LatLng(_controller.currentActivity!.origin.latitude!,
            _controller.currentActivity!.origin.longitude!),
        LatLng(_controller.currentActivity!.destiny.latitude!,
            _controller.currentActivity!.destiny.longitude!)
      ],
      color: Theme.of(context).colorScheme.secondary,
    );
    
    _polylines.add(polyline);
  }

  _tripStatus() {
    //TRIP STATUS
    _tripStream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;

        if(_controller.currentActivity!.agent == null){ //agent inst found yet
            if (data['agent'].containsKey('id')) { //found agent who accepted the trip, initialize the trip
              
              _addMarkers();
              _controller.currentActivity!.agent = _tempAgent;
              
              WidgetsBinding.instance.addPostFrameCallback((_) {
                toastSuccess(
                    context, 'Corrida iniciada! Confira mais detalhes acima.');

                _scrollController.animateTo(0.4,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);

                Future.delayed(const Duration(seconds: 4), () {
                  _scrollController.animateTo(0.075,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                });
              });

              //initialize position listeners
              _agentStatus();
              _myStatus();
              setState(() {});
              return;
            }

            if (data['agent']['accepting'] == false) {
              _tempAgent = await _controller.drawAgent(_controller.currentActivity!);
              return;
            }

        }else{
          if (data['cancelled'] == true && data['whoCancelled'] == 'a') { //listens for possible trip cancellation by agent
            _controller.cancelActivity(alreadyCancelled: true);
            _tripStream.cancel();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Corrida cancelada pelo agente !'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('Motivo: ${data['cancellingReason']}'),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }
        }
      }else{
        _tripStream.cancel();
        _controller.cancelActivity(alreadyCancelled: true);
        return;
      }
    });
  }

  _agentStatus() async {

    await _createMarkerIcon();

     //AGENT POSITION
    _agentStream = FirebaseDatabase.instance
        .ref('availableAgents')
        .child(_controller.currentActivity!.agent!.uuid!)
        .onValue
        .listen((querySnapshot) async {
            final data = querySnapshot.snapshot.value as Map;
            _markers.removeWhere((marker) => marker.markerId.value == 'agent');
            final agentMarker = Marker(
              markerId: const MarkerId('agent'),
              position: LatLng(data['latitude'], data['longitude']),
              icon: _agentIcon!,
              infoWindow: InfoWindow(
                    title: 'Seu ${_controller.currentActivity!.agent!.typeName}'));
            setState(() {
              _markers.add(agentMarker);
            });
    });
  }

  _myStatus(){
    //MY POSITION
    _locationListener =
        Geolocator.getPositionStream().listen((Position position) {
      FirebaseDatabase.instance
          .ref('trips')
          .child(_controller.currentActivity!.uuid!)
          .child('passenger')
          .update(
              {'latitude': position.latitude, 'longitude': position.longitude});
      _checkRadius();
    });
  }


  _checkRadius() {
    final destination = _controller.currentActivity!.destiny;
    final agentPosition = _markers.firstWhere((marker) => marker.markerId.value == 'agent').position;

    Geolocator.getCurrentPosition().then((Position passengerPosition) {
      
      final passengerDistance = Geolocator.distanceBetween(
        passengerPosition.latitude,
        passengerPosition.longitude,
        destination.latitude!,
        destination.longitude!,
      );
  
      if (mounted) {
        setState(() {
          _allowConclusion = passengerDistance <= _acceptableRadius;
        });
      }
    });
  }



  TextEditingController _cancellingReason = TextEditingController();
  final _formCancelamentoKey = GlobalKey<FormState>();
  bool _cancelling = false;

  void _cancelTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Form(
              key: _formCancelamentoKey,
              child: Column(
                children: [
                  Text('Insira o motivo do cancelamento: '),
                  TextFormField(
                    controller: _cancellingReason,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Motivo não pode estar vazio';
                      }
                      return null;
                    },
                  )
                ],
              )),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formCancelamentoKey.currentState!.validate()) {
                  setState(() {
                    _cancelling = true;
                  });
                  final ret = await _controller.cancelActivity(
                    trip: _controller.currentActivity!,
                    reason: _cancellingReason.text,
                  );
                  setState(() {
                    _cancelling = false;
                  });
                  if (!ret) {
                    FToast().init(context).showToast(
                        child: MyToast(
                          msg: const Text(
                            'Houve um erro ao cancelar sua corrida! Tente novamente.',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          icon: const Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                          color: Colors.redAccent,
                        ),
                        gravity: ToastGravity.BOTTOM,
                        toastDuration: const Duration(seconds: 5));
                  } else {
                    Navigator.pop(ctx);
                  }
                }
              },
              child: _cancelling
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : Text('Cancelar'),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    try {
      _tripStream.cancel();
    } catch (e) {}

    try {
      _agentStream.cancel();
    } catch (e) {}

    try {
      _locationListener.cancel();
    } catch (e) {}

    super.dispose();
  }
}
