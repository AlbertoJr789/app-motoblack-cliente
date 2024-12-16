import 'dart:async';

import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Agent.dart';
import 'package:app_motoblack_cliente/widgets/assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  Agent? _agent;
  bool _foundAgent = false;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<ActivityController>(context, listen: false);
    _drawAgent();
  }

  _drawAgent() async {
    _agent = await _controller.drawAgent(_controller.currentActivity!);
    _tripStream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      final data = querySnapshot.snapshot.value as Map;
      if (data['agent'].containsKey('id')) {
        _foundAgent = true;
        _tripStream.cancel();
        _manageTrip();
        setState(() {});
        return;
      }
      if (data['agent']['accepting'] == false) {
        _agent = await _controller.drawAgent(_controller.currentActivity!);
      }
    });
  }

  _manageTrip() {
    _tripStream = FirebaseDatabase.instance
        .ref('trips')
        .child(_controller.currentActivity!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      if (querySnapshot.snapshot.exists) {
        final data = querySnapshot.snapshot.value as Map;
        if (data['cancelled'] == true) {
          _controller.cancelActivity(alreadyCancelled: true);
          _tripStream.cancel();
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Corrida cancelada pelo agente !'),
                  SizedBox(
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
        .child(_agent!.uuid!)
        .onValue
        .listen((querySnapshot) async {
      final data = querySnapshot.snapshot.value as Map;
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('agent'),
        position: LatLng(data['latitude'], data['longitude']),
      ));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_agent != null)
          Text(
            'Agente encontrado! Atente-se à descrição do mesmo:',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.inversePrimary),
            textAlign: TextAlign.center,
          ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.2,
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
                _agent == null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Procurando um ${_controller.currentActivity!.agentActivityType} pertinho de você...",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.person_off_outlined,
                                                color: Colors.black,
                                              ),
                                          imageUrl: _agent!.avatar!),
                                    ),
                                    Text(_agent!.name)
                                  ],
                                ),
                                Expanded(child: SizedBox()),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('Informações do veículo'),
                                    Row(
                                      children: [
                                        Icon(
                                          _agent!.vehicle!.icon,
                                          color: Color(int.parse(
                                            '0xFF${_agent!.vehicle!.color.toString().replaceFirst('#', '')}',
                                          )),
                                          size: 70,
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                                '${_agent!.vehicle!.brand} - ${_agent!.vehicle!.model}'),
                                            Row(
                                              children: [
                                                Text(
                                                    'Placa: ${_agent!.vehicle!.plate}, Cor: '),
                                                SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: Container(
                                                    color: Color(int.parse(
                                                      '0xFF${_agent!.vehicle!.color.toString().replaceFirst('#', '')}',
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Divider(),
                ),
                ElevatedButton.icon(
                  onPressed: () {
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
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.red), // Set the background color of the icon
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (_agent != null)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6 - 10,
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition(
                  target: LatLng(_controller.currentActivity!.origin.latitude!,
                      _controller.currentActivity!.origin.longitude!),
                  zoom: 16),
              markers: Set<Marker>.of(_markers),
            ),
          ),
      ],
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
                     _tripStream.cancel();
                     _agentStream.cancel();
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
    _tripStream.cancel();
    _agentStream.cancel();
    super.dispose();
  }
}
