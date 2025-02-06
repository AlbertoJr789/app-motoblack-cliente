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
  BitmapDescriptor? _agentIcon;
  late Agent? _tempAgent;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _drawAgent();
  }

  _createMarkerIcon() async {
    try {
      final String url =
          '${ApiClient.instance.baseUrl}/api/marker/${_controller.currentActivity!.agent!.userId}';
      _agentIcon = await getMarkerImageFromUrl(url, targetWidth: 120);
      setState(() {});
    } catch (e) {
      _agentIcon = BitmapDescriptor.defaultMarker;
      setState(() {});
    }
  }

  _drawAgent() async {
    _tempAgent = await _controller.drawAgent(_controller.currentActivity!);
    _tripStream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      final data = querySnapshot.snapshot.value as Map;
      if (data['agent'].containsKey('id')) {
        
        _tripStream.cancel();
        _controller.currentActivity!.agent = _tempAgent;
        _manageTrip();
        setState(() {});
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          
          toastSuccess(context, 'Corrida iniciada! Confira mais detalhes acima.');
          
          _scrollController.animateTo(0.4,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
          
          Future.delayed(const Duration(seconds: 4), () {
            _scrollController.animateTo(0.075,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          });
        });
        return;
      }
      if (data['agent']['accepting'] == false) {
        _tempAgent = await _controller.drawAgent(_controller.currentActivity!);
      }
    });
  }

  _manageTrip() async {
    await _createMarkerIcon();

    _tripStream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;
        if (data['cancelled'] == true && data['whoCancelled'] == 'a') {
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
    });

    _agentStream = FirebaseDatabase.instance
        .ref('availableAgents')
        .child(_controller.currentActivity!.agent!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      final data = querySnapshot.snapshot.value as Map;
      _markers.clear();
      _markers.add(Marker(
          markerId: const MarkerId('agent'),
          position: LatLng(data['latitude'], data['longitude']),
          icon: _agentIcon!,
          infoWindow: InfoWindow(
              title: 'Seu ${_controller.currentActivity!.agent!.typeName}')));
      setState(() {});
    });

    _locationListener =
        Geolocator.getPositionStream().listen((Position position) {
      FirebaseDatabase.instance
          .ref('trips')
          .child(_controller.currentActivity!.uuid!)
          .child('passenger')
          .update(
              {'latitude': position.latitude, 'longitude': position.longitude});
    });
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
                Container(
                  width: double.infinity,
                  // height: 200,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(
                            _controller.currentActivity!.origin.latitude!,
                            _controller.currentActivity!.origin.longitude!),
                        zoom: 16),
                    markers: Set<Marker>.of(_markers),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
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
