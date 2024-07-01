import 'dart:async';
import 'dart:convert';

import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../util/util.dart';
import '../models/Activity.dart';

class DestinySelection extends StatefulWidget {
  DestinySelection({super.key});

  TextEditingController origin =  TextEditingController();
  TextEditingController destiny = TextEditingController();
  bool firstAddress = true;

  @override
  State<DestinySelection> createState() => _DestinySelectionState();
}

class _DestinySelectionState extends State<DestinySelection> {

  bool _gettingAddress = false;
  bool _selectingOrigin = false;
  bool _selectingDestiny = true;
  CameraPosition? _currentPosition;
  GoogleMapController? _mapController;
  Map<String, double>? _originPosition;
  Map<String, double>? _destinyPosition;
  ActivityController _controller = ActivityController();
  final _formKey = GlobalKey<FormState>();

  Future<Position> _getUserLocation() async {
    try {

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
          throw 'Seu serviço de localização está desativado! Reative-o nas configurações do seu dispositivo.';
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw 'Permissão negada! Precisamos da sua permissão para obter sua localização automaticamente!';
      }

      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  void _getAddress(latitude, longitude) async {
    // latitude = -20.461858529051117;
    // longitude = -45.43592934890276;
    try {
      if (widget.firstAddress == false) {
        if (_selectingOrigin) {
          widget.origin.text = "Carregando...";
        } else if (_selectingDestiny) {
          widget.destiny.text = "Carregando...";
        }
      }

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=AIzaSyCgo47TDRIpqJ2ZDmMcGWwkxI6oejOju0U');

      final response = await http.get(url);
      final data = json.decode(response.body);
      String address = data['results'][0]['formatted_address'];
      if (address.contains('-')) {
        address = address.substring(0, address.indexOf('-') - 1);
      } else {
        address = address.substring(0, address.indexOf(',') - 1);
      }

      if (widget.firstAddress == false) {
        if (_selectingOrigin) {
          widget.origin.text = address;
          _originPosition = {'lat': latitude, 'lon': longitude};
        } else if (_selectingDestiny) {
          widget.destiny.text = address;
          _destinyPosition = {'lat': latitude, 'lon': longitude};
        }
      } else {
        widget.origin.text = address;
        widget.firstAddress = false;
        _originPosition = {'lat': latitude, 'lon': longitude};
      }
    } catch (e) {
      showAlert(context, "Erro ao obter endereço no mapa!", "Digite o endereço aproximado para que possamos definir o ponto de origem/destino ou tente novamente mais tarde.", e.toString());
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.origin.text = "Obtendo sua localização...";
    _getUserLocation().then((value) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(value.latitude, value.longitude),
            zoom: 16,
          ),
        ),
      );
      _getAddress(value.latitude, value.longitude);
    }).catchError((error, stackTrace) {
      showAlert(context,'Tivemos um erro ao obter sua localização!','Digite seu ponto de origem manualmente ou selecione-o no mapa.',
          error.toString());
      _selectingOrigin = true;
      _selectingDestiny = false;
    });
  }

  void _initTrip(BuildContext context) async {
    
    if (_formKey.currentState!.validate()) {

        await _controller.initActivity(_originPosition!,_destinyPosition!,activityTypeToEnum(3));

        if(context.mounted){
          Navigator.pop(context, {
            "origin": _originPosition,
            "destiny": _destinyPosition
          });
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleção de Corrida'),
      ),
      body: Column(
        children: [
          Column(children: [
            Material(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 197, 179, 88),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          child: TextFormField(
                            controller: widget.origin,
                            decoration: const InputDecoration(
                              labelText: "Origem",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            onTap: () {
                              _selectingDestiny = false;
                              _selectingOrigin = true;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  _originPosition == null) {
                                return '';
                              }
                            },
                          ),
                        ),
                        Container(
                          height: 70,
                          child: TextFormField(
                            controller: widget.destiny,
                            decoration: const InputDecoration(
                              hintText: "Pra onde?",
                              labelText: "Destino",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            onTap: () {
                              _selectingDestiny = true;
                              _selectingOrigin = false;
                            },
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  _destinyPosition == null) {
                                return '';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ]),
          Expanded(
            child: Stack(children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                    target: LatLng(-20.4630769, -45.4443985),
                    zoom: 16),
                onCameraMove: (position) {
                  _currentPosition = position;
                },
                onCameraMoveStarted: () {
                  _gettingAddress = true;
                },
                onCameraIdle: () {
                  if (_gettingAddress) {
                    _getAddress(_currentPosition?.target.latitude,
                        _currentPosition?.target.longitude);
                    _gettingAddress = false;
                  }
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: ElevatedButton(
                      onPressed: () {
                        _initTrip(context);
                      },
                      child: const Text(
                        'Partiu!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.add_location,
                  size: 40,
                  color: Colors.black87,
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.origin.clear();
    widget.destiny.clear();
    super.dispose();
  }
}
