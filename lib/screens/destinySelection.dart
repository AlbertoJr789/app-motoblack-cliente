import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DestinySelection extends StatefulWidget {
  DestinySelection({super.key, required this.location});

  Position location;
  TextEditingController origin = new TextEditingController();
  TextEditingController destiny = new TextEditingController();
  bool firstAddress = true;


  @override
  State<DestinySelection> createState() => _DestinySelectionState();
}

class _DestinySelectionState extends State<DestinySelection> {
  bool _gettingAddress = false;
  bool _selectingOrigin = false;
  bool _selectingDestiny = true;
  CameraPosition? _currentPosition;
  Map<String,double>? _originPosition;
  Map<String,double>? _destinyPosition;
  final _formKey = GlobalKey<FormState>();


  void _getAddress(latitude, longitude) async {
    // latitude = -20.461858529051117;
    // longitude = -45.43592934890276;
    try {

      if(widget.firstAddress == false){  
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
      
      if(widget.firstAddress == false){
        if (_selectingOrigin) {
          widget.origin.text = address;
          _originPosition = {
            'lat': latitude,
            'lon': longitude
          }; 
        } else if (_selectingDestiny) {
          widget.destiny.text = address;
          _destinyPosition = {
            'lat': latitude,
            'lon': longitude
          };
        }
      }else{
        widget.origin.text = address;
        widget.firstAddress = false;
        _originPosition = {
          'lat': latitude,
          'lon': longitude
        };
      }

    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _getAddress(widget.location.latitude, widget.location.longitude);
  }

  @override
  void dispose() {
    widget.origin.clear();
    widget.destiny.clear();
    super.dispose();
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
                            validator: (value){
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
                            validator: (value){
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
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                        widget.location.latitude, widget.location.longitude),
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
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()){
                          Navigator.pop(context,{
                            "origin": _originPosition,
                            "destiny": _destinyPosition
                          });
                        }
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
}
