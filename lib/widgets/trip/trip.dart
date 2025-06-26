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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fluttermocklocation/fluttermocklocation.dart';

class Trip extends StatefulWidget {
  const Trip({super.key});

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

  final _mock = Fluttermocklocation();

  BitmapDescriptor? _agentIcon;
  late Agent? _tempAgent;

  bool _allowConclusion = false;
  double _acceptableRadius = 30;

  int maxTries = 10;
  Duration maxTriesDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _drawAgent();
    _tripStatus();
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
        : Stack(
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
                      onTap: (){
                        toastInfo(context, 'Fique neste raio para conseguir concluir a corrida, entenderemos que você chegou próximo ao seu destino');
                      },
                      center: LatLng(
                          _controller.currentActivity!.destiny.latitude!,
                          _controller.currentActivity!.destiny.longitude!),
                      radius: _acceptableRadius,
                      strokeWidth: 2,
                      strokeColor:
                          _allowConclusion ? Colors.green : Colors.red,
                      fillColor: _allowConclusion
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.redAccent.withOpacity(0.2),
        
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
                    icon: Icon(
                      _allowConclusion ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                    label: Text(
                      _allowConclusion ? "Concluir" : "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          _allowConclusion
                              ? Colors.green
                              : Colors
                                  .red), // Set the background color of the icon
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton.icon(
                        onPressed: _endTripDialog,
                        icon: Icon(
                          _allowConclusion ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                        label: Text(
                          _allowConclusion ? "Concluir" : "Cancelar",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              _allowConclusion
                                  ? Colors.green
                                  : Colors
                                      .red), // Set the background color of the icon
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
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
    
    if(_controller.currentActivity != null){
      if(_controller.currentActivity!.agent != null) return;
      _tempAgent = await _controller.drawAgent(_controller.currentActivity!);
    }

    if(_tempAgent == null){
      if(maxTries > 0){
        maxTries--;
        Timer(maxTriesDuration, () { //try again after 20 seconds
          _drawAgent();
        });
        return;
      }else{
        if(mounted){
          toastError(context, 'Não foi possível encontrar um ${_controller.currentActivity!.agentActivityType} próximo a você. Por favor, tente novamente mais tarde.');
        }
        if(_controller.currentActivity != null){
          _controller.cancelActivity(trip: _controller.currentActivity!, reason: '404');
        }
      }
    }else{

       Timer(maxTriesDuration, () { //cooldown to try for another agent even if the current one hasnt accepted yet, 
          _drawAgent();
        });
        return;
    }
  }

  _addMarkers() async {
    final originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(_controller.currentActivity!.origin.latitude!,
          _controller.currentActivity!.origin.longitude!),
      icon: await createFlagBitmapFromIcon(
          Icon(Icons.flag, color: Theme.of(context).colorScheme.secondary)),
      infoWindow: const InfoWindow(
          title: 'Ponto de partida (fique próximo dessa área)'),
    );

    final destinyMarker = Marker(
      markerId: const MarkerId('destiny'),
      position: LatLng(_controller.currentActivity!.destiny.latitude!,
          _controller.currentActivity!.destiny.longitude!),
      icon: await createFlagBitmapFromIcon(Icon(Icons.flag_circle_rounded,
          color: Theme.of(context).colorScheme.surface)),
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

    //init agent location
    FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .child('agent').get().then((value) async {
          if(value.exists){
            _agentStatus();
            // _mockStatus();
            _myStatus();
          }
        });

    //TRIP STATUS
    _tripStream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;

        if (_controller.currentActivity!.agent == null) {
          //agent is not found yet
          if (data['agent'].containsKey('id')) {
            //found agent who accepted the trip, initialize the trip

            _controller.currentActivity!.agent = _tempAgent;
            _controller.currentActivity!.vehicle = _tempAgent!.vehicle;

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
            // _mockStatus();
            _myStatus(); //comment this piece of code if you're mocking the location and uncomment "_mockStatus"
            
            return;
          }

          if (data['agent']['accepting'] == false) {
            _drawAgent();
            return;
          }
        }
      } else {
        if(_dialogLoading == false){
          _tripStream.cancel();
          _agentStream.cancel();
          _locationListener.cancel();
          _controller.checkCancelled = _controller.currentActivity!.id!;
          _controller.toggleTrip(enabled: false,notify: true);
        }
      }
    });
  }

  _agentStatus() async {
    await _createMarkerIcon();
    await _addMarkers();

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
              title: 'Seu ${_controller.currentActivity!.vehicle!.agentType}'));
      setState(() {
        _markers.add(agentMarker);
      });
    });
  }

  Timer? _debounce;
  _mockStatus() {
    print('mock status');
    FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .child('passenger')
        .onValue
        .listen((querySnapshot) async {
          final data = querySnapshot.snapshot.value as Map;

          print('dados passageiro');
          print(data['latitude']);
          print(data['longitude']);
            _mock.updateMockLocation(data['latitude'], data['longitude']);
            if (_debounce?.isActive ?? false) _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () async {
              _checkRadius();
            });
        });
    
  }

  _myStatus() {
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

  void _endTripDialog() {
    if (_allowConclusion) {
      _finishTripDialog();
      return;
    }

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
  final _formDialogKey = GlobalKey<FormState>();
  bool _dialogLoading = false;

  void _cancelTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Form(
              key: _formDialogKey,
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
                if (_formDialogKey.currentState!.validate()) {
                  setState(() {
                    _dialogLoading = true;
                  });
                  final ret = await _controller.cancelActivity(
                    trip: _controller.currentActivity!,
                    reason: _cancellingReason.text,
                  );
                  setState(() {
                    _dialogLoading = false;
                  });
                  if (!ret) {
                    toastError(context, 'Houve um erro ao cancelar sua corrida! Tente novamente.');
                  } else {
                    Navigator.pop(ctx);
                    toastSuccess(context, 'Corrida cancelada com sucesso!');
                  }
                }
              },
              child: _dialogLoading
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

  double _evaluation = 0;
  TextEditingController _obs = TextEditingController();

  _finishTripDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Form(
            key: _formDialogKey,
            child: Column(
              children: [
                Text(
                  'Sua opinião é muito importante para nós! Por gentileza, avalie o nosso serviço:',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                FormField(
                  builder: (field) => RatingBar(
                    initialRating: _evaluation,
                    itemCount: 5,
                    allowHalfRating: true,
                    glowColor: Colors.amber,
                    glowRadius: 1,
                    ratingWidget: RatingWidget(
                        full: const Icon(Icons.star, color: Colors.amber),
                        half: const Icon(Icons.star_half, color: Colors.amber),
                        empty: const Icon(
                          Icons.star_outline_outlined,
                          color: Color.fromARGB(255, 209, 203, 203),
                        )),
                    onRatingUpdate: (rate) {
                      _evaluation = rate;
                    },
                  ),
                  validator: (value) {
                    if (_evaluation == 0) {
                      toastError(context, 'Por gentileza, avalie o serviço');
                      return 'Por gentileza, avalie o serviço';
                    }
                    return null;
                  },
                ),
                Text(
                  'Observação: ',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.start,
                ),
                TextFormField(
                  controller: _obs,
                  maxLines: 2,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText:
                        'Deixe uma observação/comentário sobre a corrida caso necessário',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formDialogKey.currentState!.validate()) {
                  setState(() {
                    _dialogLoading = true;
                  });
                  final ret = await _controller.finishActivity(
                    trip: _controller.currentActivity!,
                    evaluation: _evaluation,
                    evaluationComment: _obs.text,
                  );
                  setState(() {
                    _dialogLoading = false;
                  });
                  if (!ret) {
                    toastError(context,
                        'Houve um erro ao concluir sua corrida! Tente novamente.');
                  } else {
                    Navigator.pop(ctx);
                    toastSuccess(context,
                        'Corrida concluída com sucesso! Agradecemos a sua preferência!');
                  }
                }
              },
              child: _dialogLoading
                  ? Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    )
                  : Text('Concluir'),
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
