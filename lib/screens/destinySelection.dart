import 'package:app_motoblack_cliente/controllers/activityController.dart';
import 'package:app_motoblack_cliente/controllers/destinySelectionController.dart';
import 'package:app_motoblack_cliente/models/Activity.dart';
import 'package:app_motoblack_cliente/models/Address.dart';
import 'package:app_motoblack_cliente/widgets/assets/toast.dart';
import 'package:app_motoblack_cliente/widgets/destinySelection/addressAutoComplete.dart';
import 'package:app_motoblack_cliente/widgets/destinySelection/autoFillButton.dart';
import 'package:app_motoblack_cliente/widgets/destinySelection/initTripButton.dart';
import 'package:app_motoblack_cliente/widgets/trip/tripIcon.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/util.dart';
import 'dart:async';

class DestinySelection extends StatefulWidget {
  DestinySelection({super.key});

  final TextEditingController origin = TextEditingController();
  final TextEditingController destiny = TextEditingController();

  //vallidation control
  final originKey = GlobalKey<FormFieldState<String>>();
  final destinyKey = GlobalKey<FormFieldState<String>>();

  final FocusNode originfocusNode = FocusNode();
  final FocusNode destinyfocusNode = FocusNode();
  bool firstAddress = true;

  @override
  State<DestinySelection> createState() => _DestinySelectionState();
}

class _DestinySelectionState extends State<DestinySelection> {
  //map address flags
  bool _gettingAddress = false;
  bool _autoFill = true;

  bool _selectingOrigin = true;
  bool _selectingDestiny = false;

  GoogleMapController? _mapController;

  Address? _originPosition;
  Address? _destinyPosition;

  final DestinySelectionController _destinySelectionController =
      DestinySelectionController();

  final _formKey = GlobalKey<FormState>();

  Timer? _debounce;

  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  
  BitmapDescriptor? _iconOrigin;
  BitmapDescriptor? _iconDestiny;

  @override
  void initState() {
    super.initState();
    
    widget.origin.text = "Obtendo sua localização...";
    _destinySelectionController.getUserLocation().then((value) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(value.latitude, value.longitude),
            zoom: 16,
          ),
        ),
      ).then((value) {
       Future.delayed(const Duration(seconds: 1), () {
         setState(() {
           _selectingDestiny = true;
           _selectingOrigin = false;
         });
       });
      });
    }).catchError((error, stackTrace) {
      showAlert(
          context,
          'Tivemos um erro ao obter sua localização!',
          'Digite seu ponto de origem manualmente ou selecione-o no mapa.',
          error.toString());
      _selectingOrigin = true;
      _selectingDestiny = false;
    });

    widget.originfocusNode.addListener(() {
      if (widget.originfocusNode.hasFocus) {
        _animatePosition(_originPosition!);
      }
      setState(() {}); //to show clear button on right side of text field so use can clear text
    });

    widget.destinyfocusNode.addListener(() {
      if (widget.destinyfocusNode.hasFocus) {
          _animatePosition(_destinyPosition!);
      }
      setState(() {}); //to show clear button on right side of text field so use can clear text
    });

  }


  void _animatePosition(Address position) {
    
    if (widget.destinyfocusNode.hasFocus) {
      _selectingOrigin = false;
      _selectingDestiny = true;
    }else{
      _selectingOrigin = true;
      _selectingDestiny = false;
    }

    _gettingAddress = false;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(position.latitude!, position.longitude!), zoom: 16),
      ),
    ).then((value) {
       if (_debounce?.isActive ?? false) _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () async {
          _gettingAddress = true;
        });
    });

  }

  void _setMarkers() async{
    
    _markers.clear();
    
    if(_originPosition != null){
      _markers.add(Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(_originPosition!.latitude!, _originPosition!.longitude!),
        icon: _iconOrigin ??= await createFlagBitmapFromIcon(Icon(Icons.flag,color: Theme.of(context).colorScheme.secondary)),
      ));
    }

    if(_destinyPosition != null){
      _markers.add(Marker(
        markerId: const MarkerId('destiny'),
        position: LatLng(_destinyPosition!.latitude!, _destinyPosition!.longitude!),
          icon: _iconDestiny ??= await createFlagBitmapFromIcon(Icon(Icons.flag_circle_rounded,color: Theme.of(context).colorScheme.surface,)),
        ));
    }
    
    _polylines.clear();
    if (_originPosition != null && _destinyPosition != null) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_originPosition!.latitude!, _originPosition!.longitude!),
            LatLng(_destinyPosition!.latitude!, _destinyPosition!.longitude!),
          ],
          color: Theme.of(context).colorScheme.secondary,
          width: 4,
        ),
      );     
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar corrida'),
      ),
      body: Column(
        children: [
          Column(children: [
            Material(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AddressAutoComplete(
                            textController: widget.origin,
                            focusNode: widget.originfocusNode,
                            formFieldKey: widget.originKey,
                            position: _originPosition,
                            onSelected: (address) {
                                _originPosition = address;
                                _animatePosition(_originPosition!);
                                _setMarkers();
                            },
                            onValidate: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  _originPosition == null || !_originPosition!.addressComplete) {
                                return 'Endereço inválido!';
                              }
                              return null;
                            },
                            hintText: "De onde ?",
                            labelText: "Origem",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AddressAutoComplete(
                            textController: widget.destiny,
                            focusNode: widget.destinyfocusNode,
                            formFieldKey: widget.destinyKey,
                            position: _destinyPosition,
                            onSelected: (address) {
                              _destinyPosition = address;
                              _animatePosition(_destinyPosition!);
                              _setMarkers();
                            },
                            onValidate: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  _destinyPosition == null || !_destinyPosition!.addressComplete) {
                                return 'Endereço inválido!';
                              }
                              return null;

                            },
                            hintText: "Para onde ?",
                            labelText: "Destino",
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
                    target: LatLng(-20.4630769, -45.4443985), zoom: 16),
                onCameraMove: (position) {
                  if(_autoFill){
                    if(_selectingDestiny){
                      _destinyPosition = Address(latitude: position.target.latitude, longitude: position.target.longitude);
                    }else{
                      _originPosition = Address(latitude: position.target.latitude, longitude: position.target.longitude);
                    }
                   _setMarkers();
                  }
                },
                onCameraIdle: () {
                  _getAddress();
                },
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: Set<Marker>.of(_markers),
                polylines: Set<Polyline>.of(_polylines),
              ),
              AutoFillButton(onChanged: (value) {
                _autoFill = value;
              }),
              InitTripButton(
                  originPosition: () => _originPosition,
                  destinyPosition: () => _destinyPosition,
                  formKey: _formKey),
            ]),
          ),
        ],
      ),
    );
  }

  void _getAddress() async {

    if (_gettingAddress && _autoFill) {
    
      if (_selectingOrigin) {
        widget.origin.text = "Carregando...";
        
        _destinySelectionController
            .getAddress(_originPosition!.latitude!,
                _originPosition!.longitude!)
            .then((address) {
              print(address.formattedAddress + address.zipCode!);
              widget.origin.text = address.formattedAddress;
              _originPosition = address;
        }).catchError((e) {
          showAlert(
              context,
              "Erro ao obter endereço no mapa!",
              "Digite o endereço aproximado para que possamos definir o ponto de origem/destino ou tente novamente mais tarde.",
              e.toString());
        });
    
      } else if (_selectingDestiny) {
        widget.destiny.text = "Carregando...";
         
        _destinySelectionController
            .getAddress(_destinyPosition!.latitude!,
                _destinyPosition!.longitude!)
            .then((address) {
              print(address.formattedAddress + address.zipCode!);
              widget.destiny.text = address.formattedAddress;
              _destinyPosition = address;
        }).catchError((e) {
          showAlert(
              context,
              "Erro ao obter endereço no mapa!",
              "Digite o endereço aproximado para que possamos definir o ponto de origem/destino ou tente novamente mais tarde.",
              e.toString());
        });
      }
    
      _setMarkers();
    }
    _gettingAddress = true;
  }

  @override
  void dispose() {
    widget.origin.clear();
    widget.destiny.clear();
    widget.originfocusNode.dispose();
    widget.destinyfocusNode.dispose();
    super.dispose();
  }
}
